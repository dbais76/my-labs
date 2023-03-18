echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03



## Do these steps once you have created the Tech-exercise project  and Group glsteam

export GITLAB_USER=lab03
export GITLAB_PASSWORD=lab03
gitlab_pat
echo $GITLAB_PAT

echo $GITLAB_PAT > pat.txt
cat pat.txt

## pat saved in pat.txt file for future reference

cd /projects/tech-exercise
git remote set-url origin https://${GIT_SERVER}/${TEAM_NAME}/tech-exercise.git

cd /projects/tech-exercise
git add .
git commit -am "🐙 ADD - argocd values file 🐙"
git push -u origin --all

## Enter the pat displayed earlier

echo "Deploy Ubiquitous Journey"

yq eval -i '.team=env(TEAM_NAME)' /projects/tech-exercise/values.yaml
yq eval ".source = \"https://$GIT_SERVER/$TEAM_NAME/tech-exercise.git\"" -i /projects/tech-exercise/values.yaml

sed -i "s|TEAM_NAME|$TEAM_NAME|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
echo "the git token is displayed below"
echo "****"
cat pat.txt
echo "****"
cd /projects/tech-exercise/
git add .
git commit -m  "🦆 ADD - correct project names 🦆"
git push


cat <<EOF | oc apply -n ${TEAM_NAME}-ci-cd -f -
  apiVersion: v1
  data:
    password: "$(echo -n ${GITLAB_PAT} | base64 -w0)"
    username: "$(echo -n ${GITLAB_USER} | base64 -w0)"
  kind: Secret
  type: kubernetes.io/basic-auth
  metadata:
    annotations:
      tekton.dev/git-0: https://${GIT_SERVER}
      sealedsecrets.bitnami.com/managed: "true"
    labels:
      credential.sync.jenkins.openshift.io: "true"
    name: git-auth
EOF

cd /projects/tech-exercise
helm upgrade --install uj --namespace ${TEAM_NAME}-ci-cd .

sleep 20
oc get projects | grep ${TEAM_NAME}

echo "Getting the pods"
sleep 30
oc get pods -n ${TEAM_NAME}-ci-cd
