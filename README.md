# helio
Helio Video based AI Workout Journal App

## getting started
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