#!/bin/zsh

function build_deriv {

	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~ CalcDerivatives-mode was activated ~~~~~~'
    echo '~~~~~~ CI: CIvarval=0 CIvarste=1.0E-07 ~~~~~~~~~'
    echo '~~~~~~ SM: CIvarval=0 CIvarste=0.0 ~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

    remove_derivatives

    for CItype in "${models[@]}"
	do
    
    # #replace / with | in the name of the file
    # file_name=${model////|}

	CIvarval=0.0
	CIvarstep=1.0E-07

		echo 'Model: ' $n

        sed "s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
            s|PDF_is=.*|PDF_is='CI'|g ;\
            s|INdoCI=.*|INdoCI=true|g ; s|INCItype=.*|INCItype='$CItype'|g ;\
            s|INCIvarval=.*|INCIvarval=$CIvarval|g ;\
            s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ;\
            s|INCIDoSimpFit=.*|INCIDoSimpFit='true'|g ;\
            s|INCISimpFitStep=.*|INCISimpFitStep='CalcDerivatives'|g ;\
            s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g \
            " $WORKDIR/tmp_grid/batch_bird_d.cmd > $OUTPUTDIR/RUN/run_d/batch_CI_${CItype}.cmd
		
        condor_qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_d/batch_CI_${CItype}.cmd &

    CIvarval=0.0
    CIvarstep=0.0

	sed "s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
            s|PDF_is=.*|PDF_is='SM'|g ;\
            s|INdoCI=.*|INdoCI=true|g ; s|INCItype=.*|INCItype='$CItype'|g ;\
            s|INCIvarval=.*|INCIvarval=$CIvarval|g ;\
            s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ;\
            s|INCIDoSimpFit=.*|INCIDoSimpFit='true'|g ;\
            s|INCISimpFitStep=.*|INCISimpFitStep='CalcDerivatives'|g ;\
            s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g \
            " $WORKDIR/tmp_grid/batch_bird_d.cmd > $OUTPUTDIR/RUN/run_d/batch_SM_${CItype}.cmd
        
        condor_qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_d/batch_SM_${CItype}.cmd
	done

} 