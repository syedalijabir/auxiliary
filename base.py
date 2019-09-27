#!/usr/bin/env python
# vim: set syntax=python:
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

import argparse
import os
import pdb
import sys
import logging
import platform
import time
from optparse import OptionParser

dir_path = os.path.dirname(os.path.realpath(__file__))
base_path = os.path.split(os.path.split(dir_path)[0])[0]

log_file = dir_path + "/python.log"

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.FileHandler(log_file, mode='a')
handler.setLevel(logging.INFO)
logger.addHandler(handler)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)

class col:
    HEADER = '\033[95m'
    if (platform.system() != "Linux"):
        BLUE = '\033[36m'
    else:
        BLUE = '\033[94m'
    GREEN = '\033[92m'
    INFO = '\033[93m'
    ERROR = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class BadNoneValue(Exception):
    """Raise an error if an argument is None"""
    def __init__(self, argument):
        self.argument = argument

    def __str__(self):
        return 'argument {}: can not be None'.format(self.argument)

def argument_parser():
    parser = argparse.ArgumentParser(
        description='Base python script')
    parser.add_argument(
        '-a1', '--arg1',
        default = "",
        help='First argument')
    parser.add_argument(
        '-q', '--quiet',
        action="store_true",
        help='Do not log on console')
    return parser

def validate_parameters(namespace, parser):
    if namespace.arg1 is None:
        parser.print_usage()
        raise BadNoneValue('-a1/--arg1')
    return

def parse_parameters(arguments):
    parser = argument_parser()
    namespace = parser.parse_args(arguments)
    validate_parameters(namespace, parser)
        
def isAccessible(path, mode="r"):
    """
    Check if the file/directory at 'path' is accessible
    """
    try:
        file = open(path, mode)
        file.close()
    except OSError as e:
        logger.error(e)
        return False
    except IOError as e:
        logger.error(e)
        return False
    return True

def get_file_handler(fileName):
    if isAccessible(fileName):
        try:
            fileHandler = open(fileName, 'r')
            return fileHandler
        except IOError as err:
            logger.error('I/O error({0}): {1}'.format(err.errno, err.strerror))
            return None
        except:
            logger.error("Unexpected error:", sys.exc_info()[0])
            return None

def main(cli_arguments):

    # Parse parameters
    parameters = parse_parameters(cli_arguments)

    if parameters["quiet"] is False:
        consoleHandler = logging.StreamHandler()
        consoleHandler.setFormatter(formatter)
        logger.addHandler(consoleHandler)
    
    # Start your code here
    logger.info("Starting main function")
    print(col.INFO + "hello world!" + col.END)

if __name__ == '__main__':
    try:
        sys.exit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        logger.error('Interrupted by keyboard')
    except BadNoneValue as e:
        logger.error("{}: error: {}".format(sys.argv[0], e))

