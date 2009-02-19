#!/bin/bash
######################################################################
# Script to run all unit tests
#
#
######################################################################
fl=`find . -name '*.mos'`
##curDir=`pwd`
curDir="P:/ldrd/bie/modeling/bie/branches/mwetter/work/bie/modelica/Buildings"
if [ `basename $curDir` != "Buildings" ]; then
    echo "*** Error. Program must be run from directory 'Buildings'"
    echo "*** Exit with error without doing anything."
    exit 1
fi

MOSFIL=runAll.mos

##echo "Unit tests run on `date`" > $curDir/unitTests.log
##echo "User     : `whoami`" >> $curDir/unitTests.log
##echo "Directory: `pwd`" >> $curDir/unitTests.log

echo "Generating script to run all examples."

echo "// File autogenerated by `whoami`. Do not edit." > $MOSFIL
echo "openModel(\"package.mo\");" >> $MOSFIL
for ff in $fl; do
    grep "simulateModel" $ff > /dev/null
    if [ $? == 0 ]; then
	FILNAM=`basename $ff`
	DIRNAM=`dirname $ff`
	echo "cd $DIRNAM" >> $MOSFIL
	echo "RunScript(\"$FILNAM\");" >> $MOSFIL
##	echo "system(\"echo ===================== >> $curDir/unitTests.log\");" >> $MOSFIL
##	echo "system(\"echo === $ff >> $curDir/unitTests.log\");" >> $MOSFIL
##	echo "system(\"cat dslog.txt >> $curDir/unitTests.log\");" >> $MOSFIL
	echo "cd $curDir" >> $MOSFIL
    fi
done
##echo "exit();" >> $MOSFIL
##echo "Running Dymola"
##dymola6 $MOSFIL
##rm $MOSFIL

##nFai=`grep -c -i failed unitTests.log`
##if [ "$nFai" == "0" ]; then 
##    echo "All unit tests run successfully."
##else
##    echo "Error: Found $nFai errors in unit test. Check unitTests.log for details."
##fi