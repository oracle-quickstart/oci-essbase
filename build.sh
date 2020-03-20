#!/bin/bash

cd $(dirname $0)
SCRIPT_DIR=$(pwd)

echo "Cleaning build folder"
rm -rf $SCRIPT_DIR/build
mkdir -p $SCRIPT_DIR/build

echo "Creating BYOL stack"
folder=$(mktemp -d "essbase-XXXXX")

mkdir -p $folder
cd $folder
cp -R $SCRIPT_DIR/terraform/* .
rm -rf .terraform
rm -rf essbase-ucm*
for file in *.disabled; do mv $file ${file//.disabled/}; done
ls -la
zip -r $SCRIPT_DIR/build/essbase-stack-byol.zip *
cd $SCRIPT_DIR
rm -rf $folder

echo "Creating UCM stack"
folder=$(mktemp -d "essbase-XXXXX")

mkdir -p $folder
cd $folder
cp -R $SCRIPT_DIR/terraform/* .
rm -rf .terraform
rm -rf essbase-byol*
for file in *.disabled; do mv $file ${file//.disabled/}; done
ls -la
zip -r $SCRIPT_DIR/build/essbase-stack-ucm.zip *
cd $SCRIPT_DIR
rm -rf $folder

ls -la $SCRIPT_DIR/build
