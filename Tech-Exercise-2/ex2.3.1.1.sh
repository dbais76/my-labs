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

cd /projects
git clone https://github.com/rht-labs/pet-battle.git && cd pet-battle
git remote set-url origin https://${GIT_SERVER}/${TEAM_NAME}/pet-battle.git
git branch -M main
git push -u origin main


## Run above commands before setting the git webhook
##  Call the next set of steps after setting and testing the integration 
