#!/bin/bash

if [ -L $0 ]; then
	REAL_FILE=$(readlink $0)
	source ${REAL_FILE/.sh/.conf}
else
	source ${0/.sh/.conf}
fi

DOCS_TO_PUBLISH=${1:-$DOCS_TO_PUBLISH_DEFAULT}

if [ -d $DOCS_TO_PUBLISH ]; then
	cd $(dirname $DOCS_TO_PUBLISH)
else
	NEW_DIR=${DOCS_TO_PUBLISH%$MD_WILDCARD} # remove wildcard from string
	cd $(dirname $NEW_DIR)
fi

TARGET_SUB_LOCATION=$(basename $(pwd))

ssh $TARGET_CONNECTION "rm $TARGET_LOCATION_ROOT/$TARGET_SUB_LOCATION/*.html"
for i in $DOCS_TO_PUBLISH/$MD_WILDCARD; do
	scp $(basename $i).html $TARGET_CONNECTION:$TARGET_LOCATION_ROOT/$TARGET_SUB_LOCATION/
done

cd -
exit 0
