import torch
import json
import urllib
from torchvision.transforms import Compose, Lambda
from torchvision.transforms._transforms_video import (
    CenterCropVideo,
    NormalizeVideo,
)
from pytorchvideo.data.encoded_video import EncodedVideo
from pytorchvideo.transforms import (
    ApplyTransformToKey,
    ShortSideScale,
    UniformTemporalSubsample,
)

# Load the slowfast_r50 model
model = torch.hub.load('facebookresearch/pytorchvideo', 'slowfast_r50', pretrained=True)

# Set device (GPU or CPU)
device = "cuda" if torch.cuda.is_available() else "cpu"
model = model.eval()
model = model.to(device)

# Load kinetics class names
json_url = "https://dl.fbaipublicfiles.com/pyslowfast/dataset/class_names/kinetics_classnames.json"
json_filename = "kinetics_classnames.json"
try:
    urllib.URLopener().retrieve(json_url, json_filename)
except:
    urllib.request.urlretrieve(json_url, json_filename)

with open(json_filename, "r") as f:
    kinetics_classnames = json.load(f)

# Create an id to label name mapping
kinetics_id_to_classname = {}
for k, v in kinetics_classnames.items():
    kinetics_id_to_classname[v] = str(k).replace('"', "")

# Define transformation for video input
class PackPathway(torch.nn.Module):
    """
    Transform for converting video frames as a list of tensors.
    """
    def __init__(self):
        super().__init__()

    def forward(self, frames: torch.Tensor):
        fast_pathway = frames
        # Perform temporal sampling from the fast pathway.
        slow_pathway = torch.index_select(
            frames,
            1,
            torch.linspace(
                0, frames.shape[1] - 1, frames.shape[1] // 4
            ).long(),
        )
        frame_list = [slow_pathway, fast_pathway]
        return frame_list

# Transformation pipeline for video preprocessing
transform =  ApplyTransformToKey(
    key="video",
    transform=Compose(
        [
            UniformTemporalSubsample(32),  # 32 frames
            Lambda(lambda x: x/255.0),
            NormalizeVideo([0.45, 0.45, 0.45], [0.225, 0.225, 0.225]),
            ShortSideScale(256),  # Resize short side to 256
            CenterCropVideo(256),  # Crop center to 256x256
            PackPathway()  # Pack frames into slow and fast pathways
        ]
    ),
)

def analyze_video(
        url_link,
        filter_labels_list,
        window_size=5, # seconds
        fps = 30, # frames per second
):
    """
    returns:
     - timestamped_labels_dict (dict): Dictionary containing timestamps (begin, end) and predicted labels.
    """
    from tqdm import tqdm
    # Download the video file
    video_path = 'video.mp4'
    try:
        urllib.URLopener().retrieve(url_link, video_path)
    except:
        urllib.request.urlretrieve(url_link, video_path)

    # Initialize EncodedVideo helper class and load the video
    video = EncodedVideo.from_path(video_path)

    # get the number of frames based on the video fps
    clip_duration = video.duration
    num_frames =  int(fps * clip_duration)
    timestamped_labels_dict = {}
    for i in tqdm(range(0, num_frames, int(window_size * fps))):
        start_sec = int(i / fps)
        end_sec = start_sec + window_size
        predicted_labels = classify_video(video, start_sec, end_sec, filter_labels_list)
        if predicted_labels:
            timestamped_labels_dict[(start_sec, end_sec)] = predicted_labels
    return timestamped_labels_dict 


def classify_video(
        video,
        start_sec,
        end_sec, 
        filter_labels_list,
    ):
    """
    Function to classify actions in a video and filter based on provided labels.

    Args:
    - url_link (str): URL link to the video file.
    - filter_labels_list (list of str): List of labels to filter predictions.

    Returns:
    - filtered_label
    """

    # Load the desired clip from the video
    video_data = video.get_clip(start_sec=start_sec, end_sec=end_sec)

    # Apply transformation to normalize and preprocess the video clip
    video_data = transform(video_data)

    # Move inputs to the desired device
    inputs = video_data["video"]
    inputs = [i.to(device)[None, ...] for i in inputs]

    # Pass the input clip through the model
    with torch.no_grad():
        preds = model(inputs)

    # Get the predicted classes
    post_act = torch.nn.Softmax(dim=1)
    preds = post_act(preds)
    pred_classes = preds.topk(k=1).indices[0]  # Get the top predicted class index

    # Map the predicted classes to label names
    pred_class_names = [kinetics_id_to_classname[int(i)] for i in pred_classes]

    # Filter predicted labels based on filter_labels_list
    filtered_pred_class_names = [label for label in pred_class_names if any(filter_label.lower() in label.lower() for filter_label in filter_labels_list)]

    return filtered_pred_class_names

# Example usage
url_link = "https://dl.fbaipublicfiles.com/pytorchvideo/projects/archery.mp4"
filter_labels_list = ['squat', 'jumping jacks', 'archery']

predicted_labels_dict = analyze_video(url_link, filter_labels_list)
print("Predicted labels with timestamps: ", predicted_labels_dict)
