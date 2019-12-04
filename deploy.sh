#!/bin/bash

#export $(cat .env | xargs)
#./terraform apply -var-file ./variables.tfvars -auto-approve

./terraform output -json > output.json
cd ./ansible
jinja2 ./ssh.cfg.tmpl ./../output.json --format=json > ssh.cfg
ansible-playbook -i ./hosts ./docker_ubuntu.yaml
