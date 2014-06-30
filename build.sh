DEBUGOPTS64="-lib -m64 -debug -property -g -gs -gx -c -lib -version=DX11_1 -I../.. -of../lib/libaurora_immediate64d.lib"
RELOPTS64="-lib -m64 -O -release -property -inline -c -lib -version=DX11_1 -I../.. -of../lib/libaurora_immediate64.lib"
DEBUGOPTS32="-lib -m32 -debug -property -g -gs -gx -c -lib -version=DX11_1 -I../.. -of../lib/libaurora_immediate32d.lib"
RELOPTS32="-lib -m32 -O -release -property -inline -c -lib -version=DX11_1 -I../.. -of../lib/libaurora_immediate32.lib"
SRCFILES="types.d input.d entry.d window.d application.d package.d"

printf "Building the Aurora Immediate x64 (Release) library ... "
dmd $SRCFILES $RELOPTS64
printf "Complete\n\r"

printf "Building the Aurora Immediate x86 (Release) library ... "
dmd $SRCFILES $RELOPTS32
printf "Complete\n\r"

printf "Building the Aurora Immediate x64 (Debug) library ... "
dmd $SRCFILES $DEBUGOPTS64
printf "Complete\n\r"

printf "Building the Aurora Immediate x86 (Debug) library ... "
dmd $SRCFILES $DEBUGOPTS32
printf "Complete\n\r"