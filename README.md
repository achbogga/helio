# helio
Helio Video based AI Workout Journal App
- Runs on an Iphone
- Runs on a FastAPI server
- Uses Pytorch slowfast model for action recognition

## Helio: Intelligent Video Analysis App
### Overview
- Helio is an advanced video analysis application designed to leverage machine learning for real-time action recognition. Built with FastAPI and PyTorch Video, - Helio provides a robust platform for analyzing videos uploaded by users, identifying specific actions, and filtering results based on user-defined labels.

### Features
- Video Upload and Processing: Users can upload video files directly through a user-friendly interface. Helio processes these videos to detect and classify various actions.
- Action Recognition: Utilizing the SlowFast R50 model from PyTorch Video, Helio performs sophisticated video analysis to recognize and classify actions present in the video.
- Flexible Label Filtering: Users can specify a list of actions or labels to filter the results. This allows for targeted analysis and retrieval of relevant information.
- Timestamped Results: The app provides timestamped results, indicating when specific actions were detected within the video. This feature helps users pinpoint and review relevant sections of the video.
- Real-time Feedback: The app offers real-time feedback and results, ensuring users receive prompt and accurate analysis.
### Technology Stack
- FastAPI: A modern, fast (high-performance) web framework for building APIs with Python 3.6+ based on standard Python type hints.
- PyTorch Video: A library that provides video processing functionalities and pre-trained models for video action recognition.
Torchvision: A library that includes popular pre-trained models and transforms for video data processing.
How It Works
- Upload: Users upload a video file via the FastAPI endpoint.
- Process: The video is processed using PyTorch Video's SlowFast R50 model. This involves applying a series of transformations to prepare the video data for classification.
- Classify: The processed video is analyzed to detect and classify actions. Results are filtered based on user-defined labels.
- Respond: The app returns the classification results, including timestamps for when each action was detected in the video.
Example Use Case
- A fitness coach uploads a video of a workout session and specifies labels such as "squat," "jumping jacks," and "archery." Helio analyzes the video, detects when each of these actions occurs, and provides a timestamped list of detected actions. This allows the coach to quickly review and analyze specific segments of the workout.

### Installation and Usage
- Clone the Repository: Clone the Helio repository from GitHub.
- Install Dependencies: Install the required Python packages using pip install -r requirements.txt.
- Run the Application: Start the FastAPI server using uvicorn main:app --host 0.0.0.0 --port 8000.
- Upload and Analyze: Access the API endpoint to upload videos and receive analysis results.
- Future Improvements
- User Interface: Develop a frontend UI to enhance user experience and simplify video uploads.
- Performance Optimization: Implement additional optimizations for faster video processing and analysis.
- Extended Model Support: Integrate more pre-trained models to support a wider range of action categories.


## getting started
### the app is currently running on a google cloud instance at http://34.72.202.95:8000/docs
- create a conda env and then install the following
```bash
conda create -n helio python=3.11
conda activate helio
conda install mamba -c conda-forge
conda install pytorch==2.1.0 torchvision==0.16.0 -c pytorch
python3 -m pip install -r requirements.txt
```
- start the app
```
python3 helio_app.py
```
- App is currently running at the following endpoint: http://34.72.202.95:8000/docs
- you can filter for certain actions, if you leave the labels empty, it will return all the actions it detects
- You can send a POST request with a video file to get responses for each 5 seconds of the video
- There is a mobile app which is connected to the endpoint and the relative code is in the mobile_app folder