#!/bin/bash
DIR=`dirname $0`
DIRS=`find $DIR -type d -and -not -path '*.git*'`
FILES=`find $DIR -name '*.h' -and -not -name '*Keychain*' -and -not -name '*PSUI*'`

INCLUDES="-I/Users/psionides/Projects/irubytime/RubyTime/Lib/ASIHTTPRequest"
for dir in $DIRS
do
  INCLUDES="$INCLUDES -I$dir"
done

mkdir -p $DIR/Bridges

for file in $FILES
do
  gen_bridge_metadata -c "$INCLUDES" $file > $DIR/Bridges/`basename $file .h`.bridgesupport
  echo "Generated bridge for" `basename $file`
done
