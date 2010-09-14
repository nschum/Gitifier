#!/bin/bash
DIR=`dirname $0`
if [ -n "$1" ]; then
  FILES="$1"
else
  FILES="$DIR/*.h"
fi
INCLUDES="-I$DIR"

mkdir -p $DIR/Bridges

for file in $FILES
do
  gen_bridge_metadata -c "$INCLUDES" $file > $DIR/Bridges/`basename $file .h`.bridgesupport
  echo "Generated bridge for" `basename $file`
done
