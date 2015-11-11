#!/usr/bin/env bash

#
# This script uses the Docker Tools Box (= new packaging of boot2docker) to start the docker daemon
# with these env variables : 
# DOCKER_CERT_PATH="/Users/chmoulli/.docker/machine/machines/default"
# DOCKER_HOST="tcp://$DOCKER_IP_PORT"
# DOCKER_MACHINE_NAME="default"
# DOCKER_TLS_VERIFY="1"
#
# You can change IP_ADDRESS and PORT NUMBER to access the docker daemaon as such
# ./scripts/daemon-image-published-gerrit.sh 192.168.99.100:2376
# 
# like also the local directory containing the gerrit-site created and mounted as volume
#
# ./scripts/daemon-image-published-gerrit.sh 192.168.99.100:2376 /home/temp/gerrit-site
#
PROJECT_DIR=`pwd`

GERRIT_TEMP_DIR=${2:-~/temp/gerrit-site} # Temp dir where we will mount the volume locally
KEYS_DIR=$PROJECT_DIR/ssh-keys
ADMIN_KEY=$PROJECT_DIR/ssh-admin-key

. ./scripts/set_docker_env.sh

docker stop gerrit
docker rm gerrit
rm -rf $GERRIT_TEMP_DIR

docker run -d -p 0.0.0.0:8080:8080 -p 0.0.0.0:29418:29418 \
 -e GERRIT_GIT_LOCALPATH='/home/gerrit/git' \
 -e GERRIT_GIT_PROJECT_CONFIG='/home/gerrit/configs/project.config' \
 -e GERRIT_GIT_REMOTEPATH='ssh://admin@localhost:29418/All-Projects' \
 -e GIT_SERVER_IP='gogs-service.default.local' \
 -e GIT_SERVER_PORT='80' \
 -e GIT_SERVER_USER='root'  \
 -e GIT_SERVER_PASSWORD='redhat01' \
 -e GIT_SERVER_PROJ_ROOT='root'  \
 -e GERRIT_ADMIN_USER='admin'  \
 -e GERRIT_ADMIN_EMAIL='admin@fabric8.io' \
 -e GERRIT_ADMIN_FULLNAME='Administrator' \
 -e GERRIT_ADMIN_PWD='mysecret' \
 -e GERRIT_ACCOUNTS='jenkins,jenkins,jenkins@fabric8.io,secret,Non-Interactive Users:Administrators;sonar,sonar,sonar@fabric8.io,secret,Non-Interactive Users' \
 -e GERRIT_SSH_PATH='/root/.ssh' \
 -e GERRIT_ADMIN_PRIVATE_KEY='/root/.ssh/id_rsa' \
 -e GERRIT_PUBLIC_KEYS_PATH='/home/gerrit/ssh-keys' \
 -e GERRIT_USER_PUBLIC_KEY_PREFIX='id-' \
 -e GERRIT_USER_PUBLIC_KEY_SUFFIX='-rsa.pub' \
 -e AUTH_TYPE='DEVELOPMENT_BECOME_ANY_ACCOUNT' \
 -v $ADMIN_KEY:/root/.ssh \
 -v $KEYS_DIR:/home/gerrit/ssh-keys \
 -v $GERRIT_TEMP_DIR:/home/gerrit/site \
 --name gerrit \
 fabric8/gerrit
 
docker exec -it gerrit bash

# -v $KEYS_DIR/id_rsa.pub:/root/.ssh/id_rsa.pub \