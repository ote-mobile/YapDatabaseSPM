#!/bin/sh

set -e

readonly XCODEBUILD_RELEASEOPTIONS="-project YapDatabase.xcodeproj -target YapDatabase-iOS -configuration Release BITCODE_GENERATION_MODE=bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
readonly XCODEBUILD_DEBUGOPTIONS="-project YapDatabase.xcodeproj -target YapDatabase-iOS -configuration Debug BITCODE_GENERATION_MODE=bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES"

function clean () {
	rm -rf build
    rm -rf export
}

function buildAll () {
	build
	buildD
}

function createDirs () {
	mkdir -p export
}

function build () {
    createDirs

	xcodebuild -sdk iphoneos $XCODEBUILD_RELEASEOPTIONS
	xcodebuild -sdk iphonesimulator $XCODEBUILD_RELEASEOPTIONS
 
 	rm -f build.log
}

function XCFramework() {
    createXCFramework "Release-iphoneos" "Release-iphonesimulator"
}

function generateFrameworksCommand() {
    FRAMEWORK_NAME=$1
    CONFIGURATION_PLATFORM_DIR=$2

    FRAMEWORK=$CONFIGURATION_PLATFORM_DIR/$FRAMEWORK_NAME.framework
    FRAMEWORK_DSYM=$CONFIGURATION_PLATFORM_DIR/$FRAMEWORK_NAME.framework.dSYM
    SYMBOL_MAP_FILE=`find $CONFIGURATION_PLATFORM_DIR -name "*.bcsymbolmap"`

    COMMAND="-framework $FRAMEWORK -debug-symbols $FRAMEWORK_DSYM"
    if [[ ! -z "${SYMBOL_MAP_FILE}" ]]
    then
        read -a SYMBOL_MAP_FILE_ARRAY <<< "$SYMBOL_MAP_FILE"
        for SYMBOL_MAP in "${SYMBOL_MAP_FILE_ARRAY[@]}"
        do
            COMMAND="$COMMAND -debug-symbols $SYMBOL_MAP"
        done
    fi
    echo $COMMAND
}

function createXCFramework() {
    CURRENT_DIR=$(pwd)
    FRAMEWORK_NAME=YapDatabaseSPM
    CONFIGURATION_PLATFORM_1_DIR="$CURRENT_DIR/build/${1}"
    CONFIGURATION_PLATFORM_2_DIR="$CURRENT_DIR/build/${2}"

    FRAMEWORK_OUTPUT=export/iOS/$FRAMEWORK_NAME.xcframework
    
    COMMAND="xcodebuild -create-xcframework -output $FRAMEWORK_OUTPUT"

    COMMAND="$COMMAND `generateFrameworksCommand $FRAMEWORK_NAME $CONFIGURATION_PLATFORM_1_DIR`"
    COMMAND="$COMMAND `generateFrameworksCommand $FRAMEWORK_NAME $CONFIGURATION_PLATFORM_2_DIR`"
    
    echo "Creating xcframework..."
    echo $COMMAND
    eval $COMMAND
    echo "XCFramework created"
} 

clean
build
XCFramework 
