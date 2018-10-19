#!/bin/sh

source REFWORKDIR/settings_env.sh

echo $TMP
cd $TMP
export TMPDIR=$TMP

cp REFWORKDIR/tmp_xfitter/minuit.in.txt .
cp REFWORKDIR/tmp_xfitter/ewparam.txt .
cp REFWORKDIR/tmp_xfitter/steering.txt .
ln -s $XFITTER/bin/xfitter  .
ln -s REFWORKDIR/datafiles .


INCItype='VV'
INCIvarval=0.0
INCIvarstep=1.0E-06
IREP=1
INISeedMC=$((RANDOM*RANDOM))
randomize=RANDOM

cp REFOUTDIR/output/derivatives/CIDerivatives_CI_${INCItype}.txt ./CIDerivatives.txt
CI_FIT_TYPE=${INCItype//div//}
sed -i "s|doCI = false|doCI = true|g" $TMPDIR/steering.txt
sed -i "s|CItype = '.*'|CItype = '$CI_FIT_TYPE'|g" $TMPDIR/steering.txt
sed -i "s|CIvarval =.*|CIvarval = $INCIvarval|g" $TMPDIR/steering.txt
sed -i "s|CIvarstep = '.*'|CIvarstep = $INCIvarstep|g" $TMPDIR/steering.txt
sed -i "s|CIDoSimpFit =.*|CIDoSimpFit = true|g" $TMPDIR/steering.txt
sed -i "s|CISimpFitStep = .*|CISimpFitStep = 'SimpFit'|g" $TMPDIR/steering.txt
sed -i "s|ISeedMC =.*|ISeedMC = $INISeedMC|g" $TMPDIR/steering.txt
sed -i "s|lRAND .*|lRAND = True|g" $TMPDIR/steering.txt

./xfitter

#cp $TMPDIR/output/CIout.txt  REFOUTDIR/output/monte_carlo/CIval_in_${INCItype}_${IREP}.txt
cp $TMPDIR/steering.txt REFOUTDIR/output/monte_carlo/steering_${INCItype}_${IREP}.txt

RES=$(awk '{ print $3,$4 }' < output/CIout.txt)
chis=$(grep -i 'After' output/Results.txt | awk '{print $3}')
status=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' output/minuit.out.txt | awk '{print $5}')
echo $INCItype $chis $INCIvarval $RES $status $INISeedMC >> REFOUTDIR/output/monte_carlo/RESULTS_${INCItype}_${IREP}_${randomize}.txt

#Warning: Clean!
# rm REFOUTDIR/bird_info_out/bird_out_mc/err/*
# rm REFOUTDIR/bird_info_out/bird_out_mc/out/*
# rm REFOUTDIR/RUN/run_mc/r_${IREP}/batch_${INCItype}_${IREP}_${IREP2}.cmd
