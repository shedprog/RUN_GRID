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
ABSmin=1.0E-12
ABSmax=1.0E-05

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

# First interval \eta<0
sed -i "s|CIvarmin .*|CIvarmin = -$ABSmax|g" $TMPDIR/steering.txt
sed -i "s|CIvarmax .*|CIvarmax = $ABSmin|g" $TMPDIR/steering.txt

./xfitter

#cp $TMPDIR/output/CIout.txt  REFOUTDIR/output/monte_carlo/CIval_in_${INCItype}_${IREP}.txt
cp $TMPDIR/steering.txt REFOUTDIR/output/monte_carlo/steering_neg_${INCItype}_${IREP}.txt
RES1=$(awk '{ print $3 }' < output/CIout.txt)
chis1=$(grep -i 'After' output/Results.txt | awk '{print $3}')
status1=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' output/minuit.out.txt | awk '{print $5}')
# echo $INCItype $chis $INCIvarval $RES $status $INISeedMC >> REFOUTDIR/output/monte_carlo/RESULTS_${INCItype}_${IREP}_${randomize}.txt

# Second interval \eta>0
sed -i "s|CIvarmin .*|CIvarmin = -$ABSmin|g" $TMPDIR/steering.txt
sed -i "s|CIvarmax .*|CIvarmax = $ABSmax|g" $TMPDIR/steering.txt

./xfitter

#cp $TMPDIR/output/CIout.txt  REFOUTDIR/output/monte_carlo/CIval_in_${INCItype}_${IREP}.txt
cp $TMPDIR/steering.txt REFOUTDIR/output/monte_carlo/steering_pos_${INCItype}_${IREP}.txt
RES2=$(awk '{ print $3 }' < output/CIout.txt)
chis2=$(grep -i 'After' output/Results.txt | awk '{print $3}')
status2=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' output/minuit.out.txt | awk '{print $5}')
# echo $INCItype $chis $INCIvarval $RES $status $INISeedMC >> REFOUTDIR/output/monte_carlo/RESULTS_${INCItype}_${IREP}_${randomize}.txt

null=0.0
factor=1.0E12
rep_neg=`echo $(($RES1*$factor))'<'$null | bc -l`
rep_pos=`echo $(($RES2*$factor))'>'$null | bc -l`

echo $INCItype $INISeedMC $INCIvarval $chis1 $RES1 $status1 $rep_neg $chis2 $RES2 $status2 $rep_pos >> REFOUTDIR/output/monte_carlo/RESULTS_${INCItype}_${IREP}_${randomize}.txt