#!/usr/bin/env bash
# Runs inside MSYS2 MINGW64, invoked by build-sm64coopdx-64p.bat.
# Mirrors the project's own CI recipe (.github/workflows/build-coop.yaml).
set -u
cd "$(dirname "$0")"

REPO_DIR="sm64coopdx-64p"
BRANCH="maxplayers-64"
URL="https://github.com/mobiusbagel/sm64coopdx.git"

echo "==> Step 1/4: MSYS2 signing keyring (fresh installs ship a stale one)..."
# Fresh MSYS2 installs ship a stale signing keyring; without this bootstrap,
# pacman stalls on a key-import prompt (e.g. the clangarm64 key) that a
# scripted shell cannot answer.
pacman-key --init || true
pacman-key --populate msys2 || true

echo "==> Step 2/4: refreshing package databases..."
# Deliberately NOT a full `pacman -Syu`: on fresh installs the core-runtime
# upgrade makes MSYS2 kill its own shell mid-script and wait for a restart,
# which hangs a scripted run. A database refresh is all a build needs.
pacman -Sy --noconfirm || true
pacman -S --noconfirm msys2-keyring || true
pacman -Sy --noconfirm || true

echo "==> Step 3/4: installing build packages..."
if ! pacman -S --needed --noconfirm unzip make git zip python3 \
    mingw-w64-x86_64-gcc mingw-w64-x86_64-glew mingw-w64-x86_64-SDL2; then
    echo ""
    echo "ERROR: package install failed. Re-run the .bat; if it fails again,"
    echo "screenshot the output above and send it to Baymax."
    exit 1
fi

echo "==> Step 4/4: source and build..."

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
