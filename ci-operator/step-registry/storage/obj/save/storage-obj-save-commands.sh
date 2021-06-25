#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

ARTIFACT_DIR=${ARTIFACT_DIR:-/tmp}
SAVE_FILE=${SHARED_DIR}/initial-objects
STORAGE_OBJECTS=pv,csidriver,storageclass

function report_flake() {
    # Create a junit file with a flake, not a failure
    MESSAGE="$1"
    STDOUT="$2"
    mkdir -p ${ARTIFACT_DIR}/junit/
    cat << EOF > ${ARTIFACT_DIR}/junit/junit_check.xml
<?xml version="1.0"?>
<testsuite name="$0" tests="2" skipped="0" failures="1" time="1">
  <testcase name="$0" time="0">
    <failure message="">
    $1
    </failure>
    <system-out>
    $2
    </system-out>
  </testcase>
  <testcase name="$0" time="0"/>
</testsuite>
EOF
    # For build-log.txt
    echo $MESSAGE
    echo $STDOUT
}


# Try only 10 times, just in case a cluster setup failed.
for i in `seq 10`; do
    echo "Attempt $i"
    if oc get $STORAGE_OBJECTS --no-headers --ignore-not-found -o name > $SAVE_FILE; then
        break;
    fi
    # try until the command succeds
    sleep 5
done

# For debugging
oc get $STORAGE_OBJECTS -o yaml > ${ARTIFACT_DIR}/objects.yaml || :

echo "Saved list of storage objects into $SAVE_FILE"
