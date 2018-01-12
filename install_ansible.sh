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

# Usage function for the script
function usage () {
  cat << DELIM__
usage: $(basename $0) [options]

Options:
  -h, --help            Display help menu
DELIM__
}

# read the options
TEMP=$(getopt -o h --long help -n 'installer.sh' -- "$@")
if [[ $? -ne 0 ]]; then
  usage
  exit 1
fi
eval set -- "$TEMP"

# extract options
while true ; do
  case "$1" in
    -h|--help)  usage ; exit 1 ;;
    --) shift ; break ;;
    *) usage ; exit 1 ;;
  esac
done

# Check Ubuntu
if [[ ! -f /etc/os-release  ]]; then
  log "${ERROR}Only Ubuntu platform is supported.${NORM}"
  exit 1
fi

# Install ansible
dpkg -l ansible &> /dev/null
if [[ $? -eq 0 ]]; then
  log "${INFO}Ansible is already installed.${NORM}"
else
  sudo apt-get install -y software-properties-common
  sudo apt-add-repository -y ppa:ansible/ansible
  sudo apt-get update -y
  sudo apt-get install -y ansible
  log "${GREEN}Ansible installed successfully.${NORM}"
fi
ansible --version

exit 0

