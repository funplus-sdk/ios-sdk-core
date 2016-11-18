#!/usr/bin/env bash

# go to project root.
if [[ $(pwd) == *Scripts ]]; then
    cd ..
fi

ver=$(grep "VERSION = " Source/FunPlusSDK.swift | sed "s/\"//g" | sed "s/public static let VERSION = //g" | tr -d ' ')
framework=FunPlusSDK.framework

src=Release/funplus-ios-sdk-$ver/$framework
target_dir=../../unity/sdk-core/Assets/FunPlusSDK/Plugins/iOS

if [ -d $target_dir/FunPlusSDK.framework ]; then
    rm -rf $target_dir/FunPlusSDK.framework*
fi

dst=$target_dir/$framework

cp -R $src $dst

echo Copied $src to $dst
