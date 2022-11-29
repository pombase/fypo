#!/bin/sh
# Wrapper script for docker.
#
# We map this folder to a docker volume
#

IMAGE=${IMAGE:-odkfull}
ODK_JAVA_OPTS=-Xmx16G
ODK_DEBUG=${ODK_DEBUG:-no}

TIMECMD=
if [ x$ODK_DEBUG = xyes ]; then
    echo "Running ${IMAGE} with ${ODK_JAVA_OPTS} of memory for ROBOT and Java-based pipeline steps."
    TIMECMD="/usr/bin/time -f ### DEBUG STATS ###\nElapsed time: %E\nPeak memory: %M kb"
fi

git show HEAD:src/ontology/fypo-edit.owl > fypo-edit-old.owl

docker run -v $PWD/../src/ontology:/work/ontology:ro -v $PWD:/work/comprehensive_diff -w /work/ontology -e ROBOT_JAVA_ARGS="$ODK_JAVA_OPTS" -e JAVA_OPTS="$ODK_JAVA_OPTS" --rm -ti obolibrary/$IMAGE $TIMECMD robot diff --labels True --left ../comprehensive_diff/fypo-edit-old.owl --left-catalog catalog-v001.xml --right fypo-edit.owl -f html -o ../comprehensive_diff/editdiff.html

case "$@" in
*update_repo*|*release*)
    echo "Please remember to update your ODK image from time to time: https://oboacademy.github.io/obook/howto/odk-update/."
    ;;
esac