#! /bin/bash

echo "Start the cleaning process"

yaycache -d
yaycache -r

paccache -d
paccache -r

sudo pacman -Scc
yay -Sc


echo "Cleaning process completed"
echo "Now check your self big files in your system"
ncdu ~/
