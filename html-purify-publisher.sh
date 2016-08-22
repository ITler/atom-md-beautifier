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
	pushd "$(dirname $DOCS_TO_PUBLISH)" >/dev/null
else
	NEW_DIR=${DOCS_TO_PUBLISH%$MD_WILDCARD} # remove wildcard from string
	pushd "$(dirname $NEW_DIR)" >/dev/null
fi

TARGET_SUB_LOCATION=$(basename "$(pwd)")
TARGET_LOCATION=$TARGET_LOCATION_ROOT/$TARGET_SUB_LOCATION
COPY_TARGET=$TARGET_CONNECTION:$TARGET_LOCATION/

if [ -d $DOCS_TO_PUBLISH ]; then
	DOCS_TO_PUBLISH=$(find $DOCS_TO_PUBLISH -type l -print0 | xargs -0)
else
	for doc in $DOCS_TO_PUBLISH/$MD_WILDCARD; do
		DOCS_TO_PUBLISH_NEW="${DOCS_TO_PUBLISH_NEW} $doc"
	done
	DOCS_TO_PUBLISH=$DOCS_TO_PUBLISH_NEW
fi
# exit 1
ssh $TARGET_CONNECTION "find $TARGET_LOCATION -name \"${EXPORT_FILE_SUFFIX}\" -delete"
echo "Start publishing to ${COPY_TARGET}"
for i in $DOCS_TO_PUBLISH; do
	SOURCE_PATH=''
	SOURCE_FILE=$(basename $i)
	if [[ $i =~ \/ ]]; then
		for j in $(echo $i | sed 's/\// /g'); do
			if [ $j != $DOCS_TO_PUBLISH_DEFAULT ] && [ $j != '.' ] && [ $j != $SOURCE_FILE ]; then
				SOURCE_PATH="${SOURCE_PATH}${j}/"
			fi
		done
	fi
	echo $SOURCE_FILE
	EXPORT_FILE=''
	if [ $EXPORT_FILE_EXTENSION_CONSTRUCTOR == 'concat' ]; then
		EXPORT_FILE="${SOURCE_FILE}.${EXPORT_FILE_SUFFIX}"
	elif [ $EXPORT_FILE_EXTENSION_CONSTRUCTOR == 'replace' ]; then
		EXPORT_FILE=${SOURCE_FILE/$MD_SUFFIX/$EXPORT_FILE_SUFFIX}
	fi
	REAL_COPY_TARGET="${COPY_TARGET}${SOURCE_PATH}"
	REAL_TARGET_LOCATION="${TARGET_LOCATION}/${SOURCE_PATH}"
	echo "copying '$EXPORT_FILE'@$REAL_TARGET_LOCATION"
	ssh $TARGET_CONNECTION "[ ! -d $REAL_TARGET_LOCATION ] && mkdir -p $REAL_TARGET_LOCATION"
	scp -q $EXPORT_FILE $REAL_COPY_TARGET
	RESOURCES_DIR=$RESOURCES_ROOT/${SOURCE_FILE%.$MD_SUFFIX} # strip file extension from source file
	if [ -r $RESOURCES_DIR ]; then
		echo "additionally sync file's resources found in '${RESOURCES_DIR}'."
		rsync -aLvz --no-o --no-g --delete --exclude '*.draft' --exclude '.*' $RESOURCES_DIR $REAL_COPY_TARGET/$RESOURCES_ROOT
	fi
done

popd >/dev/null
exit 0
