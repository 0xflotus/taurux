#!/bin/bash

echo "Started use_taurux.sh"
dart ./taurux.snapshot $EXAMPLE_LINK || exit 1
dart ./taurux.snapshot $EXAMPLE_LINK --target /tmp || exit 1
dart ./taurux.snapshot $EXAMPLE_LINK --target /tmp --name foo --cbr 128 || exit 1
du -h $EXAMPLE_FILE || exit 1
du -h /tmp/$EXAMPLE_FILE || exit 1
du -h /tmp/foo.mp3 || exit 1
echo "Cleanup"
rm $EXAMPLE_FILE || exit 1
rm /tmp/$EXAMPLE_FILE || exit 1
rm /tmp/foo.mp3 || exit 1
echo "Finished"