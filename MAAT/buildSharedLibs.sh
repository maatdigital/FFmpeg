#!/bin/bash

endUserInstallDir=/usr/local/MAAT/lib/drm2
buildInstallDir=MAAT/builds
tmp32=MAAT/tmp32
tmp64=MAAT/tmp64
minOSXTargetVersion=-mmacosx-version-min=10.8

function handleError {
  if [[ "$?" != "0" ]]; then
    printf "\a"
    read -p "errors detected. Pausing... Enter any key to continue "
  fi
}

rm -rf $buildInstallDir
mkdir -p $endUserInstallDir

pushd ..

# 32 bit
rm -rf $tmp32
mkdir $tmp32; handleError
echo "building 32 bit..."
make clean;
./configure --shlibdir=$endUserInstallDir \
--disable-static --enable-shared --disable-all --enable-avcodec \
--enable-encoder=aac --enable-decoder=aac \
--extra-cflags=$minOSXTargetVersion --extra-cxxflags=$minOSXTargetVersion --extra-objcflags=$minOSXTargetVersion --extra-ldflags=$minOSXTargetVersion \
--cc='gcc -m32'; handleError
make; handleError
make install; handleError
cp $endUserInstallDir/libavcodec.58.6.102.dylib $tmp32/libavcodec.58.dylib; handleError
cp $endUserInstallDir/libavutil.56.5.100.dylib $tmp32/libavutil.56.dylib; handleError
rm -f $endUserInstallDir/*.dylib; handleError

# # 64 bit
echo "building 64 bit..."
rm -rf $tmp64
mkdir $tmp64; handleError
make clean;
./configure --shlibdir=$endUserInstallDir \
--disable-static --enable-shared --disable-all --enable-avcodec \
--enable-encoder=aac --enable-decoder=aac \
--extra-cflags=$minOSXTargetVersion --extra-cxxflags=$minOSXTargetVersion --extra-objcflags=$minOSXTargetVersion --extra-ldflags=$minOSXTargetVersion \
; handleError
make; handleError
make install; handleError
cp $endUserInstallDir/libavcodec.58.6.102.dylib $tmp64/libavcodec.58.dylib; handleError
cp $endUserInstallDir/libavutil.56.5.100.dylib $tmp64/libavutil.56.dylib; handleError
rm -f $endUserInstallDir/*.dylib; handleError

function fattenAndMove {
	libName="${1}.dylib"
	echo "fattening $libName"
	lipo -create $tmp32/$libName $tmp64/$libName -output $endUserInstallDir/$libName; handleError	
	mv $endUserInstallDir/$libName $buildInstallDir/$libName; handleError
}

read -p "p"

mkdir -p $buildInstallDir

# create fat binaries
fattenAndMove libavcodec.58
fattenAndMove libavutil.56

rm -rf $tmp32; handleError
rm -rf $tmp64; handleError
rm -rf $endUserInstallDir; handleError

echo "done! Libs built at $buildInstallDir"

popd
