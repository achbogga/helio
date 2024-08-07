import os
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from analyze import analyze_video
import logging
from shutil import copyfile
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.DEBUG)

# Initialize FastAPI
app = FastAPI()

@app.post("/analyze_video/")
async def analyze_video_endpoint(file: UploadFile = File(...), labels: str = ""):
    # Save the uploaded file
    video_path = "uploaded_video.mp4"
    with open(video_path, "wb") as buffer:
        buffer.write(file.file.read())

    # Convert labels string to list
    filter_labels_list = labels.split(",") if labels else []

    # Analyze the video
    try:
        logging.debug(f"Starting analysis for video: {video_path} with labels: {filter_labels_list}")
        result = analyze_video(video_path, filter_labels_list)
        logging.debug(f"Analysis result: {result}")
        return JSONResponse(content=result)
    except Exception as e:
        logging.error(f"Error during video analysis: {e}")
        return JSONResponse(content={"error": str(e)}, status_code=500)
    finally:
        # save the video file for debugging purposes to a separate location, overwrite if already exists
        v_path = Path(video_path)
        copyfile(v_path, '/home/abogg/Downloads/' + v_path.name)
        if os.path.exists(video_path):
            os.remove(video_path)

# Run the application
if __name__ == "__main__":
    import uvicorn
    config = uvicorn.Config(app=app, host="0.0.0.0", port=8000, log_level="info")
    server = uvicorn.Server(config)
    server.run()
