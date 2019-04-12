#!/bin/bash
#
# Owner: Ali Jabir
# Email: syedalijabir@gmail.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Color codes
ERROR='\033[1;31m'
GREEN='\033[0;32m'
TORQ='\033[0;96m'
HEAD='\033[44m'
INFO='\033[0;33m'
NORM='\033[0m'

function log() {
  echo -e "[$(basename $0)] $@"
}

function check_dir() {
  if [[ ! -d ${1} ]]; then
    log "${ERROR}Directory [ ${1} ] does not exit.${NORM}"
    exit 1
  fi
}

# Usage function for the script
function usage () {
  cat << DELIM__

usage: $(basename $0) [options] [parameter]
Options:
  -i, --image             container image name
  -m, --mount_dir         mount directory to be mounted to /opt/ directory of container

DELIM__
}

# read the options
TEMP=$(getopt -o i:d:h --long image:,mount_dir:,help -n $(basename $0) -- "$@")
if [[ $? -ne 0 ]]; then
  usage
  exit 1
fi
eval set -- "$TEMP"

# extract options
while true ; do
  case "$1" in
    -i|--image) image=${2}; shift 2 ;;
    -d|--mount_dir) mount_dir=${2}; check_dir ${mount_dir}; shift 2 ;;
    -h|--help)  usage ; exit 1 ;;
    --) shift ; break ;;
    *) usage ; exit 1 ;;
  esac
done
image=${image:-}
if [[ -z ${image} ]]; then
  log "${ERROR}Must specify docker image${NORM}"
  usage
  exit 1
fi
mount_dir=${mount_dir:-}

# delete <none> named images
log "${INFO}Deleting stale docker images${NORM}"
for i in `docker images | grep \<none\> | awk '{print$3}'`; do
  docker rmi -f $i
done

# stop already running container
if [[ -n ${image} ]]; then
  id=$(docker ps | grep "${image}" | awk '{print$1}')
  if [[ -n ${id} ]]; then
    docker kill ${id}
  fi
fi

# delete old images
latest_tag=$(docker images | grep "${image}" | awk '{print $2}' | sort | head -n 1)
while [[ `docker images | grep "${image}" | wc -l` -ne 1 ]]; do
  tag=$(docker images | grep "${image}" | awk '{print$2}' | head -n 1)
  id=$(docker images | grep "${image}" | awk '{print$3}' | head -n 1)
  if [[ ${tag} -ne ${latest_tag} ]]; then
    docker rmi -f ${id}
  fi
done

# run latest container
mount_opt=""
if [[ -n ${mount_dir} ]]; then
  mount_opt="-v ${mount_dir}:/opt/"
fi
docker run ${mount_opt} -itd ${image}:${latest_tag} bash

# copy over aws and ssh credentials
container_id=$(docker ps | grep "${image}:${latest_tag}" | awk '{print$1}')
if [[ -d "~/.aws" ]]; then
  docker cp ~/.aws ${container_id}:/root/
fi

if [[ -d "~/.ssh" ]]; then
docker cp ~/.ssh ${container_id}:/root/
fi

log "${GREEN}Done.{NORM}"
exit 0

