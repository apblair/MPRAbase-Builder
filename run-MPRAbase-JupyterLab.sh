#!/bin/bash 
# "${PWD}"
docker run -it --rm -p 10000:8888 -u root -v /Users/andrewblair/Desktop/Development:/home/jovyan/work apblair/mprabase:jupyterlab-dev-v0.1