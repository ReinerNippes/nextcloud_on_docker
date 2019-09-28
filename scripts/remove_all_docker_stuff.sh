#!/bin/bash

docker kill $(docker ps -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls | awk '{print $2}' | grep -v "ID" |  grep -v ingress | grep -v bridge | grep -v host | grep -v none)

