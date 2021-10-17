#!/bin/bash

set -euo pipefail

python3 -m pip install --upgrade --user setuptools
python3 -m pip install --user "molecule[lint]"
