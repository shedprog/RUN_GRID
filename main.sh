#!/bin/zsh

source settings_var.sh
source settings_env.sh
source src/simpfit.sh
source src/clean.sh
source src/derivative.sh
source src/mc.sh

function replica_ROOT {
    echo $OUTPUTDIRs
    python ./src/analysis_py/replica_error.py left $1 $OUTPUTDIR $models &
    python ./src/analysis_py/replica_error.py right $1 $OUTPUTDIR $models
}

function reload_tamplates_xfitter {
    echo 're-loading tamplates'
    python ./src/analysis_py/update_tamplates.py $PATH_LATEX $PATH_PARAM $models $1
}

executable="echo 'main.sh running:'"

while [ ! $# -eq 0 ]
do
    case "$1" in

        --mode| -m)
            ci_mode=$2
            shift
            ;;
        
        --side| -s)
            side=$2
            shift
            ;;

        --tamplates | -ta)
            executable="$executable; echo 'Load tamplates xfitter. Side:' $side"
            executable="$executable; reload_tamplates_xfitter $side"
            ;;

        --default_fit | -df)
            # executable="$executable; echo 'Load tamplates xfitter. Side:' $side"
            # executable="$executable; reload_tamplates_xfitter $side"
            
            executable="$executable; echo 'Default fit'" 
            executable="$executable; default_fit"
            ;;

        --derivative | -de)
            # executable="$executable; echo 'Load tamplates xfitter. Side:' $side"
            # executable="$executable; reload_tamplates_xfitter $side"
            
            executable="$executable; echo 'Build derivatives for SM, CI'"
            executable="$executable; build_deriv"
            ;;

        --simpfit | -sf)
            echo "Simplified fit is not available in this version of the program!"
            executable="$executable; echo 'Simplified fit <-- derivatives for SM, CI'"
            executable="$executable; simpfit"
            ;;

        --monte_carlo | -mc)
            # executable="$executable; echo 'Load tamplates xfitter. Side:' $side"
            # executable="$executable; reload_tamplates_xfitter $side"

            executable="$executable; echo 'Monte Carlo'"
            executable="$executable; monte_carlo_freq_updated $ci_mode $side"
            ;;

        --analyse | -an)
            executable="$executable; echo 'Analysis in python framework'"
            executable="$executable; replica_ROOT $ci_mode $side"
            ;;

        --clean | cl)
            executable="$executable; echo 'Clean all will be evaluated'"
            executable="$executable; CLEAN_ALL"
            ;;

        *)
            echo 'Not available flag!'
            break
            ;;
    esac
    shift
done

eval $executable
