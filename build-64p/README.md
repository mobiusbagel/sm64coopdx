# SM64CoopDX — 64-Player Build Guide

One-click builder for the `maxplayers-64` branch of your fork
(mobiusbagel/sm64coopdx) — Super Mario 64 Coop DX with the player cap
raised from 16 to 64.

## Files

- `build-sm64coopdx-64p.bat` — the builder. Double-click it.
- `build-inside.sh` — the script the .bat runs inside MSYS2. Keep it in
  the same folder as the .bat; don't run it directly.

## What the builder does

1. Finds MSYS2 (C:\msys64, D:\, E:\, or your user folder). If it's
   missing, it tries to install it with winget; failing that, it points
   you to https://www.msys2.org/ — install with the default folder,
   then run the .bat again.
2. Updates MSYS2 and installs exactly the packages the project's own
   CI uses: make, git, python3, unzip, zip, mingw-w64-x86_64-gcc,
   mingw-w64-x86_64-glew, mingw-w64-x86_64-SDL2.
3. Clones your fork's `maxplayers-64` branch into `sm64coopdx-64p\`
   next to the .bat (or pulls the latest if it's already there).
4. Builds with `make -j` (all cores). Output:
   `sm64coopdx-64p\build\us_pc\sm64coopdx.exe`

## The one manual step: the ROM

The build extracts game assets from a ROM, which can't be downloaded
for you. You need **baserom.us.z64** (a US Super Mario 64 dump) in the
`sm64coopdx-64p\` folder. Either:

- drop `baserom.us.z64` next to the .bat before running it — the
  builder copies it in for you, or
- the builder will stop and tell you the exact folder; copy it there
  and run the .bat again.

## Good to know

- **First run is slow** (MSYS2 setup + package downloads + full
  compile). Re-runs are incremental and quick, and pull the latest
  branch changes first.
- **If the first run stops during MSYS2's self-update**, just run the
  .bat again — that's normal MSYS2 behavior. (A stall at a PGP key
  import prompt on very fresh MSYS2 installs is handled automatically:
  the script bootstraps the signing keyring before updating.)
- **Clean rebuild:** run `build-sm64coopdx-64p.bat clean` from a
  command prompt in this folder.
- **If the build fails**, copy the error text and send it to Baymax.

## Playing with more than 16

CoopNet lobbies cap at 16 players, so big games need direct socket
hosting:

1. Host menu → **Network System: Socket**, set **Amount of Players**
   (up to 64), note the port (default **7777**), host.
2. For internet play, forward **UDP 7777** on your router to the
   hosting PC — or play over a virtual LAN (Tailscale/ZeroTier), or a
   real LAN, where no forwarding is needed.
3. Everyone else: Join → **Direct**, enter the host's IP and port.

The host's connection and PC carry the whole lobby — expect a full
64-player pile-up in one area to be the stress case, not the norm.
