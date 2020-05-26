#!/bin/bash
SOURCE=$1
if [ -z $1 ] ; then
  echo "Usage: assemble.sh {source.as}"
else
  OBJ=${SOURCE/.as/.o}
  BIN=${SOURCE/.as/.bin}
  echo "Assembling $SOURCE to $BIN"
  as -o ${OBJ} ${SOURCE} && ld -o ${BIN} ${OBJ} 
fi

