echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03



## Deploying Jenkins pipeline - Pet Battle
## follow the steps for git integration before follwing next steps



##Update UJ

yq e '(.applications[] | (select(.name=="jenkins").values.deployment.env_vars[] | select(.name=="GITLAB_HOST")).value)|=env(GIT_SERVER)' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
yq e '(.applications[] | (select(.name=="jenkins").values.deployment.env_vars[] | select(.name=="GITLAB_GROUP_NAME")).value)|=env(TEAM_NAME)' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml

yq e '.applications.pet-battle.source |="http://nexus:8081/repository/helm-charts"' -i /projects/tech-exercise/pet-battle/test/values.yaml

yq e '.applications.pet-battle.source |="http://nexus:8081/repository/helm-charts"' -i /projects/tech-exercise/pet-battle/stage/values.yaml

cd /projects/tech-exercise
git add .
git commit -m  "🍕 ADD - jenkins pipelines config 🍕"
git push

sleep 20

## Check on Jenkins if Pet battle pipeline is available

wget -O /projects/pet-battle/Jenkinsfile https://raw.githubusercontent.com/rht-labs/tech-exercise/main/tests/doc-regression-test-files/3a-jenkins-Jenkinsfile.groovy

cd /projects/pet-battle
git add Jenkinsfile
git commit -m "🌸 Jenkinsfile updated with build stage 🌸"
git push


echo "Now move to jenkins console and check the pipeline. It should be running"
sleep 10


