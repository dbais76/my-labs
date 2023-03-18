echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03



## Deploying App of Apps - Deploying Pet Battle - Keycloak
sleep 10

yq e '(.applications[] | (select(.name=="test-app-of-pb").enabled)) |=true' -i /projects/tech-exercise/values.yaml
yq e '(.applications[] | (select(.name=="staging-app-of-pb").enabled)) |=true' -i /projects/tech-exercise/values.yaml

if [[ $(yq e '.applications[] | select(.name=="keycloak") | length' /projects/tech-exercise/pet-battle/test/values.yaml) < 1 ]]; then
    yq e '.applications.keycloak = {"name": "keycloak","enabled": true,"source": "https://github.com/petbattle/pet-battle-infra","source_ref": "labs1.0.1","source_path": "keycloak","values": {"app_domain": "CLUSTER_DOMAIN"}}' -i /projects/tech-exercise/pet-battle/test/values.yaml
    sed -i "s|CLUSTER_DOMAIN|$CLUSTER_DOMAIN|" /projects/tech-exercise/pet-battle/test/values.yaml
fi

echo "Git token displayed"
cat /projects/tech-exercise/pat.txt
sleep 10

cd /projects/tech-exercise
git add .
git commit -m  "🐰 ADD - app-of-apps and keycloak to test 🐰"
git push 

cd /projects/tech-exercise
helm upgrade --install uj --namespace ${TEAM_NAME}-ci-cd .

echo "Deploying Pet Battle now"
sleep 10

if [[ $(yq e '.applications[] | select(.name=="pet-battle-api") | length' /projects/tech-exercise/pet-battle/test/values.yaml) < 1 ]]; then
    yq e '.applications.pet-battle-api = {"name": "pet-battle-api","enabled": true,"source": "https://petbattle.github.io/helm-charts","chart_name": "pet-battle-api","source_ref": "1.2.1","values": {"image_name": "pet-battle-api","image_version": "latest", "hpa": {"enabled": false}}}' -i /projects/tech-exercise/pet-battle/test/values.yaml
fi
if [[ $(yq e '.applications[] | select(.name=="pet-battle") | length' /projects/tech-exercise/pet-battle/test/values.yaml) < 1 ]]; then
    yq e '.applications.pet-battle = {"name": "pet-battle","enabled": true,"source": "https://petbattle.github.io/helm-charts","chart_name": "pet-battle","source_ref": "1.0.6","values": {"image_version": "latest"}}' -i /projects/tech-exercise/pet-battle/test/values.yaml
fi
sed -i '/^$/d' /projects/tech-exercise/pet-battle/test/values.yaml
sed -i '/^# Keycloak/d' /projects/tech-exercise/pet-battle/test/values.yaml
sed -i '/^# Pet Battle Apps/d' /projects/tech-exercise/pet-battle/test/values.yaml

export JSON="'"'{
        "catsUrl": "https://pet-battle-api-'${TEAM_NAME}'-test.'${CLUSTER_DOMAIN}'",
        "tournamentsUrl": "https://pet-battle-tournament-'${TEAM_NAME}'-test.'${CLUSTER_DOMAIN}'",
        "matomoUrl": "https://matomo-'${TEAM_NAME}'-ci-cd.'${CLUSTER_DOMAIN}'/",
        "keycloak": {
          "url": "https://keycloak-'${TEAM_NAME}'-test.'${CLUSTER_DOMAIN}'/auth/",
          "realm": "pbrealm",
          "clientId": "pbclient",
          "redirectUri": "http://localhost:4200/tournament",
          "enableLogging": true
        }
      }'"'"
yq e '.applications.pet-battle.values.config_map = env(JSON) | .applications.pet-battle.values.config_map style="single"' -i /projects/tech-exercise/pet-battle/test/values.yaml


export JSON="'"'{
        "catsUrl": "https://pet-battle-api-'${TEAM_NAME}'-stage.'${CLUSTER_DOMAIN}'",
        "tournamentsUrl": "https://pet-battle-tournament-'${TEAM_NAME}'-stage.'${CLUSTER_DOMAIN}'",
        "matomoUrl": "https://matomo-'${TEAM_NAME}'-ci-cd.'${CLUSTER_DOMAIN}'/",
        "keycloak": {
          "url": "https://keycloak-'${TEAM_NAME}'-stage.'${CLUSTER_DOMAIN}'/auth/",
          "realm": "pbrealm",
          "clientId": "pbclient",
          "redirectUri": "http://localhost:4200/tournament",
          "enableLogging": true
        }
      }'"'"
yq e '.applications.pet-battle.values.config_map = env(JSON) | .applications.pet-battle.values.config_map style="single"' -i /projects/tech-exercise/pet-battle/stage/values.yaml

cd /projects/tech-exercise
git add .
git commit -m  "🐩 ADD - pet battle apps 🐩"
git push 



