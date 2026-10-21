#!/usr/bin/env bash
# Runs inside MSYS2 MINGW64, invoked by build-sm64coopdx-64p.bat.
# Mirrors the project's own CI recipe (.github/workflows/build-coop.yaml).
set -u
cd "$(dirname "$0")"

REPO_DIR="sm64coopdx-64p"
BRANCH="maxplayers-64"
URL="https://github.com/mobiusbagel/sm64coopdx.git"

echo "==> Updating MSYS2 and installing build packages (first run takes a while)..."
pacman -Syu --noconfirm || true
if ! pacman -S --needed --noconfirm unzip make git zip python3 \
    mingw-w64-x86_64-gcc mingw-w64-x86_64-glew mingw-w64-x86_64-SDL2; then
    echo ""
    echo "ERROR: package install failed. If MSYS2 just updated itself, simply run the .bat again."
    exit 1
fi

if [ -d "$REPO_DIR/.git" ]; then
    echo "==> Updating existing clone..."
    cd "$REPO_DIR" || exit 1
    git fetch origin || exit 1
    git checkout "$BRANCH" || exit 1
    git pull --ff-only || exit 1
else
    echo "==> Cloning the fork (branch $BRANCH, ~320 MB)..."
    git clone -b "$BRANCH" "$URL" "$REPO_DIR" || exit 1
    cd "$REPO_DIR" || exit 1
fi

if [ ! -f baserom.us.z64 ]; then
    echo ""
    echo "ERROR: baserom.us.z64 not found in:"
    echo "  $(pwd)"
    echo "Copy your US Super Mario 64 ROM dump into that folder, named baserom.us.z64,"
    echo "then run the .bat again."
    exit 2
fi

if [ "${1:-}" = "clean" ]; then
    echo "==> Cleaning previous build..."
    make clean >/dev/null 2>&1 || true
fi

echo "==> Building with make -j$(nproc) (first build takes several minutes)..."
make -j"$(nproc)"
RC=$?
if [ $RC -ne 0 ]; then
    echo ""
    echo "BUILD FAILED (make exit code $RC). Copy the errors above and send them to Baymax."
    exit $RC
fi

echo ""
echo "BUILD OK: build/us_pc/sm64coopdx.exe"
exit 0
