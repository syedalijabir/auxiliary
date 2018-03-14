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

# Usage function for the script
function usage () {
  cat << DELIM__
usage: $(basename $0) [options] [parameter]

Options:
  -h, --help            Display help menu
DELIM__
}

# read the options
TEMP=$(getopt -o h --long help -n 'base.sh' -- "$@")
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

log "${GREEN}Success.${NORM}"
exit 0

