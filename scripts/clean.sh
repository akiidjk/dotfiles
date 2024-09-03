#! /bin/bash

echo "Start the cleaning process"

yaycache -d
yaycache -r

paccache -d
paccache -r

sudo pacman -Scc
yay -Sc


echo "Cleaning docker"
docker-start
sudo docker system prune -a
docker-stop

echo "Cleaning process completed"
echo "Now check your self big files in your system"
sudo ncdu /
