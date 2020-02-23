#!/bin/bash -eu
asl -cpu z80 -L RTCWRITE.ASM
p2hex -r \$-\$ -F Intel RTCWRITE.p

asl -cpu z80 -L RTCREAD.ASM
p2hex -r \$-\$ -F Intel RTCREAD.p

asl -cpu z80 -L RTCINIT.ASM
p2hex -r \$-\$ -F Intel RTCINIT.p
