## Deploying Tekton pipeline

## FOLLOW THE STEPS TO CREATE A PROJECT pet-battle-api
## Then proceed to next steps
#################################################################################################


echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03

cd /projects
git clone https://github.com/rht-labs/pet-battle-api.git && cd pet-battle-api
git remote set-url origin https://${GIT_SERVER}/${TEAM_NAME}/pet-battle-api.git
git branch -M main
git push -u origin main


if [[ $(yq e '.applications[] | select(.name=="tekton-pipeline") | length' /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml) < 1 ]]; then
    yq e '.applications += {"name": "tekton-pipeline","enabled": true,"source": "https://GIT_SERVER/TEAM_NAME/tech-exercise.git","source_ref": "main","source_path": "tekton","values": {"team": "TEAM_NAME","cluster_domain": "CLUSTER_DOMAIN","git_server": "GIT_SERVER"}}' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
    sed -i "s|GIT_SERVER|$GIT_SERVER|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
    sed -i "s|TEAM_NAME|$TEAM_NAME|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml    
    sed -i "s|CLUSTER_DOMAIN|$CLUSTER_DOMAIN|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml    
fi

yq e '.applications.pet-battle-api.source |="http://nexus:8081/repository/helm-charts"' -i /projects/tech-exercise/pet-battle/test/values.yaml

git pull --rebase

cd /projects/tech-exercise
git add .
git commit -m  "🍕 ADD - tekton pipelines config 🍕"
git push 


#### get the webhook for integration

sleep 30

echo https://$(oc -n ${TEAM_NAME}-ci-cd get route webhook --template='{{ .spec.host }}')


