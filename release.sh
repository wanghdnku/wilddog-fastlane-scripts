#!/bin/bash


# env_file=$ARGUMENTS['env']
# version=$ARGUMENTS['version']

version="$1"
envfile=".env.$2"



echo "$version"
echo "$envfile"

file="./fastlane/$envfile"
if [ -f "$file" ] 
then
	echo "$file found."
else
	echo "$file not found."
fi
