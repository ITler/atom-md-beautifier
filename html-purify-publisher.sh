#!/bin/bash

if [ -L $0 ]; then
	REAL_FILE=$(readlink $0)
	source ${REAL_FILE/.sh/.conf}
else
	source ${0/.sh/.conf}
fi

DOCS_TO_PUBLISH=${1:-$DOCS_TO_PUBLISH_DEFAULT}
MD_WILDCARD="*.${MD_SUFFIX}"

if [ -d $DOCS_TO_PUBLISH ]; then
	cd "$(dirname $DOCS_TO_PUBLISH)"
else
	NEW_DIR=${DOCS_TO_PUBLISH%$MD_WILDCARD} # remove wildcard from string
	cd "$(dirname $NEW_DIR)"
fi

TARGET_SUB_LOCATION=$(basename "$(pwd)")
TARGET_LOCATION=$TARGET_LOCATION_ROOT/$TARGET_SUB_LOCATION
COPY_TARGET=$TARGET_CONNECTION:$TARGET_LOCATION/

ssh $TARGET_CONNECTION "rm $TARGET_LOCATION/*.${EXPORT_FILE_SUFFIX}"

echo "Start publishing to ${COPY_TARGET}"
for i in $DOCS_TO_PUBLISH/$MD_WILDCARD; do
	SOURCE_FILE=$(basename $i)
	EXPORT_FILE=''
	if [ $EXPORT_FILE_EXTENSION_CONSTRUCTOR == 'concat' ]; then
		EXPORT_FILE="${SOURCE_FILE}.${EXPORT_FILE_SUFFIX}"
	elif [ $EXPORT_FILE_EXTENSION_CONSTRUCTOR == 'replace' ]; then
		EXPORT_FILE=${SOURCE_FILE/$MD_SUFFIX/$EXPORT_FILE_SUFFIX}
	fi
	echo "copying '$EXPORT_FILE'"
	ssh $TARGET_CONNECTION "[ ! -d $TARGET_LOCATION ] && mkdir -p $TARGET_LOCATION"
	scp -q $EXPORT_FILE $COPY_TARGET
	RESOURCES_DIR=$RESOURCES_ROOT/${SOURCE_FILE%.$MD_SUFFIX} # strip file extension from source file
	if [ -r $RESOURCES_DIR ]; then
		echo "additionally sync file's resources found in '${RESOURCES_DIR}'."
		rsync -aLvz --no-o --no-g --delete --exclude '*.draft' --exclude '.*' $RESOURCES_DIR $COPY_TARGET/$RESOURCES_ROOT
	fi
done

cd -
exit 0
