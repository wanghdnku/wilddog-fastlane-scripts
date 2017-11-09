#!/bin/bash

set -e # Exit sub shell if anything erro
set -o pipefail
DIR="$(cd "$(dirname "$0")"; pwd)"
VERSION_STRING=$1
OUTPUT_DIR="${DIR}/Build"
XCODE_WORKSPACE="${DIR}/../WilddogMock.xcworkspace"
XCODEBUILD=xcodebuild

echo "===> Cleaning target directory"
rm -rf $OUTPUT_DIR

echo "===> Building iOS binary"
${XCODEBUILD} \
-workspace ${XCODE_WORKSPACE} \
-scheme WilddogMock \
-configuration Release \
-sdk iphoneos \
BUILD_DIR=${OUTPUT_DIR}/Products \
OBJROOT=${OUTPUT_DIR}/Intermediates \
BUILD_ROOT=${OUTPUT_DIR}/Build \
SYMROOT=${OUTPUT_DIR}/Symbol \
ONLY_ACTIVE_ARCH=NO \
ARCHS="armv7 arm64" \
build | xcpretty

echo "===> Building simulator binary"
${XCODEBUILD} \
-workspace ${XCODE_WORKSPACE} \
-scheme WilddogMock \
-configuration Release \
-sdk iphonesimulator \
BUILD_DIR=${OUTPUT_DIR}/Products \
OBJROOT=${OUTPUT_DIR}/Intermediates \
BUILD_ROOT=${OUTPUT_DIR}/Build \
SYMROOT=${OUTPUT_DIR}/Symbol \
ONLY_ACTIVE_ARCH=NO \
ARCHS="x86_64" \
build | xcpretty

echo "===> Using simulator binary as base project for headers and directory structure"
cp -a ${OUTPUT_DIR}/Products/Release-iphonesimulator ${OUTPUT_DIR}/Products/Release-combined

echo -n "===> Combining all binaries into one ..."
lipo \
-create \
${OUTPUT_DIR}/Products/Release-iphoneos/WilddogMock.framework/WilddogMock \
${OUTPUT_DIR}/Products/Release-iphonesimulator/WilddogMock.framework/WilddogMock \
-output ${OUTPUT_DIR}/Products/Release-combined/WilddogMock.framework/WilddogMock
echo " done."

echo -n "===> Checking binary architecture count ..."
EXPECTEDCOUNT=4
ARCHCOUNT=$(file ${OUTPUT_DIR}/Products/Release-combined/WilddogMock.framework/WilddogMock | wc -l)
if [[ $ARCHCOUNT -ne $EXPECTEDCOUNT ]]; then
  echo " bad."
  file ${OUTPUT_DIR}/Products/Release-combined/WilddogMock.framework/WilddogMock
  echo "===> The architecture count ($ARCHCOUNT) looks wrong. It should be $EXPECTEDCOUNT.";
  exit 1
fi

echo "===> Creating zip of final Combining framework"
pushd ${OUTPUT_DIR}/Products/Release-combined
zip -ry ../../WilddogMock-${VERSION_STRING}.zip WilddogMock.framework
popd

echo "===> Creating zip of iphoneos framework"
pushd ${OUTPUT_DIR}/Products/Release-iphoneos
zip -ry ../../WilddogMock-${VERSION_STRING}-os.zip WilddogMock.framework
popd
open ${OUTPUT_DIR}
