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

cd /projects/pet-battle-api
mvn -ntp versions:set -DnewVersion=1.3.1

echo "Waiting to finish"
sleep 60

cd /projects/pet-battle-api
git add .
git commit -m  "🍕 UPDATED - pet-battle-version to 1.3.1 🍕"
git push 

echo "Check tekton pipeline, it should be running now "
