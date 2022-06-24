pipeline {
    agent {
        dockerfile {
            dir '.devcontainer'
        }
    }
    stages {
        stage('arm-build') {
            steps {
                sh 'jenkins/build-release.sh'
                archiveArtifacts(artifacts: 'build/*.zip')
            }
        }
        stage('test') {
            steps {
                sh 'jenkins/build-test.sh'
                sh 'jenkins/test.sh'
                junit 'build/app-test.xml'
                publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'build/test/app-coverage',
                    reportFiles: 'index.html',
                    reportName: "Test Coverage"
                ])
            }
        }
    }
}
