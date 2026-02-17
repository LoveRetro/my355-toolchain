#!/bin/bash

set -euo pipefail

# Container Sanity Check Script
# Validates that critical libraries and headers are present in the toolchain

SYSROOT=${SYSROOT:-/opt/aarch64-nextui-linux-gnu/aarch64-nextui-linux-gnu/libc}
FAILED=0

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track failed checks for final exit code
failed_checks=()

# Helper function to check for file existence
check_file() {
    local path=$1
    local description=$2
    
    if [ -f "$path" ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description (missing: $path)"
        failed_checks+=("$description")
        return 1
    fi
}

# Helper function to check for directory existence
check_dir() {
    local path=$1
    local description=$2
    
    if [ -d "$path" ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description (missing: $path)"
        failed_checks+=("$description")
        return 1
    fi
}

echo "====================================="
echo "Container Sanity Check"
echo "====================================="
echo "SYSROOT: $SYSROOT"
echo ""

# === Core Infrastructure ===
echo -e "${YELLOW}[Core Infrastructure]${NC}"
check_dir "$SYSROOT" "Sysroot directory exists"
check_dir "$SYSROOT/usr/lib" "Standard library directory"
check_dir "$SYSROOT/usr/include" "Standard include directory"
echo ""

# === Compression Libraries ===
echo -e "${YELLOW}[Compression Libraries]${NC}"
check_file "$SYSROOT/usr/lib/libzip.so" "libzip - ZIP archive library"
check_file "$SYSROOT/usr/include/zip.h" "libzip headers"
check_file "$SYSROOT/usr/lib/libbz2.so" "libbz2 - Bzip2 compression library"
check_file "$SYSROOT/usr/include/bzlib.h" "libbz2 headers"
check_file "$SYSROOT/usr/lib/liblz4.so" "liblz4 - LZ4 compression library"
check_file "$SYSROOT/usr/include/lz4.h" "liblz4 headers"
echo ""

# === Audio Libraries ===
echo -e "${YELLOW}[Audio Libraries]${NC}"
check_file "$SYSROOT/usr/lib/libsamplerate.so" "libsamplerate - Audio resampling"
check_file "$SYSROOT/usr/include/samplerate.h" "libsamplerate headers"
check_file "$SYSROOT/usr/lib/libtinyalsa.so" "libtinyalsa - ALSA audio library"
check_file "$SYSROOT/usr/include/tinyalsa/asoundlib.h" "libtinyalsa headers"
echo ""

# === Graphics/GPU Libraries ===
echo -e "${YELLOW}[Graphics Libraries]${NC}"
check_file "$SYSROOT/usr/lib/libdrm.so" "libdrm - Direct Rendering Manager"
check_file "$SYSROOT/usr/lib/libEGL.so" "libEGL - EGL library"
check_file "$SYSROOT/usr/lib/libGLESv2.so" "libGLESv2 - OpenGL ES 2.0"
check_file "$SYSROOT/usr/include/EGL/egl.h" "EGL headers"
check_file "$SYSROOT/usr/include/GLES2/gl2.h" "OpenGL ES 2.0 headers"
echo ""

# === System Libraries ===
echo -e "${YELLOW}[System Libraries]${NC}"
check_file "$SYSROOT/usr/lib/libdbus-1.so" "libdbus - IPC library"
check_file "$SYSROOT/usr/include/dbus-1.0/dbus/dbus.h" "libdbus headers"
check_file "$SYSROOT/usr/lib/libudev.so" "libudev - Device enumeration library"
echo ""

# === Application Libraries ===
echo -e "${YELLOW}[Application Libraries]${NC}"
check_file "$SYSROOT/usr/lib/libSDL2-2.0.so" "SDL2 - Simple DirectMedia Layer"
check_file "$SYSROOT/usr/include/SDL2/SDL.h" "SDL2 headers"
check_file "$SYSROOT/usr/lib/libsqlite3.so" "sqlite3 - SQL database"
check_file "$SYSROOT/usr/include/sqlite3.h" "sqlite3 headers"
echo ""

# === Filesystem Tools ===
echo -e "${YELLOW}[Filesystem Tools]${NC}"
check_file "$SYSROOT/usr/bin/mksquashfs" "mksquashfs - SquashFS creation tool"
check_file "$SYSROOT/usr/bin/unsquashfs" "unsquashfs - SquashFS extraction tool"
echo ""

# === Summary ===
echo "====================================="
if [ ${#failed_checks[@]} -eq 0 ]; then
    echo -e "${GREEN}All sanity checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Sanity check failed with ${#failed_checks[@]} error(s):${NC}"
    printf '%s\n' "${failed_checks[@]}" | sed 's/^/  - /'
    exit 1
fi
