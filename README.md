# Notes

## Start the Forge

./start.sh

## Stop the Forge

./stop.sh 

## Remove the Forge 
CAUTION: Will destroy all data

./remove.sh

# How to config

1. Grant Non-Interactive Users permission to createRepo in Gerrit.

2. Create repo
ssh jenkins@$GERRIT_IP -p 29418 gerrit create-project awesome-project.git --description "'Most better project'"

3. Clone repo
git clone ssh://jenkins@${GERRIT_IP}:29418/awesome-project; cd awesome-project

4. Configure repo
git config user.email "jenkins@domain.local"
git config user.name "Jenkins Server"
gitdir=$(git rev-parse --git-dir); scp -p -P 29418 jenkins@${GERRIT_IP}:hooks/commit-msg ${gitdir}/hooks/
chmod +x .git/hooks/commit-msg

5. Create review job in Jenkins

Jenkins -> New task -> Name: Gerrit-review -> Type: Pipeline

New pipeline configuration:

Build Triggers: Gerrit event

Gerrit Trigger:

- Choose a Server: Gerrit

**Advance**:

### Gerrit Reporting Values:

*Verify*
Started: 0
Successful: 1
Failed: -1
Unstable: -1
Not Built: 0

*Code Review*
Started: 0
Successful: 1
Failed: -1
Unstable: -1
Not Built: 0

### Custom Build Messages

Build Start Message	

```gerrit review <CHANGE>,<PATCHSET> --message '"Build Started <BUILDURL> <STARTED_STATS>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>```

Build Successful Message

```
gerrit review <CHANGE>,<PATCHSET> --message '"Build Successful <GERRIT_NAME>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>
```

Build Failure Message

```gerrit review <CHANGE>,<PATCHSET> --message '"Build Failure <GERRIT_NAME>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>```

Build Unstable Message

```gerrit review <CHANGE>,<PATCHSET> --message '"Build Unstable <GERRIT_NAME>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>```

Build Not Built Message	

```gerrit review <CHANGE>,<PATCHSET> --message '"Build not built <GERRIT_NAME>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>```

Trigger on: Patchset Created

**Gerrit Project**

*Type*: Plain
*Pattern*: Awesome-project

**Branches**

*Type*: Path
*Pattern*: **

## Pipeline

**Pipeline script**

```
node {
    stage ('Checkout') {
      checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: '$GERRIT_REFSPEC']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'jenkins-master', refspec: '+refs/changes/*:refs/changes/*', url: 'ssh://jenkins@10.0.91.72:29418/awesome-project']]]
    }
    stage ('Build') {
      docker.image('maven').inside('-v $HOME/.m2:/root/.m2') {
        sh 'mvn -DskipTests=true install compile package'
      }
    }
}
```

6. Push our code on the repo

```
git add ...
git commit -a -m MESSAGE
git push origin HEAD:refs/for/master
```

> At this point the job should has been triggered.

7. Create Jenkins merge job

Jenkins -> New task -> Name: Gerrit-review -> Type: Free style

## Source Code Management:

Git:

Repositories: 

**Repository URL**: ssh://jenkins@10.0.91.72:29418/awesome-project

**Credentials**: jenkins (Jenkins Master)

> under Advanced

**Refspec**: `+refs/heads/master:refs/remotes/origin/master`

**Branch Specifier (blank for 'any')**. `*/master`

## Build Triggers: 

Gerrit event

## Gerrit Trigger:

- Choose a Server: Gerrit

**Advance**:

### Gerrit Reporting Values:

*Verify*
Started: 0
Successful: 1
Failed: -1
Unstable: -1
Not Built: 0

*Code Review*
Started: 0
Successful: 1
Failed: -1
Unstable: -1
Not Built: 0

### Custom Build Messages

Build Start Message	

```gerrit review <CHANGE>,<PATCHSET> --message '"Build Started <BUILDURL> <STARTED_STATS>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>```

Build Successful Message

```
gerrit review <CHANGE>,<PATCHSET> --message '"Build Successful <GERRIT_NAME>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>
```

Build Failure Message

```gerrit review <CHANGE>,<PATCHSET> --message '"Build Failure <GERRIT_NAME>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>```

Build Unstable Message

```gerrit review <CHANGE>,<PATCHSET> --message '"Build Unstable <GERRIT_NAME>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>```

Build Not Built Message	

```gerrit review <CHANGE>,<PATCHSET> --message '"Build not built <GERRIT_NAME>"' --label "verified=<VERIFIED>" --code-review <CODE_REVIEW>```

**Trigger on**:

Change Merged

**Gerrit Project**

*Type*: Plain
*Pattern*: Awesome-project

**Branches**

*Type*: Path
*Pattern*: **

## Build

**Execute shell**

```
TARGET_FOLDER=/usr/share/apache
PROJECT_NAME=$(echo $GIT_URL | cut -d"/" -f4)

docker run --rm --volumes-from jenkins -w ${WORKSPACE} nordri/nordri-dev-tools mvn -DskipTests=true install compile package

mkdir -p $TARGET_FOLDER/$PROJECT_NAME
cp ./target/tema1_2-ejem1-0.0.1-SNAPSHOT.jar $TARGET_FOLDER/$PROJECT_NAME
```

8. Aprove changes in Gerrit. Go to Gerrit -> All -> Open and vote with +2 the changes, then submit the changes to master. This action will trigger the merge job.

9. Go to localhost to pick up the artifact(s).

# Issues

## Jenkins

- Jenkins came without Pipeline fully installed. Had to go to plugins and install pipeline.
- You must install and configure Jave8 and Maven:
	- Maven:
	  Jenkins -> Admin Jenkins -> Global Tool Configuration -> Maven
	  - Name: M3
	  - Install automatically
	  - Version 3.5.3
	- JDK8:
	  Jenkins -> Admin Jenkins -> Global Tool Configuration -> JDK
	  - Name: JDK8
	  - DO NOT install automatically
	  - JAVA_HOME: /usr/lib/jvm/java-8-openjdk-amd64

- Working with remote repo

export GERRIT_IP=10.0.91.72
git clone ssh://jenkins@${GERRIT_IP}:29418/awesome-project
cd awesome-project

git config user.email "jenkins@domain.local"
git config user.name "Jenkins Server"

GERRIT_IP=
gitdir=$(git rev-parse --git-dir); scp -p -P 29418 jenkins@${GERRIT_IP}:hooks/commit-msg ${gitdir}/hooks/
chmod +x .git/hooks/commit-msg

echo "This project is awesome" > README.md
git add README.md
git commit -m "First commit" README.md
git push origin HEAD:refs/for/master

>> Creating the repo from jenkins' command line interface:

1. createProject permission is needed

2. Launch the command from Jenkins Shell
$ ssh -i .ssh/id_rsa gerrit -p 29418 gerrit create-project awesome-project.git --description "'Most better project'"
From your laptop
GERRIT_IP=10.0.91.72
$ ssh jenkins@$GERRIT_IP -p 29418 gerrit create-project awesome-project.git --description "'Most better project'"

# Command to code-review
ssh -p 29418 jenkins@10.0.91.72 gerrit review 25d4f8c89bf452ed163bb5ef4bd8576d728a4998 --message "Build_started_nulljob/gerrit-maven/19/" --label "Verified=1" --code-review +1

3. 

## Custom

- You'll need the rsa key Jenkins generates when it's launched. Add it to the start.sh output or something.

## Docker

- We've generated Jenkins and Gerrit containers.
  
  - Jenkins because we need Pipeline plugin.
  - Gerrit because the bootstrap process tryed to reach /gerrit context but it's published under /

# Previous deployment (the old way)

This steps are deprecated and they're still here as a remaind.

## OpenLDAP

Dir: openldap-docker
command to run: ./createOpenLDAP.sh secret example.com admin passwd admin@example.com ci-network

jxplorer -> App to search in a LDAP tree
  - http://pegacat.com/jxplorer/downloads/users.html
  - Host: localhost
  - Level: User + Password
  - User DN: cn=admin,dc=example,dc=com
  - Password: secret
  
LDAP Self Service Password
./createOpenSSP.sh secret

## Gerrit

Dir: gerrit-docker
command: ./createGerrit.sh http://gerrit-urjc.es:8080 172.19.0.2:389 dc=example,dc=com 

## Jenkins

Dir: jenkins-docker
command: TIMEZONE="Europe/Madrid" ./createJenkins.sh 

## Archiva

