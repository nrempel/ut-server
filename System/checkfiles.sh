#!/bin/bash

echo "UTPG Linux Patch tester - v451"

#
# this script needs to be executed from the base install dir (not the System dir)
# DONT TOUCH ANYTHING BELOW THIS
#

MD5FILE="patch.md5"

# perform initial checking
if ! [ -e "${MD5FILE}" ]; then
    echo "Missing the md5 archive: ${MD5FILE}"
    exit 1;
fi
TEST=`type md5sum`
if [ -z "${TEST}" ]; then
    echo "This script requires `md5sum` to be installed"
    exit 1;
fi


#
# check the files in patch.md5
checkFiles()
{
    echo "Checking..."
    BADFILE="0"
    IFS=$'\n'$'\t'
    for ML in `cat ${MD5FILE}`
    do
	MD5=`echo -e $ML | cut -d ' ' -f 1`
	ML=`echo -e $ML | cut -d ' ' -f 3`
	DN=`dirname $ML`
	FN=`basename $ML`
	MATCHINGFILE="0"
	for CF in `find $DN -iname $FN -maxdepth 1`
	do
	    TEST=`md5sum $CF | cut -d ' ' -f 1`
	    if ! [ "${TEST}" = "${MD5}" ]; then
		echo "MD5 checksum mismatch for $CF moving to $CF.old"
		mv $CF $CF.old
		BADFILE=$(( $BADFILE + 1 ))
	    fi
	    MATCHINGFILE="1"
	done;
	if [ "${MATCHINGFILE}" -eq "0" ]; then
	    echo "Missing file $ML";
	    BADFILE=$(( $BADFILE + 1 ))
	fi
    done;
    if [ "${BADFILE}" -eq "0" ]; then
	echo "Everything is OK";
    else
	echo "Found ${BADFILE} bad file(s)";
    fi
}

#
# create the patch.md5 file
# must be an isolated directory with all changed files
createPatchMD5()
{
    # empty file
    echo -n "" > $MD5FILE
    for FL in `find . -type f -mindepth 2`
    do
	echo "+ $FL"
	md5sum $FL >> $MD5FILE
    done;
}


if [ "${1}" == "-c" ]; then
    createPatchMD5
else
    checkFiles
fi