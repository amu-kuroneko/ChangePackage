#!/bin/bash

readonly SOURCE_DIRECTORY='src'
readonly FIXED_CHANGE_FILES=( "AndroidManifest.xml" )

sourcePackage=
sourceDirectory=
sourceRegularExpression=
sourceDirectories=()
destinationPackage=
destinationDirectory=
destinationRegularExpression=

function usage(){
    echo ""
    echo "Usage: bash $0 <Source Package Name> <Destination Package Name>"
    echo "       This script is to change Package Name of Android."
    echo ""
    return
}

function initialize(){
    sourcePackage="$1"
    destinationPackage="$2"
    IFS='.'
    for _directory in ${sourcePackage}
    do
        if [ -z ${sourceDirectory} ]
        then
            sourceDirectory=${_directory}
            sourceRegularExpression=${_directory}
        else
            sourceDirectory=${sourceDirectory}'/'${_directory}
            sourceRegularExpression=${sourceRegularExpression}'\.'${_directory}
        fi
        sourceDirectories=( "${sourceDirectory}" "${sourceDirectories[@]}" )
    done
    for _directory in ${destinationPackage}
    do
        if [ -z ${destinationDirectory} ]
        then
            destinationDirectory=${_directory}
            destinationRegularExpression=${_directory}
        else
            destinationDirectory=${destinationDirectory}'/'${_directory}
            destinationRegularExpression=${destinationRegularExpression}'\.'${_directory}
        fi
    done
    IFS=' '
    if [ -d ${SOURCE_DIRECTORY}"/${sourceDirectory}" ]
    then
        return 1
    else
        echo "No such package directory in ${sourcePackage}"
        return 0
    fi
}

function change(){
    local _current=`pwd`
    cd ${SOURCE_DIRECTORY}
    if [ -n "${destinationDirectory}" ]
    then
        if [ ! -d "./${destinationDirectory}" ]
        then
            mkdir -p "./${destinationDirectory}"
        fi
    fi
    mv -f "./${sourceDirectory}/"* "./${destinationDirectory}"
    for _directory in ${sourceDirectories[@]}
    do
        if [ -z "$(ls -A "${_directory}")" ]
        then
            rmdir "${_directory}"
        else
            break
        fi
    done
    cd ${_current}
    return
}

function rewrite(){
    local _files=${FIXED_CHANGE_FILES[@]}
    while read _file
    do
        _files+=(${_file})
    done < <(find "${SOURCE_DIRECTORY}" -name *.java )
    sed -i '' -e "s/${sourceRegularExpression}/${destinationRegularExpression}/g" "${_files[@]}"
    return
}

if [ $# -lt 2 ]
then
    usage
else
    initialize "$1" "$2"
    if [ $? -ne 0 ]
    then
        change
        rewrite
    fi
fi
