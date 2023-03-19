## we’ll deploy Allure - a useful tool for managing your java tests and other reports from your CI/CD server.
#################################################################################################


echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03

#### Testing with tekton
### 

cat << EOF > /tmp/allure-auth.yaml
apiVersion: v1
data:
  password: "$(echo -n password | base64 -w0)"
  username: "$(echo -n admin | base64 -w0)"
kind: Secret
metadata:
  name: allure-auth
EOF

kubeseal < /tmp/allure-auth.yaml > /tmp/sealed-allure-auth.yaml -n ${TEAM_NAME}-ci-cd --controller-namespace tl500-shared --controller-name sealed-secrets -o yaml

cat /tmp/sealed-allure-auth.yaml| grep -E 'username|password'


##### REPLACE value-toolings-allure.yaml to value-toolings.yaml and then follow next steps to push to Git

### REPLACE THE CORRECT USERNAME AND PASSWORD TO VALUE-TOOLINGS.YAML FROM PREVIOUS OUTPUT



cd /projects/tech-exercise
git add ubiquitous-journey/values-tooling.yaml
git commit -m  "👩‍🏭 ADD - Allure tooling 👩‍🏭"
git push 

echo https://$(oc get route allure --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)/allure-docker-service/projects/default/reports/latest/index.html


cd /projects/tech-exercise
cat <<'EOF' > tekton/templates/tasks/allure-post-report.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: allure-post-report
  labels:
    app.kubernetes.io/version: "0.2"
spec:
  description: >-
    This task used for uploading test reports to allure
  workspaces:
    - name: output
  params:
    - name: APPLICATION_NAME
      type: string
      default: ""
    - name: IMAGE
      description: the image to use to upload results
      type: string
      default: "quay.io/openshift/origin-cli:4.9"
    - name: WORK_DIRECTORY
      description: Directory to start build in (handle multiple branches)
      type: string
    - name: ALLURE_HOST
      description: "Allure Host"
      default: "http://allure:5050"
    - name: ALLURE_SECRET
      type: string
      description: Secret containing Allure credentials
      default: allure-auth
  steps:
    - name: save-tests
      image: $(params.IMAGE)
      workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
      env:
        - name: ALLURE_USERNAME
          valueFrom:
            secretKeyRef:
              name: $(params.ALLURE_SECRET)
              key: username
        - name: ALLURE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: $(params.ALLURE_SECRET)
              key: password
      script: |
        #!/bin/bash
        curl -sLo send_results.sh https://raw.githubusercontent.com/eformat/allure/main/scripts/send_results.sh && chmod 755 send_results.sh
        ./send_results.sh $(params.APPLICATION_NAME) \
          $(workspaces.output.path)/$(params.WORK_DIRECTORY) \
          ${ALLURE_USERNAME} \
          ${ALLURE_PASSWORD} \
          $(params.ALLURE_HOST)
EOF



#### REPLACE maven-pipeline-save-results.yaml to maven-pipeline.yaml and follow next steps


cd /projects/tech-exercise
git add .
git commit -m  "🥽 ADD - save-test-results step 🥽"
git push 

cd /projects/pet-battle-api
git commit --allow-empty -m "🧦 test save-test-results step 🧦"
git push




