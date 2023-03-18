echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03



## Now performing steps for Extend UJ

cd /projects/tech-exercise
git remote set-url origin https://gitlab-ce.apps.ocp4.example.com/glsteam/tech-exercise.git
git pull

## get the git web hook for integration

echo https://$(oc get route argocd-server --template='{{ .spec.host }}'/api/webhook  -n ${TEAM_NAME}-ci-cd)

echo "Adding nexus to UJ"

if [[ $(yq e '.applications[] | select(.name=="nexus") | length' /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml) < 1 ]]; then
    yq e '.applications += {"name": "nexus","enabled": true,"source": "https://redhat-cop.github.io/helm-charts","chart_name": "sonatype-nexus","source_ref": "1.1.10","values":{"includeRHRepositories": false,"service": {"name": "nexus"}}}' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
fi

cat /projects/tech-exercise/pat.txt

cd /projects/tech-exercise
git add .
git commit -m  "🦘 ADD - nexus repo manager 🦘"
git push 


echo "showing the pods in team ci-cd project"
sleep 30
oc get pod  -n glsteam-ci-cd| grep nexus
sleep 30
echo "waiting for Nexus to be deployed"

echo https://$(oc get route nexus --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)

echo "Access the nexus console if all pods are running and healthy"


