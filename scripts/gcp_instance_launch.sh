#!/bin/bash
gcloud compute instances create \
    helio-dev-01 \
    --project=helio-435322 \
    --zone=us-central1-a \
    --machine-type=n1-standard-16 \
    --network-interface=address=34.122.80.57,network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=healio-dev \
    --can-ip-forward \
    --maintenance-policy=TERMINATE \
    --provisioning-model=STANDARD \
    --service-account=602186142866-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --accelerator=count=1,type=nvidia-tesla-t4 \
    --tags=http-server,https-server,lb-health-check \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-20240929-160342,image=projects/ml-images/global/images/c2-deeplearning-pytorch-2-3-cu121-v20240922-debian-11-py310,mode=rw,size=512,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any