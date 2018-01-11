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

# Pre-req: Git must be installed.

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
  -r, --repo            Repository to be cloned
  -f, --file            File containing additional checkout/cherry-pick commands
  -o, --out             Output tar ball name
  -e, --erase           Erase git data
  -h, --help            Display help menu
DELIM__
}

# read the options
TEMP=$(getopt -o r:f:o:eh --long repo:,file:,out:,erase,help -n 'installer.sh' -- "$@")
if [[ $? -ne 0 ]]; then
  usage
  exit 1
fi
eval set -- "$TEMP"

# extract options
while true ; do
  case "$1" in
    -r|--repo)  repo=$2 ; shift 2 ;;
    -o|--out)   tar_name=$2 ; shift 2 ;;
    -e|--erase) erase=true ; shift 1 ;;
    -h|--help)  usage ; exit 1 ;;
    --) shift ; break ;;
    *) usage ; exit 1 ;;
  esac
done

file=${file:-}
repo=${repo:-}
erase=${erase:-false}
tar_name=${tar_name:-"auto_tar"}.tar

if [[ -z ${repo} ]]; then
  log "${ERROR}Repository is not provided.${NORM}"
  usage
  exit 1
fi

res=$(git ls-remote --exit-code -h "${repo}")
if [[ $? -ne 0 ]]; then
  log "${ERROR}Repository [${repo}] does not exist.${NORM}"
  exit 1
fi
dir=$(echo ${repo##*/} | tr '.' ' ' | awk '{print $1}')
rm -rf ${dir}
rm -f ${tar_name}

log "${INFO}Found repo: [${repo}]${NORM}"
git clone ${repo}

pushd ${dir} > /dev/null

if [[ -n ${file} ]]; then
  while read -r line
  do
    echo ${line}
    ret=$(eval ${line}) > /dev/null
    if [[ ${ret} -ne 0 ]]; then
      log "${ERROR}Command failed:\n[${line}].${NORM}"
    fi
  done < ${file}
fi

if [[ ${erase} == "true" ]]; then
  rm -rf .git
  rm -f project.config
fi

popd > /dev/null

tar -cvf ${tar_name} ${dir} > /dev/null

log "${GREEN}Successfully created tarball: [${tar_name}]${NORM}"
exit 0

