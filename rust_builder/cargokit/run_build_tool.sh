#!/usr/bin/env bash
set -e
echo "=== Cargokit fully bypassed: Using prebuilt binary ==="

cd /home/debian/tumiyomi

# 必要な出力先ディレクトリをすべて作成
mkdir -p android/app/src/main/jniLibs/arm64-v8a
mkdir -p build/rust_lib_tumiyomi/build/aarch64-linux-android/debug/

# 手動ビルドした .so を Cargokit が期待するすべての場所に確実に配置
cp rust/target/aarch64-linux-android/debug/librust_lib_tumiyomi.so android/app/src/main/jniLibs/arm64-v8a/
cp rust/target/aarch64-linux-android/debug/librust_lib_tumiyomi.so build/rust_lib_tumiyomi/build/aarch64-linux-android/debug/ 2>/dev/null || true

echo "=== .so successfully injected. Skipping cargo build. ==="
exit 0
