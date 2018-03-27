#!/bin/zsh

function simpfit {

    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~~~ SimpFit-mode was activated ~~~~~~~~~~'
    echo '~~~~~~ CI: CIvarval=0 CIvarste=1.0E-07 ~~~~~~~~~'
    echo '~~~~~~ SM: CIvarval=0 CIvarste=0.0 ~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

    remove_simpfit_result
  
    for CItype in "${models[@]}"
    do
        CIvarval=0.0
        CIvarstep=1.0E-07

        sed "s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
            s|PDF_is=.*|PDF_is='CI'|g ; s|INdoCI=.*|INdoCI=true|g ;\
            s|INCItype=.*|INCItype='$CItype'|g ; s|INCIvarval=.*|INCIvarval=$CIvarval|g ;\
            s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ; s|INCIDoSimpFit=.*|INCIDoSimpFit='true'|g ;\
            s|INCISimpFitStep=.*|INCISimpFitStep='SimpFit'|g;\
            s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g\
            " $WORKDIR/tmp_grid/batch_bird_sf.cmd > $OUTPUTDIR/RUN/run_sf/batch_CI_${CItype}.cmd

        qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_sf/batch_CI_${CItype}.cmd

        CIvarval=0.0
        CIvarstep=0.0

        sed "s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
            s|PDF_is=.*|PDF_is='SM'|g ; s|INdoCI=.*|INdoCI=true|g ;\
            s|INCItype=.*|INCItype='$CItype'|g ; s|INCIvarval=.*|INCIvarval=$CIvarval|g ;\
            s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ; s|INCIDoSimpFit=.*|INCIDoSimpFit=true|g ;\
            s|INCISimpFitStep=.*|INCISimpFitStep='SimpFit'|g;\
            s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g\
            " $WORKDIR/tmp_grid/batch_bird_sf.cmd > $OUTPUTDIR/RUN/run_sf/batch_SM_${CItype}.cmd

        qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_sf/batch_SM_${CItype}.cmd

    done
}

# Not tested!
function multy-simpfit {
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~~~ SimpFit-mode was activated ~~~~~~~~~~'
    echo '~~~~~~ CI: CIvarval=eta_true CIvarste=1.0E-07 ~~'
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

    remove_multy_simpfit_result

    CIvarstep=1.0E-07

    for CItype in "${models[@]}"
    do

        l_upper_lim=$(grep -i $CItype $WORKDIR/setting_limits.txt | awk '{print $3}')
        l_lower_lim=$(grep -i $CItype $WORKDIR/setting_limits.txt | awk '{print $2}')

        r_upper_lim=$(grep -i $CItype $WORKDIR/setting_limits.txt | awk '{print $5}')
        r_lower_lim=$(grep -i $CItype $WORKDIR/setting_limits.txt | awk '{print $4}')

 	
	
        for (( IREP=1; IREP<=$(($NUMBER_OF_STEPS*2)); IREP=$(($IREP+1)) ))
        do

        		if [ "$IREP" -le "$NUMBER_OF_STEPS" ]; then
                        START=$l_lower_limв
                        STEP=$( echo $l_upper_lim $l_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/$3}')
                        CIvarval=$( echo $STEP $IREP $START | awk '{print $1*$2+$3}')
                else
                        START=$r_lower_lim
                        STEP=$( echo $r_upper_lim $r_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/$3}')
                        CIvarval=$( echo $STEP $IREP $START $NUMBER_OF_STEPS | awk '{print $1*($2-$4)+$3}')
                fi

        sed "s|INIREP=.*|INIREP=$IREP|g ; s|REF1|$WORKDIR|g ; s|PDF_is=.*|PDF_is='CI'|g ;\
            s|INdoCI=.*|INdoCI=true|g ; s|INCItype=.*|INCItype='$CItype'|g ;\
            s|INCIvarval=.*|INCIvarval=$CIvarval|g ;\
            s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ;\
            s|INCIDoSimpFit=.*|INCIDoSimpFit='true'|g ;\
            s|INCISimpFitStep=.*|INCISimpFitStep='SimpFit'|g ;\
            s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g \
            " $WORKDIR//tmp_grid/batch_bird_sf_eta.cmd > $OUTPUTDIR/RUN/run_msf/batch_CI_${CItype}_${IREP}.cmd

        qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_msf/batch_CI_${CItype}_${IREP}.cmd

		done
	done
}