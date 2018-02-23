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

#Extract base dir for installer
working_dir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
base_dir=$(dirname "$working_dir")

# Color codes
ERROR='\033[1;31m'
GREEN='\033[0;32m'
TORQ='\033[0;96m'
HEAD='\033[44m'
INFO='\033[0;33m'
NORM='\033[0m'

function log() {
  echo -e "[$(basename $0)-$(date '+%H:%M:%S')] $@"
}

function tryexec() {
  "$@"
  retval=$?
  [[ $retval -eq 0 ]] && return 0

  log 'A command has failed:'
  log "  $@"
  log "Value returned: ${retval}"
  print_stack
  exit $retval
}

function print_stack() {
  local i
  local stack_size=${#FUNCNAME[@]}
  log "Stack trace (most recent call first):"
  # to avoid noise we start with 1, to skip the current function
  for (( i=1; i<$stack_size ; i++ )); do
    local func="${FUNCNAME[$i]}"
    [[ -z "$func" ]] && func='MAIN'
    local line="${BASH_LINENO[(( i - 1 ))]}"
    local src="${BASH_SOURCE[$i]}"
    [[ -z "$src" ]] && src='UNKNOWN'

    log "  $i: File '$src', line $line, function '$func'"
  done
}

function which_() { hash "$1" &>/dev/null; }

function package_exists() {
  local res=1
  if which_ dpkg; then
    dpkg -l $1 &> /dev/null; res=$?
  elif which_ rpm; then
    rpm -q $1 &> /dev/null; res=$?
  else
    log "${ERROR}package manager not found.${NORM}"
  fi
  return $res
}

function package_install() {
  local res=1
  if which_ apt-get; then
    sudo apt-get -y install "$1" 2>&1; res=$?
  elif which_ yum; then
    sudo yum -y install "$1" 2>&1; res=$?
  else
    log "${ERROR}Error: package manager not found.${NORM}"
  fi
  return $res
}

function install() {
  if ! package_exists ${1}; then
    package_install ${1}
    if [[ $? -ne 0 ]]; then
      log "${ERROR}Error occured while installing package [${1}]${NORM}"
      exit 1
    fi
    log "${GREEN}Installed: ${1}${NORM}\n"
  fi
  return 0
}

# Docker pre-reqs on debian
function install_debian() {
  tryexec wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker_engine.list
  tryexec sudo apt-get update
}

# Docker pre-reqs on rpm
function install_rpm() {
  tryexec install yum-utils
  tryexec install device-mapper-persistent-data
  tryexec install lvm2
  tryexec sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  tryexec sudo yum update -y
}

# Check OS
if [[ -f "/etc/os-release" ]]; then
    source /etc/os-release
    log "${INFO}Opertaing System: ${NAME}${NORM}"
    if [[ ${ID_LIKE} == "debian" ]]; then
      log "${INFO}OS Version: ${VERSION_CODENAME}${NORM}"
      install_debian
    else
      log "${INFO}OS Version: ${VERSION}${NORM}"
      install_rpm
    fi
    log "${INFO}All dependencies installed successfully.${NORM}"
fi

tryexec install docker-ce
tryexec sudo systemctl start docker
if [[ $? -ne 0 ]]; then
  log "${ERROR}Could not start docker.service${NORM}"
  exit 1
else
  log "${GREEN}Docker service in operation.${NORM}"
fi

log "${GREEN}Installation complete.${NORM}"



