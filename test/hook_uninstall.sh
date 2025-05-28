#!/bin/sh
GIT_DIR=$(git rev-parse --git-dir)
echo "Removing Git hooks..."
rm -f $GIT_DIR/hooks/pre-push
echo "Done!"

