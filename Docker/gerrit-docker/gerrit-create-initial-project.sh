#!/bin/bash -x
set -e

echo "#####################################"
echo "### GERRIT CREATE INITIAL PROJECT ###"
echo "#####################################"

# Usage
usage() {
    echo "Usage:"
    echo "    ${0} -A <username> -P <password> -p <initial_project_name> -d <initial_project_description> -g <initial_group> -e <git_email>"
    exit 1
}

while getopts "A:P:p:d:g:e:" opt; do
  case $opt in
    A)
      username=${OPTARG}
      ;;
    P)
      password=${OPTARG}
      ;;
    p)
      initial_project_name=${OPTARG}
      ;;
    d)
      initial_project_description="${OPTARG}"
      ;;
    g)
      initial_group="${OPTARG}"
      ;;
    e)
      git_email=${OPTARG}
      ;;
    *)
      echo "Invalid parameter(s) or option(s)."
      usage
      ;;
  esac
done

if [ -z "${username}" ] || [ -z "${password}" ] || [ -z "${initial_project_name}" ] || [ -z "${initial_project_description}" ] || [ -z "${initial_group}" ]; then
    echo "Parameters missing"
    usage
fi

# Generate Gerrit admin rsa key
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""

# Load the key
ssh_key=$(cat ~/.ssh/id_rsa.pub)
ret=$(curl --request POST --user ${username}:${password} --data "${ssh_key}" --output /dev/null --silent --write-out '%{http_code}' http://localhost:8080/a/accounts/admin/sshkeys)
if [[ ${ret} -eq 201 ]]; then
  echo "Public-key was uploaded"
else
  echo "Public-key was uploaded with the invalid response code: ${ret}"
fi

# Create the project
ssh admin@localhost -p 29418 -o "StrictHostKeyChecking no" gerrit create-project ${initial_project_name}.git --description "'${initial_project_description}'"
if [ "$?" == "0" ]; then
	echo "Project ${initial_project_name} created"
else
	echo "Project creation failed"
fi

# Adjusting permissions (READ and PUSH)

GROUP_UUID=$(curl --silent --user "${username}:${password}" "http://localhost:8080/a/groups/${initial_group}" | grep id | awk -F"\"" '{ print $4 }' | tail -n 1)

eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa

mkdir ~/git
git init ~/git 
cd ~/git

git config user.name  $username
git config user.email $git_email
git remote add origin ssh://$username@localhost:29418/${initial_project_name}

git fetch -q origin refs/meta/config:refs/remotes/origin/meta/config
git checkout meta/config

TAB="$(printf '\t')"
cat >groups<<EOF
# UUID${TAB}Group Name
#
${GROUP_UUID}${TAB}${initial_group}
EOF

git add groups 

git config -f project.config --add access.refs/heads/*.read "group ${initial_group}"
git config -f project.config --add access.refs/heads/*.push "group ${initial_group}"

git commit -a -m "Adjusting permissions"
git push origin meta/config:meta/config

# rm -rf ~/git