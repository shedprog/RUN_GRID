#!/bin/zsh

function default_fit {
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~ Default xFitter fit ~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo "Models: ${models[@]}" 

    # remove_simpfit_result

    CIvarval=0.0
    CIvarstep=0.0


    echo "Standart Model fits submiting" 
    sed  "s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
          s|PDF_is=.*|PDF_is='SM'|g ; s|INdoCI=.*|INdoCI=false|g\
          " $WORKDIR/tmp_grid/batch_bird_default_fit.cmd > $OUTPUTDIR/RUN/run_sf/batch_SM.cmd
    condor_qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_sf/batch_SM.cmd

    echo "CI models fits submiting"
    CIvarstep=1.0E-07
    for CItype in "${models[@]}"
    do
        echo "Submiting-${CItype}"
        sed "s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
            s|PDF_is=.*|PDF_is='CI'|g ; s|INdoCI=.*|INdoCI=true|g ;\
            s|INCItype=.*|INCItype='$CItype'|g ; s|INCIvarval=.*|INCIvarval=$CIvarval|g ;\
            s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ; s|INCIDoSimpFit=.*|INCIDoSimpFit=false|g\
            " $WORKDIR/tmp_grid/batch_bird_default_fit.cmd  > $OUTPUTDIR/RUN/run_sf/batch_CI_${CItype}.cmd
        condor_qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_sf/batch_CI_${CItype}.cmd
    done 

}

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

        condor_qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_sf/batch_CI_${CItype}.cmd &

        CIvarval=0.0
        CIvarstep=0.0

        sed "s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
            s|PDF_is=.*|PDF_is='SM'|g ; s|INdoCI=.*|INdoCI=true|g ;\
            s|INCItype=.*|INCItype='$CItype'|g ; s|INCIvarval=.*|INCIvarval=$CIvarval|g ;\
            s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ; s|INCIDoSimpFit=.*|INCIDoSimpFit=true|g ;\
            s|INCISimpFitStep=.*|INCISimpFitStep='SimpFit'|g;\
            s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g\
            " $WORKDIR/tmp_grid/batch_bird_sf.cmd > $OUTPUTDIR/RUN/run_sf/batch_SM_${CItype}.cmd

        condor_qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_sf/batch_SM_${CItype}.cmd

    done
}