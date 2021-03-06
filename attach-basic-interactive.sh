#!/usr/bin/env bash

# cwd into where this script is located
line=$(pidof hl2_linux)
arr=($line)
inst=$1
if [ $# == 0 ]; then
  inst=0
fi

if [ ${#arr[@]} == 0 ]; then
  echo TF2 isn\'t running!
  exit
fi

if [ $inst -gt ${#arr[@]} ] || [ $inst == ${#arr[@]} ]; then
  echo wrong index!
  exit
fi

proc=${arr[$inst]}

echo Running instances: "${arr[@]}"
echo Attaching to "$proc"

#sudo ./detach $inst bin/libcathook.so

#if grep -q "$(realpath bin/libcathook.so)" /proc/"$proc"/maps; then
#  echo already loaded
#  exit
#fi

# pBypass for crash dumps being sent
# You may also want to consider using -nobreakpad in your launch options.
sudo rm -rf /tmp/dumps # Remove if it exists
sudo mkdir /tmp/dumps # Make it as root
sudo chmod 000 /tmp/dumps # No permissions

#FILENAME="/tmp/.gl$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)"

#cp "bin/Debug/libdoghook.so" "$FILENAME"
FILENAME=$(readlink -f "${0%/*}/bin/Debug/libdoghook.so")

echo loading "$FILENAME" to "$proc"

sudo killall -19 steam
sudo killall -19 steamwebhelper

sudo gdb -n \
  -ex "attach $proc" \
  -ex "set \$dlopen = (void*(*)(char*, int)) dlopen" \
  -ex "call \$dlopen(\"$FILENAME\", 1)" \
  -ex "call dlerror()" \
  -ex 'print (char *) $2'
  
#rm $FILENAME

sudo killall -18 steamwebhelper
sudo killall -18 steam
