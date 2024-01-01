#!/bin/bash

find . -type f -name 'update-deps.sh' -print0 | xargs -0 -I {} bash {}
