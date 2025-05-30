#!/bin/sh
GITDIR=$(git rev-parse --git-dir)
echo "Installing Git hooks..."
mkdir -p $GITDIR/hooks
cp ./pre-push.sh $GITDIR/hooks/pre-push
chmod +x $GITDIR/hooks/pre-push
echo "Done!"

