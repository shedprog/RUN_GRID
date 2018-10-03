#!/bin/sh
#
#
#$ -e REFOUTDIR/bird_info_out/bird_out_sf/err/
#$ -o REFOUTDIR/bird_info_out/bird_out_sf/out/
#
#   Turn on Verbose Mode
set -x

source REFWORKDIR/settings_env.sh

echo $TMP
cd $TMP
export TMPDIR=$TMP

cp REFWORKDIR/tmp_xfitter/minuit.in.txt .
cp REFWORKDIR/tmp_xfitter/ewparam.txt .
cp REFWORKDIR/tmp_xfitter/steering.txt .
ln -s $XFITTER/bin/xfitter  .
ln -s REFWORKDIR/datafiles .

PDF_is='CI'
INdoCI=true
INCItype='SM'
INCIvarval=0.0
INCIvarstep=1.0E-06
INCIDoSimpFit=false

CI_FIT_TYPE=${INCItype//div//}
sed -i "s|doCI = .*|doCI = $INdoCI|g" $TMPDIR/steering.txt
sed -i "s|CItype = .*|CItype = '$CI_FIT_TYPE'|g" $TMPDIR/steering.txt
sed -i "s|CIvarval = .*|CIvarval = $INCIvarval|g" $TMPDIR/steering.txt
sed -i "s|CIvarstep = .*|CIvarstep = $INCIvarstep|g" $TMPDIR/steering.txt
sed -i "s|CIDoSimpFit =.*|CIDoSimpFit = $INCIDoSimpFit|g" $TMPDIR/steering.txt


./xfitter

cp $TMPDIR/output/CIout.txt  REFOUTDIR/output/simpfit/CIout_${PDF_is}_${INCItype}.txt
cp $TMPDIR/output/minuit.out.txt REFOUTDIR/output/simpfit/minuit_${PDF_is}_${INCItype}.out.txt
cp $TMPDIR/steering.txt REFOUTDIR/output/simpfit/steering_${PDF_is}_${INCItype}.txt
RES=$(awk '{ print $2,$3,$4 }' < output/CIout.txt)
chi2=$(grep -i 'After' $TMPDIR/output/Results.txt | awk '{print $3}')
status=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' $TMPDIR/output/minuit.out.txt | awk '{print $5}')
echo $INCItype $chi2 $RES $status >> REFOUTDIR/output/simpfit/RESULTS_${PDF_is}_${INCItype}.txt

cp -rf $TMPDIR/output REFOUTDIR/output/simpfit/output_${INCItype}