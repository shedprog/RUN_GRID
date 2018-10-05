#!/bin/zsh

# This function clean output DIR.

function CLEAN_ALL {

    echo    "CLEAN_ALL"
	echo    "Press smth to continue"
    read

	if [ -d $OUTPUTDIR/RUN ]; then
	rm -rf $OUTPUTDIR/RUN
	fi
	
    if [ -d $OUTPUTDIR/output ]; then
	rm -r $OUTPUTDIR/output
	fi
	
    if [ -d $OUTPUTDIR/bird_info_out ]; then
	rm -r $OUTPUTDIR/bird_info_out
	fi

	echo 	"CLEAN_ALL done"   
}

function remove_derivatives {	

	echo    "remove_derivatives"
	echo    "Press smth to continue"
	read

	if [ -d $OUTPUTDIR/RUN/run_d ]; then
	rm -r $OUTPUTDIR/RUN/run_d
	fi
	mkdir -p $OUTPUTDIR/RUN/run_d

	if [ -d $OUTPUTDIR/output/derivatives ]; then
	rm -r $OUTPUTDIR/output/derivatives
	fi
	mkdir -p $OUTPUTDIR/output/derivatives

	if [ -d $OUTPUTDIR/bird_info_out/bird_out_d ]; then
	rm -r $OUTPUTDIR/bird_info_out/bird_out_d
	fi
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_d/err
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_d/out

	echo	"remove_derivatives done"
} 

function remove_multy_derivatives {	

	echo    "remove_multy_derivatives"
	echo    "Press smth to continue"
	read

	if [ -d $OUTPUTDIR/RUN/run_md ]; then
	rm -r $OUTPUTDIR/RUN/run_md
	fi
	mkdir -p $OUTPUTDIR/RUN/run_md

	if [ -d $OUTPUTDIR/output/multy_derivatives ]; then
	rm -r $OUTPUTDIR/output/multy_derivatives
	fi
	mkdir -p $OUTPUTDIR/output/multy_derivatives

	if [ -d $OUTPUTDIR/bird_info_out/bird_out_d ]; then
	rm -r $OUTPUTDIR/bird_info_out/bird_out_d
	fi
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_d/err
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_d/out

	echo	"remove_multy_derivatives done"
} 

function remove_simpfit_result {

	echo    "remove_simpfit_result"
	echo    "Press smth to continue"
	read

	if [ -d $OUTPUTDIR/RUN/run_sf ]; then
	rm -r $OUTPUTDIR/RUN/run_sf
	fi
	mkdir -p $OUTPUTDIR/RUN/run_sf

	if [ -d $OUTPUTDIR/output/simpfit ]; then
	rm -r $OUTPUTDIR/output/simpfit
	fi
	mkdir -p $OUTPUTDIR/output/simpfit

	if [ -d $OUTPUTDIR/bird_info_out/bird_out_sf ]; then
	rm -r $OUTPUTDIR/bird_info_out/bird_out_sf
	fi
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_sf/err
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_sf/out
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_sf/log

	

	echo    "remove_simpfit_result done"
}

function remove_multy_simpfit_result {

	echo    "remove_multy_simpfit_result"
	echo    "Press smth to continue"
	read

	if [ -d $OUTPUTDIR/RUN/run_msf ]; then
	rm -r $OUTPUTDIR/RUN/run_msf
	fi
	mkdir -p $OUTPUTDIR/RUN/run_msf

	if [ -d $OUTPUTDIR/output/multy_simpfit ]; then
	rm -r $OUTPUTDIR/output/multy_simpfit
	fi
	mkdir -p $OUTPUTDIR/output/multy_simpfit

	if [ -d $OUTPUTDIR/bird_info_out/bird_out_msf ]; then
	rm -r $OUTPUTDIR/bird_info_out/bird_out_msf
	fi
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_msf/err
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_msf/out

	echo    "remove_multy_simpfit_result done"
}

function remove_monte_carlo_result {

	echo    "remove_monte_carlo_result"
	echo    "Press smth to continue"
	read

	if [ -d $OUTPUTDIR/RUN/run_mc ]; then
	rm -rf $OUTPUTDIR/RUN/run_mc
	fi
	mkdir -p $OUTPUTDIR/RUN/run_mc

	if [ -d $OUTPUTDIR/output/monte_carlo ]; then
	rm -rf $OUTPUTDIR/output/monte_carlo
	fi
	mkdir -p $OUTPUTDIR/output/monte_carlo

	if [ -d $OUTPUTDIR/bird_info_out/bird_out_mc ]; then
	rm -rf $OUTPUTDIR/bird_info_out/bird_out_mc
	fi
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_mc/err
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_mc/out
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_mc/log

	echo    "remove_monte_carlo_result done"
}

function remove_monte_carlo_DEF_result {

	echo    "remove_defoult_monte_carloLH_result"
	echo 	"this for default xfitter "
	echo    "Press smth to continue"
	read

	if [ -d $OUTPUTDIR/RUN/run_mc_def ]; then
	rm -rf $OUTPUTDIR/RUN/run_mc_def
	fi
	mkdir -p $OUTPUTDIR/RUN/run_mc_def

	if [ -d $OUTPUTDIR/output/monte_carlo_def ]; then
	rm -rf $OUTPUTDIR/output/monte_carlo_def
	fi
	mkdir -p $OUTPUTDIR/output/monte_carlo_def

	if [ -d $OUTPUTDIR/bird_info_out/bird_out_mc_def ]; then
	rm -rf $OUTPUTDIR/bird_info_out/bird_out_mc_def
	fi
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_mc_def/err
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_mc_def/out

	echo    "remove_defoult_monte_carloLH_result"
}

function remove_monte_carloLH_result {

	echo    "remove_monte_carloLH_result"
	echo    "Press smth to continue"
	read

	if [ -d $OUTPUTDIR/RUN/run_mcLH ]; then
	rm -rf $OUTPUTDIR/RUN/run_mcLH
	fi
	mkdir -p $OUTPUTDIR/RUN/run_mcLH

	if [ -d $OUTPUTDIR/output/monte_carloLH ]; then
	rm -rf $OUTPUTDIR/output/monte_carloLH
	fi
	mkdir -p $OUTPUTDIR/output/monte_carloLH

	if [ -d $OUTPUTDIR/bird_info_out/bird_out_mcLH ]; then
	rm -rf $OUTPUTDIR/bird_info_out/bird_out_mcLH
	fi
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_mcLH/err
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_mcLH/out

	echo    "remove_monte_carloLH_result done"
}

function remove_multy_monte_carloLH {

	echo    "remove_multy-monte_carloLH_result"
	echo    "Press smth to continue"
	read

	if [ -d $OUTPUTDIR/RUN/run_MmcLH ]; then
	rm -rf $OUTPUTDIR/RUN/run_MmcLH
	fi
	mkdir -p $OUTPUTDIR/RUN/run_MmcLH

	if [ -d $OUTPUTDIR/output/multy_monte_carloLH ]; then
	rm -rf $OUTPUTDIR/output/multy_monte_carloLH
	fi
	mkdir -p $OUTPUTDIR/output/monte_carloLH

	if [ -d $OUTPUTDIR/bird_info_out/bird_out_MmcLH ]; then
	rm -rf $OUTPUTDIR/bird_info_out/bird_out_MmcLH
	fi
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_MmcLH/err
	mkdir -p $OUTPUTDIR/bird_info_out/bird_out_MmcLH/out

	echo    "remove_multy-monte_carloLH_result done"
}
