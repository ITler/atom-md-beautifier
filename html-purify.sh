#!/bin/bash

if [ -L $0 ]; then
	REAL_FILE=$(readlink $0)
	source ${REAL_FILE/.sh/.conf}
else
	source ${0/.sh/.conf}
fi
DOCS_TO_PUBLISH_ARG=${1:-$DOCS_TO_PUBLISH_DEFAULT}
MD_WILDCARD="*.${MD_SUFFIX}"

ORIGIN_PATH=$(pwd)
if [ -r $DOCS_TO_PUBLISH_ARG ]; then
	if [ -d $DOCS_TO_PUBLISH_ARG ]; then
		DOCS_TO_PUBLISH=$DOCS_TO_PUBLISH_ARG
		if [ -d $DOCS_TO_PUBLISH_ARG/$DOCS_TO_PUBLISH_DEFAULT ] \
		&& [ -r $DOCS_TO_PUBLISH_ARG/$DOCS_TO_PUBLISH_DEFAULT ]; then
			DOCS_TO_PUBLISH="$DOCS_TO_PUBLISH/$DOCS_TO_PUBLISH_DEFAULT"
		fi
		# DOCS_TO_PUBLISH="$DOCS_TO_PUBLISH/$MD_WILDCARD"
	elif [ -f $DOCS_TO_PUBLISH_ARG ]; then
		DOCS_TO_PUBLISH=$DOCS_TO_PUBLISH_ARG
	else
		echo "What is this? $DOCS_TO_PUBLISH_ARG" >&2 && exit 3
	fi
else
	cd "$(dirname $0)"
	if [ -r "$(pwd)/${DOCS_TO_PUBLISH_ARG}" ]; then
		DOCS_TO_PUBLISH="$(pwd)/$DOCS_TO_PUBLISH_ARG"
	else
		cd -
		DOCS_TO_PUBLISH=.
	fi
fi

HOME_PATH=$(pwd)

for i in $DOCS_TO_PUBLISH/$MD_WILDCARD; do
	SOURCE_FILE=$(basename $i)
	HTML_FILE=''
	if [ $EXPORT_FILE_EXTENSION_CONSTRUCTOR == 'concat' ]; then
		HTML_FILE="${SOURCE_FILE}.${EXPORT_FILE_SUFFIX}"
	elif [ $EXPORT_FILE_EXTENSION_CONSTRUCTOR == 'replace' ]; then
		HTML_FILE=${SOURCE_FILE/$MD_SUFFIX/$EXPORT_FILE_SUFFIX}
		if [ ! -r $HTML_FILE ]; then
			cp $SOURCE_FILE $HTML_FILE
		fi
	fi
	HTM_FILE=$HTML_FILE
	if [ -w $HTML_FILE ]; then
		if [ $MODE == 'dev' ]; then
			cp $HTML_FILE $HTM_FILE
			HTM_FILE=${HTML_FILE%'l'}
		fi


		START_STYLE=$(awk '/<style>/{ print NR; exit }' $HTM_FILE)
		END_STYLE=$(awk '/<\/style>/{ print NR; exit }' $HTM_FILE)
		if [ $START_STYLE -gt 1 ]; then
			sed -i "${START_STYLE},${END_STYLE}d" $HTM_FILE
			sed -i "s~</head>.*~    $STYLE\n  </head>~" $HTM_FILE
			sed -i "s~${DIV_INJECT_OPEN}~${DIV_INJECT_OPEN_PATTERN}~" $HTM_FILE
			sed -i "s~${DIV_INJECT_CLOSE}~${DIV_INJECT_CLOSE_PATTERN}~" $HTM_FILE
			sed -i "s~${DIV_INJECT_OPEN_PATTERN}~${DIV_INJECT_OPEN}~" $HTM_FILE
			sed -i "s~${DIV_INJECT_CLOSE_PATTERN}~${DIV_INJECT_CLOSE}~" $HTM_FILE
		fi

		echo beautified: $HTML_FILE
	else
		echo File omitted as resource not existent $HTML_FILE
	fi
done

if [ $ORIGIN_PATH != $HOME_PATH ]; then
	cd -
fi

echo Check created HTML files for convenience $HOME_PATH.
if [ -r ${PUBLISH_EXECUTABLE/.sh/.conf} ]; then
	echo Upload starts in 3 seconds.
	sleep 3
	$PUBLISH_EXECUTABLE $DOCS_TO_PUBLISH_ARG
	exit $?
else
	echo Auto publishing not available due to missing publishing configuration file.
	exit 0
fi
