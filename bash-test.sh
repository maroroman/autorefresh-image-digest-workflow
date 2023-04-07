#!/bin/bash   
HASH=6f2d7df 
RELEASE=2023a
IMAGES=("odh-minimal-notebook-image-n" "odh-minimal-gpu-notebook-image-n" "odh-pytorch-gpu-notebook-image-n")
REGEXES=("v2-${RELEASE}-\d{8}+-${HASH}" "cuda-[a-z]+-minimal-[a-z0-9]+-[a-z]+-3.9-${RELEASE}-\d{8}-${HASH}" "v2-${RELEASE}-\d{8}-${HASH}")
            
              for ((i=0;i<${#IMAGES[@]};++i)); do
                image=${IMAGES[$i]}
                echo $image
                regex=${REGEXES[$i]}
                img=$(cat jupyterhub/notebook-images/overlays/additional/params.env | grep -E "${image}=" | cut -d '=' -f2)
                registry=$(echo $img | cut -d '@' -f1)
                latest_tag=$(skopeo inspect docker://$img | jq -r --arg regex "$regex" '.RepoTags | map(select(. | test($regex))) | .[0]')
                digest=$(skopeo inspect docker://$registry:$latest_tag | jq .Digest | tr -d '"')
                output=$registry@$digest
                echo $output
                sed -i "s|${image}=.*|${image}=$output|" jupyterhub/notebook-images/overlays/additional/params.env
              done
