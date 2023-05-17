#!/bin/bash   
COMMIT_HASH=a06f80a 
RELEASE_N=2023a

    IMAGES=("odh-minimal-notebook-image-n" "odh-minimal-gpu-notebook-image-n" "odh-pytorch-gpu-notebook-image-n" "odh-generic-data-science-notebook-image-n" "odh-tensorflow-gpu-notebook-image-n" "odh-trustyai-notebook-image-n")
    REGEXES=("v2-$RELEASE_N-\d{8}+-$COMMIT_HASH" "cuda-[a-z]+-minimal-[a-z0-9]+-[a-z]+-3.9-$RELEASE_N-\d{8}-$COMMIT_HASH" "v2-$RELEASE_N-\d{8}+-$COMMIT_HASH" "v2-$RELEASE_N-\d{8}+-$COMMIT_HASH" "cuda-[a-z]+-tensorflow-[a-z0-9]+-[a-z]+-3.9-$RELEASE_N-\d{8}-$COMMIT_HASH" "v1-$RELEASE_N-\d{8}+-$COMMIT_HASH")
    for ((i=0;i<${#IMAGES[@]};++i)); do
        image=${IMAGES[$i]}
        echo $image
        regex=${REGEXES[$i]}
	    echo $regex
        pullspec_1=$(cat clusterserviceversion.yml.j2 | grep "$image" -m 1 -A 1) 
        pullspec=$(echo $pullspec_1 | cut -d ' ' -f5 | tr -d '"')
        echo "OLD: $pullspec"
        registry=$(echo $pullspec | cut -d '@' -f1)                                                                                                                    
        latest_tag=$(skopeo inspect docker://$pullspec | jq -r --arg regex "$regex" '.RepoTags | map(select(. | test($regex))) | .[0]')
        echo $latest_tag
        digest=$(skopeo inspect docker://$registry:$latest_tag | jq .Digest | tr -d '"')                                                                                
        static_pullspec=$registry@$digest  
        echo "NEW: $static_pullspec"
        static_pullspec="\"$static_pullspec\""
        pullspec="\"$pullspec\""
        sed -i "s|image: $pullspec|image: $static_pullspec|g" clusterserviceversion.yml.j2
    done

