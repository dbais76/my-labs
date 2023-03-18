echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03



## Sealed Secrets

### echo "Sealed Secrets allows us to seal Kubernetes secrets by using a utility called kubeseal. ###The SealedSecrets are Kubernetes resources that contain encrypted Secret object that only the ### controller can decrypt. Therefore, a SealedSecret is safe to store even in a public repository."

cd /projects/tech-exercise
git remote set-url origin https://${GIT_SERVER}/${TEAM_NAME}/tech-exercise.git
git pull

echo ${GITLAB_USER}
echo ${GITLAB_PAT}

echo "generating sealed secret resource using kubeseal"

cat << EOF > /tmp/git-auth.yaml
kind: Secret
apiVersion: v1
data:
  username: "$(echo -n ${GITLAB_USER} | base64 -w0)"
  password: "$(echo -n ${GITLAB_PAT} | base64 -w0)"
type: kubernetes.io/basic-auth
metadata:
  annotations:
    tekton.dev/git-0: https://${GIT_SERVER}
    sealedsecrets.bitnami.com/managed: "true"
  labels:
    credential.sync.jenkins.openshift.io: "true"
  name: git-auth
EOF

oc whoami

kubeseal < /tmp/git-auth.yaml > /tmp/sealed-git-auth.yaml -n ${TEAM_NAME}-ci-cd --controller-namespace tl500-shared --controller-name sealed-secrets -o yaml
echo "Displayig the sealed secret resource"


cat /tmp/sealed-git-auth.yaml 
sleep 15

cat /tmp/sealed-git-auth.yaml | grep -E 'username|password'

echo "****************"
echo "Updating the UJ"
echo "****************"

sleep 10

if [[ $(yq e '.applications[] | select(.name=="sealed-secrets") | length' /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml) < 1 ]]; then
    yq e '.applications += {"name": "sealed-secrets","enabled": true,"source": "https://redhat-cop.github.io/helm-charts","chart_name": "helper-sealed-secrets","source_ref": "1.0.3","values": {"secrets": [{"name": "git-auth","type": "kubernetes.io/basic-auth","annotations": {"tekton.dev/git-0": "https://GIT_SERVER","sealedsecrets.bitnami.com/managed": "true"},"labels": {"credential.sync.jenkins.openshift.io": "true"},"data": {"username": "SEALED_SECRET_USERNAME","password": "SEALED_SECRET_PASSWORD"}}]}}' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
    SEALED_SECRET_USERNAME=$(yq e '.spec.encryptedData.username' /tmp/sealed-git-auth.yaml)
    SEALED_SECRET_PASSWORD=$(yq e '.spec.encryptedData.password' /tmp/sealed-git-auth.yaml)
    sed -i "s|GIT_SERVER|$GIT_SERVER|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
    sed -i "s|SEALED_SECRET_USERNAME|$SEALED_SECRET_USERNAME|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
    sed -i "s|SEALED_SECRET_PASSWORD|$SEALED_SECRET_PASSWORD|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
fi

echo ${GITLAB_PAT}

cd /projects/tech-exercise
git add ubiquitous-journey/values-tooling.yaml
git commit -m "🕵🏻‍♂️ Sealed secret of Git user creds is added 🔎"
git push




