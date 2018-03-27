#!/bin/sh
#
#
#$ -e REFOUTDIR/bird_info_out/bird_out_mcLH/err/
#$ -o REFOUTDIR/bird_info_out/bird_out_mcLH/out/
#
#   Turn on Verbose Mode
set -x

source REFWORKDIR/settings_env.sh

echo $TMPDIR
cd $TMPDIR

mkdir -p output
ln -s REFWORKDIR/tmp_xfitter/minuit.in.txt .
ln -s REFWORKDIR/tmp_xfitter/ewparam.txt .
cp REFWORKDIR/tmp_xfitter/steering.txt .
ln -s $XFITTER/bin/xfitter  .
ln -s REFWORKDIR/datafiles .


PDF_is='CI'
INdoCI=true
INCItype='VV'
INCIvarval=0.0
INCIvarstep=1.0E-06
INCIDoSimpFit='true'
INCISimpFitStep='CalcDerivatives'
IREP=1
IREP2=1
INlRAND=true
INISeedMC=11000111
INchange_CIvarval_afterMC=false
INCIvarval_afterMC=0.0

if [ "$PDF_is" = 'DATA' ];then
cp REFOUTDIR/output/derivatives/CIDerivatives_CI_${INCItype}.txt ./CIDerivatives.txt
else
cp REFOUTDIR/output/derivatives/CIDerivatives_${PDF_is}_${INCItype}.txt ./CIDerivatives.txt
fi

sed -i "s|doCI = .*|doCI = $INdoCI|g" $TMPDIR/steering.txt
sed -i "s|CItype = '.*'|CItype = '$INCItype'|g" $TMPDIR/steering.txt
sed -i "s|CIvarval =.*|CIvarval = $INCIvarval|g" $TMPDIR/steering.txt
sed -i "s|CIvarstep = .*|CIvarstep = $INCIvarstep|g" $TMPDIR/steering.txt
sed -i "s|CIDoSimpFit =.*|CIDoSimpFit = $INCIDoSimpFit|g" $TMPDIR/steering.txt
sed -i "s|CISimpFitStep = '.*|CISimpFitStep = '$INCISimpFitStep'|g" $TMPDIR/steering.txt
sed -i "s|ISeedMC =.*|ISeedMC = $INISeedMC|g" $TMPDIR/steering.txt
sed -i "s|lRAND = .*|lRAND = $INlRAND|g" $TMPDIR/steering.txt
sed -i "s| change_CIvarval_afterMC = .*| change_CIvarval_afterMC = $INchange_CIvarval_afterMC|g" $TMPDIR/steering.txt
sed -i "s| CIvarval_afterMC = .*| CIvarval_afterMC = $INCIvarval_afterMC|g" $TMPDIR/steering.txt

./xfitter

#cp $TMPDIR/steering.txt REFOUTDIR/output/monte_carloLH/steering_${PDF_is}_${IREP}.txt
#cp $TMPDIR/output/Results.txt REFOUTDIR/output/monte_carloLH/Results_${PDF_is}_${IREP}.txt

if [ "$PDF_is" = 'DATA' ];then

RES=$(awk '{ print $3,$4 }' < $TMPDIR/output/CIout.txt)
chis=$(grep -i 'After' $TMPDIR/output/Results.txt | awk '{print $3}')
status=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' | awk '{print $6}')
echo $INCItype $chis $INCIvarval $RES $status >> REFOUTDIR/output/monte_carloLH/RESULTS_${INCItype}_${IREP}_DATA.txt

rm REFOUTDIR/RUN/run_mcLH/r_${IREP}/batch_DATA_${INCItype}_${IREP}.cmd


elif [ "$PDF_is" = 'CI' ];then

RES=$(awk '{ print $3,$4 }' < $TMPDIR/output/CIout.txt)
chis=$(grep -i 'After' $TMPDIR/output/Results.txt | awk '{print $3}')
status=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' | awk '{print $6}')
echo $INCItype $chis $INCIvarval $RES $status $IREP2 >> REFOUTDIR/output/monte_carloLH/RESULTS_${INCItype}_${IREP}_CI.txt

rm REFOUTDIR/RUN/run_mc/r_${IREP}/batch_CI_${INCItype}_${IREP}_${IREP2}.cmd

else

chis=$(grep -i 'After' $TMPDIR/output/Results.txt | awk '{print $3}')
status=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' | awk '{print $6}')
echo $INCItype $chis $INCIvarval $status $IREP2 >> REFOUTDIR/output/monte_carloLH/RESULTS_${INCItype}_${IREP}_SM.txt

rm REFOUTDIR/RUN/run_mc/r_${IREP}/batch_SM_${INCItype}_${IREP}_${IREP2}.cmd

fi

#Warning: Clean!
rm REFOUTDIR/bird_info_out/bird_out_mcLH/err/*
rm REFOUTDIR/bird_info_out/bird_out_mcLH/out/*
