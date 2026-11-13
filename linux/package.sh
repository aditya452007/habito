#!/bin/bash
set -e

bundle=build/linux/x64/release/bundle
out=build/linux/package
tool=https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
runtime=https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64

rm -rf "$out"
mkdir -p "$out/Habito" "$out/AppDir/usr/bin"

cp -r "$bundle"/. "$out/Habito/"
tar -C "$out" -czf Habito-linux-x64.tar.gz Habito

cp -r "$bundle"/. "$out/AppDir/usr/bin/"
cp "$bundle/com.habito.app.desktop" "$bundle/com.habito.app.png" "$out/AppDir/"
ln -s com.habito.app.png "$out/AppDir/.DirIcon"
ln -s usr/bin/Habito "$out/AppDir/AppRun"

curl -fsSL -o "$out/appimagetool" "$tool"
curl -fsSL -o "$out/runtime" "$runtime"
chmod +x "$out/appimagetool"
ARCH=x86_64 "$out/appimagetool" --appimage-extract-and-run --runtime-file "$out/runtime" "$out/AppDir" Habito-x86_64.AppImage
