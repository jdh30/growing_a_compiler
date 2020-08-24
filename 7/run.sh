echo Building compiler...
dune build
echo Running compiler...
./_build/default/compiler.exe >program.s
echo Assembling generated program...
gcc -nostdlib -mcpu=cortex-a72 -mtune=cortex-a72 -mfpu=neon-fp-armv8 program.s -o program
echo Running executable and printing exit code...
time (./program; echo $?)