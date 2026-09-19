#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../.."

echo "=== Cargokit: Building Rust for iOS/Android ==="

if [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
    if echo "$ARCHS" | grep -q "x86_64"; then
        RUST_TARGET="x86_64-apple-ios"
    else
        RUST_TARGET="aarch64-apple-ios-sim"
    fi
    OUT_DIR="build/ios/Debug-iphonesimulator/rust_lib_tumiyomi"
    mkdir -p "$OUT_DIR"
    
    cargo build -p rust_lib_tumiyomi --target "$RUST_TARGET"
    cp "rust/target/$RUST_TARGET/debug/librust_lib_tumiyomi.a" "$OUT_DIR/librust_lib_tumiyomi.a"
elif [ "$PLATFORM_NAME" = "iphoneos" ]; then
    RUST_TARGET="aarch64-apple-ios"
    OUT_DIR="build/ios/Debug-iphoneos/rust_lib_tumiyomi"
    mkdir -p "$OUT_DIR"
    
    cargo build -p rust_lib_tumiyomi --target "$RUST_TARGET"
    cp "rust/target/$RUST_TARGET/debug/librust_lib_tumiyomi.a" "$OUT_DIR/librust_lib_tumiyomi.a"
else
    mkdir -p android/app/src/main/jniLibs/arm64-v8a
    mkdir -p build/rust_lib_tumiyomi/build/aarch64-linux-android/debug/
    cp rust/target/aarch64-linux-android/debug/librust_lib_tumiyomi.so android/app/src/main/jniLibs/arm64-v8a/ 2>/dev/null || true
    cp rust/target/aarch64-linux-android/debug/librust_lib_tumiyomi.so build/rust_lib_tumiyomi/build/aarch64-linux-android/debug/ 2>/dev/null || true
fi

echo "=== Build script finished successfully ==="
exit 0
