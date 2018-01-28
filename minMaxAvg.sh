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

# Calculates Min, Max and Avg values from a single column file(s)

files=create_container.txt,create_files.txt,create_tarball.txt,exec_code.txt,put_tarball.txt,start_container.txt

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
usage: $(basename $0) [options] [parameter]

Options:
  -f, --file            Comma separated list of single column files
                        containing interger/float values

  -h, --help            Display help menu
DELIM__
}

function check_files() {
  files=$(echo ${1} | tr ',' ' ')
  files=(${files})
  for file in ${files[*]}; do
    if ! [[ -f ${file} ]]; then
      log "${ERROR}File [${file}] not found.${NORM}"
      exit 1
    fi
  done
}

# read the options
TEMP=$(getopt -o f:h --long file:,help -n 'minMaxAvg.sh' -- "$@")
if [[ $? -ne 0 ]]; then
  usage
  exit 1
fi
eval set -- "$TEMP"

# extract options
while true ; do
  case "$1" in
    -h|--help)  usage ; exit 1 ;;
    -f|--file)  files=$2 ; shift 2 ;;
    --) shift ; break ;;
    *) usage ; exit 1 ;;
  esac
done
check_files ${files}

# Install ansible
dpkg -l bc &> /dev/null
if [[ $? -ne 0 ]]; then
  sudo apt-get install -y bc
  log "${INFO}Installed dependency bc.${NORM}"
fi

# Calculate
echo -e "${INFO}\t\tFile(s)\t\tMin\tMax\tAvg${NORM}"
for file in ${files[*]}; do
  N=$(cat ${file} | wc -l)
  max=$(grep -E '[0-9]+' ${file} | sort  -rn | head -n 1)
  max=`printf "%.3f" ${max}`
  min=$(grep -E '[0-9]+' ${file} | sort  -rn | tail -n 1)
  min=`printf "%.3f" ${min}`
  avg=0
  while read -r line
  do
    avg=`echo ${avg} + ${line} | bc`
  done < ${file}
  avg=`echo "scale=3; ${avg}/${N}" | bc`
  printf "%25s\t%s\t%s\t%s\n" ${file} ${min} ${max} ${avg}
done

exit 0
