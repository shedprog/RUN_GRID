# All global variables and enviroments
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export OUTPUTDIR="/nfs/dust/zeus/group/mykytaua/NEW_2018/X6_newdata"
#export OUTPUTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#models=( "RR" "LL" "RL" "LR" "VV" "VA" "AA" "X1" "X2" "X3" "X4" "X5" "X6" "S_o" "S_o_L" "S_o_R" "~S_o" "S_1div2" "S_1div2_L" "S_1div2_R" "~S_1div2" "S_1" "V_o" "V_o_L" "V_o_R" "~V_o" "V_1div2" "V_1div2_L" "V_1div2_R" "~V_1div2" "V_1" )
models=( "X6" )
NUMBER_OF_STEPS=20
seedstart=$((RANDOM*RANDOM))
seedstep=357
seednumber=3000
