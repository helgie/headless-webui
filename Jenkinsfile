node {
  deleteDir() // Clean the directory
  stage('Fetch repos') {
    git '${PipelineURL}'
    sh 'git clone ${RepoURL} ./tests'
  }
  stage('Build image') {
    docker.build "helgie/headless-webui", "--build-arg LATESTSELENIUM=https://goo.gl/Lyo36k --build-arg LATESTCHROMEDRIVER=https://chromedriver.storage.googleapis.com/2.25/chromedriver_linux64.zip ."
  }
  stage('TEST') {
    try {
      sh 'docker run --rm -e "TEST=${TestFileName} ${pytestParams}" -w /tests --volume "${PWD}/tests:/tests" --volume "${PWD}/Screenshots:/tests/Screenshots" -t helgie/headless-webui'
        }
    finally {
      archiveArtifacts allowEmptyArchive: true, artifacts: 'Screenshots/*, tests/mailbox', caseSensitive: false
            }
    }
}
