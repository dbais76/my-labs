echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03
sleep 10
oc new-project ${TEAM_NAME}-ci-cd || true

echo "adding Helm repo"

helm repo add tl500 https://rht-labs.com/todolist/
helm search repo todolist
helm install my tl500/todolist --namespace ${TEAM_NAME}-ci-cd || true

sleep 20

echo https://$(oc get route/my-todolist -n ${TEAM_NAME}-ci-cd --template='{{.spec.host}}')
ROUTE=$(echo https://$(oc get route/my-todolist -n ${TEAM_NAME}-ci-cd --template='{{.spec.host}}'))

firefox $ROUTE

echo " End of exercise 1.1"


