# URJC Forge

## Introduction

This repo is intended to set up a full configured CI forge to work with CI Pipelines.

It's based on [OpenFrontier](https://github.com/openfrontier/) work.

## How to use this repo

Just clone it:

```
clone https://github.com/codeurjc/codeurjc-forge 
cd codeurjc-forge
```

and run 

`./start.sh`

## Commands

# Start the Forge from scratch

`./start.sh`

# Stop the Forge

`./stop.sh`

# Start again the containers after stopped

`./resume.sh`

# Remove the Forge 

**CAUTION: Will destroy all data**

`./remove.sh`

# How to config the environment

In order to configure credentials, repos and other environment things you must edit `config.rc` file.

The config is divided in blocks.

# Description

This repo is intended to help developers who don't want to spend time struggling with system administration.

When the forge is up, you can use the default user *developer* to login and start working.

There is also a default project *awesome-project* ready to accept commits.

# How to config CI

1. Generate a SSH RSA Key

`ssh-keygen -t rsa -f developer.key -q -P ""`

load the key

`ssh-add developer.key`

2. Upload the key to Gerrit Server. Login as user Developer, go to *settings* and paste *developer.key.pub*' content.

3. Clone repo

`git clone ssh://developer@localhost:29418/awesome-project && cd awesome-project`

4. Configure repo

```
git config user.email "dev@example.com"
git config user.name "gerrit developer"
gitdir=$(git rev-parse --git-dir); scp -p -P 29418 developer@localhost:hooks/commit-msg ${gitdir}/hooks/
chmod +x .git/hooks/commit-msg
```

5. Create review job in Jenkins

Jenkins -> New task -> Name: Gerrit-review -> Type: Pipeline

New pipeline configuration:

**Build Triggers**: Gerrit event

### Gerrit Trigger:

**Choose a Server**: Gerrit

**Trigger on**: Patchset Created

**Gerrit Project**

*Type*: Plain

*Pattern*: Awesome-project

**Branches**

*Type*: Path

*Pattern*: **

### Pipeline

**Pipeline script**

```
node {
    stage ('Checkout') {
      checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: '$GERRIT_REFSPEC']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'jenkins-master', refspec: '+refs/changes/*:refs/changes/*', url: 'ssh://jenkins@gerrit:29418/awesome-project']]]
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

Jenkins -> New task -> Name: Gerrit-merge -> Type: Free style

### Source Code Management:

Git:

Repositories: 

**Repository URL**: ssh://jenkins@gerrit:29418/awesome-project

**Credentials**: jenkins (Jenkins Master)

> under Advanced

**Refspec**: `+refs/heads/master:refs/remotes/origin/master`

**Branch Specifier (blank for 'any')**. `*/master`

### Build Triggers: 

Gerrit event

### Gerrit Trigger:

**Choose a Server**: Gerrit

**Trigger on**: Change Merged

**Gerrit Project**

*Type*: Plain

*Pattern*: Awesome-project

**Branches**

*Type*: Path

*Pattern*: **

### Build

**Execute shell**

```
TARGET_FOLDER=/usr/share/apache
PROJECT_NAME=$(echo $GIT_URL | cut -d"/" -f4)

docker run --rm --volumes-from jenkins -w ${WORKSPACE} maven mvn -DskipTests=true install compile package

mkdir -p $TARGET_FOLDER/$PROJECT_NAME
cp ./target/tema1_2-ejem1-0.0.1-SNAPSHOT.jar $TARGET_FOLDER/$PROJECT_NAME
```

8. Aprove changes in Gerrit. Go to Gerrit -> All -> Open and vote with +2 the changes, then submit the changes to master. This action will trigger the merge job.

9. Go to localhost to pick up the artifact(s).

## Creating a new user in LDAP

We provided **phpLDAPAdmin** and **Self Service Password**. The first one is for LDAP administration and the second one is for the user to change their password by theirselves.

## Refs

https://hub.docker.com/u/openfrontier/
https://github.com/openfrontier
https://medium.com/@sanjogkumardash/code-review-with-continuous-integration-setup-gerrit-jenkins-on-ubuntu-14-04-amazon-36286f594bf5
https://gerrit-review.googlesource.com/Documentation/intro-gerrit-walkthrough.html#_making_the_change
https://github.com/osixia/docker-phpLDAPadmin