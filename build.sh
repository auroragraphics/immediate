DEBUGOPTS64="-lib -m64 -debug -property -g -gs -gx -c -lib -version=DX11_1 -I../.. -of../lib/libaurora_immediate64d.lib"
RELOPTS64="-lib -m64 -O -release -property -inline -c -lib -version=DX11_1 -I../.. -of../lib/libaurora_immediate64.lib"
DEBUGOPTS32="-lib -m32 -debug -property -g -gs -gx -c -lib -version=DX11_1 -I../.. -of../lib/libaurora_immediate32d.lib"
RELOPTS32="-lib -m32 -O -release -property -inline -c -lib -version=DX11_1 -I../.. -of../lib/libaurora_immediate32.lib"
SRCFILES="entry.d window.d application.d package.d"

dmd $SRCFILES $RELOPTS64
dmd $SRCFILES $RELOPTS32
dmd $SRCFILES $DEBUGOPTS64
dmd $SRCFILES $DEBUGOPTS32