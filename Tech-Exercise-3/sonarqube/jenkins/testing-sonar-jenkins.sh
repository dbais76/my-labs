## Sonarqube is a tool that performs static code analysis. It looks for pitfalls in coding and reports them. It’s great tool for catching vulnerabilities!
#################################################################################################


echo export TEAM_NAME="glsteam" | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN="apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER="gitlab-ce.apps.ocp4.example.com" | tee -a ~/.bashrc -a ~/.zshrc

source ~/.zshrc
echo ${TEAM_NAME}
echo ${CLUSTER_DOMAIN}
echo ${GIT_SERVER}


oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u lab03 -p lab03

cd /projects/pet-battle
cat << EOF > sonar-project.js
const scanner = require('sonarqube-scanner');

scanner(
  {
    serverUrl: 'http://sonarqube-sonarqube:9000',
    options: {
      'sonar.login': process.env.SONARQUBE_USERNAME,
      'sonar.password': process.env.SONARQUBE_PASSWORD,
      'sonar.projectName': 'Pet Battle',
      'sonar.projectDescription': 'Pet Battle UI',
      'sonar.sources': 'src',
      'sonar.tests': 'src',
      'sonar.inclusions': '**', // Entry point of your code
      'sonar.test.inclusions': 'src/**/*.spec.js,src/**/*.spec.ts,src/**/*.spec.jsx,src/**/*.test.js,src/**/*.test.jsx',
      'sonar.exclusions': '**/node_modules/**',
      //'sonar.test.exclusions': 'src/app/core/*.spec.ts',
      // 'sonar.javascript.lcov.reportPaths': 'reports/lcov.info',
      // 'sonar.testExecutionReportPaths': 'coverage/test-reporter.xml'
    }
  },
  () => process.exit()
);
EOF

### REPLACE jenkinsfile content with jenkinsfile.sonar file content
### FOLLOW NEXT STEP TO PUSH

cd /projects/pet-battle
git add Jenkinsfile sonar-project.js
git commit -m "🧦 test code-analysis step 🧦"
git push
