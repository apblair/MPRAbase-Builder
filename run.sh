#!/bin/bash 
docker run -it --rm -p 10000:8888 -v "${PWD}":/home/jovyan/work apblair/mprabase:dev-v0.1