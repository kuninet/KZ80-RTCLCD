#!/bin/bash -eu
asl -cpu z80 -L RTC2LCD.ASM
p2hex -r \$-\$ -F Intel RTC2LCD.p
