#!/bin/sh
#
#
#$ -e REFOUTDIR/bird_info_out/bird_out_sf/err/
#$ -o REFOUTDIR/bird_info_out/bird_out_sf/out/
#
#   Turn on Verbose Mode
set -x

source REFWORKDIR/settings_env.sh

echo $TMPDIR
cd $TMPDIR

cp REFWORKDIR/tmp_xfitter/minuit.in.txt .
cp REFWORKDIR/tmp_xfitter/ewparam.txt .
cp REFWORKDIR/tmp_xfitter/steering.txt .
ln -s $XFITTER/bin/xfitter  .
ln -s REFWORKDIR/datafiles .

PDF_is='CI'
INdoCI=true
INCItype='VV'
INCIvarval=0.0
INCIvarstep=1.0E-06
INCIDoSimpFit='true'
INCISimpFitStep='SimpFit'
INchange_CIvarval_afterMC=false
INCIvarval_afterMC=0.0
CI_FIT_TYPE=${INCItype//div//}
sed -i "s|doCI = .*|doCI = $INdoCI|g" $TMPDIR/steering.txt
sed -i "s|CItype = .*|CItype = '$CI_FIT_TYPE'|g" $TMPDIR/steering.txt
sed -i "s|CIvarval = .*|CIvarval = $INCIvarval|g" $TMPDIR/steering.txt
sed -i "s|CIvarstep = .*|CIvarstep = $INCIvarstep|g" $TMPDIR/steering.txt
sed -i "s|CIDoSimpFit =.*|CIDoSimpFit = $INCIDoSimpFit|g" $TMPDIR/steering.txt
sed -i "s|CISimpFitStep = '.*|CISimpFitStep = '$INCISimpFitStep'|g" $TMPDIR/steering.txt
sed -i "s| change_CIvarval_afterMC = .*| change_CIvarval_afterMC = $INchange_CIvarval_afterMC|g" $TMPDIR/steering.txt
sed -i "s| CIvarval_afterMC = .*| CIvarval_afterMC = $INCIvarval_afterMC|g" $TMPDIR/steering.txt

./xfitter

cp $TMPDIR/output/CIout.txt  REFOUTDIR/output/simpfit/CIout_${PDF_is}_${INCItype}.txt
cp $TMPDIR/output/minuit.out.txt REFOUTDIR/output/simpfit/minuit_${PDF_is}_${INCItype}.out.txt
cp $TMPDIR/steering.txt REFOUTDIR/output/simpfit/steering_${PDF_is}_${INCItype}.txt
RES=$(awk '{ print $2,$3,$4 }' < output/CIout.txt)
chi2=$(grep -i 'After' $TMPDIR/output/Results.txt | awk '{print $3}')
echo $INCItype $chi2 $RES >> REFOUTDIR/output/simpfit/RESULTS_${PDF_is}_${INCItype}.txt
