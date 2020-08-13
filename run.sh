ocaml $1.ml $2 >$1.s
gcc -mcpu=cortex-a72 -mtune=cortex-a72 -mfpu=neon-fp-armv8 $1.s -o $1
./$1
echo $?
