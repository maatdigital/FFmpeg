#!/bin/bash

installDir=/usr/local/MAAT/lib/drm2
tmp32=MAAT/tmp32
tmp64=MAAT/tmp64

function handleError {
  if [[ "$?" != "0" ]]; then
    printf "\a"
    read -p "errors detected. Pausing... Enter any key to continue "
  fi
}

mkdir $installDir

pushd ..

# 32 bit
rm -rf $tmp32
mkdir $tmp32; handleError
echo "building 32 bit..."
make clean;
./configure --shlibdir=$installDir --disable-static --enable-shared --disable-all --enable-avcodec --enable-encoder=aac --enable-decoder=aac --cc='gcc -m32'; handleError
make; handleError
make install; handleError
cp $installDir/libavcodec.58.6.102.dylib $tmp32/libavcodec.58.dylib; handleError
cp $installDir/libavutil.56.5.100.dylib $tmp32/libavutil.56.dylib; handleError
rm -f $installDir/*.dylib; handleError

# # 64 bit
echo "building 64 bit..."
rm -rf $tmp64
mkdir $tmp64; handleError
make clean;
./configure --shlibdir=$installDir --disable-static --enable-shared --disable-all --enable-avcodec --enable-encoder=aac --enable-decoder=aac; handleError
make; handleError
make install; handleError
cp $installDir/libavcodec.58.6.102.dylib $tmp64/libavcodec.58.dylib; handleError
cp $installDir/libavutil.56.5.100.dylib $tmp64/libavutil.56.dylib; handleError
rm -f $installDir/*.dylib; handleError

# create fat binaries
sudo lipo -create $tmp32/libavcodec.58.dylib $tmp64/libavcodec.58.dylib -output $installDir/libavcodec.58.dylib; handleError
sudo lipo -create $tmp32/libavutil.56.dylib $tmp64/libavutil.56.dylib -output $installDir/libavutil.56.dylib; handleError

rm -rf $/tmp32; handleError
rm -rf $/tmp64; handleError

echo "done!"

popd
