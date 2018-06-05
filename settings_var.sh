# All global variables and enviroments
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export OUTPUTDIR="/nfs/dust/zeus/group/mykytaua/14p/OUTPUT_V_o"
#export OUTPUTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#models=( "RR" "LL" "VV" "VA" "AA" "X1" "X2" "X3" "X4" )
models=( "V_o" )
NUMBER_OF_STEPS=10
seedstart=$((RANDOM*RANDOM))
seedstep=357
seednumber=2000
