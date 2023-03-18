echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03



## This is GitOps
cd /projects/tech-exercise
git remote set-url origin https://${GIT_SERVER}/${TEAM_NAME}/tech-exercise.git
git pull

if [[ $(yq e '.applications.[].values.deployment.env_vars[] | select(.name=="BISCUITS") | length' /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml) < 1 ]]; then
    yq e '.applications.[1].values.deployment.env_vars += {"name": "BISCUITS", "value": "jaffa-cakes"}' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
fi

cat /projects/tech-exercise/pat.txt

echo "git token displayed above"

cd /projects/tech-exercise
git add .
git commit -m  "🍪 ADD - Jenkins environment variable 🍪"
git push 

sleep 10

echo "checking if variable added to deployment successfully"

oc describe dc/jenkins -n glsteam-ci-cd | grep BISCUITS


