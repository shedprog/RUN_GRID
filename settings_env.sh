
# compiler
#. /cvmfs/sft.cern.ch/lcg/contrib/gcc/4.9/x86_64-slc6/setup.sh
. /afs/cern.ch/sw/lcg/contrib/gcc/4.6.3/x86_64-slc6-gcc46-opt/setup.sh

# cernlib
export CERN_ROOT=/cvmfs/sft.cern.ch/lcg/app/releases/ROOT/5.34.00/x86_64-slc6-gcc46-opt
# root
cd /cvmfs/sft.cern.ch/lcg/app/releases/ROOT/5.34.00/x86_64-slc6-gcc46-opt/root
. /cvmfs/sft.cern.ch/lcg/app/releases/ROOT/5.34.00/x86_64-slc6-gcc46-opt/root/bin/thisroot.sh
cd -


# directory:
SOFT="/afs/desy.de/user/m/mykytaua/sc_soft/todesy"
# SOFT="/nfs/dust/zeus/group/mykytaua/SHARE_SOFT"

export QCDNUM_ROOT="$SOFT/qcdnum-17-01-13_build"
export XFITTER="$SOFT/xFitter_CI_LQ"
export BLAS="$SOFT/OpenBLAS_build"

export PATH="$PATH:\
$BLAS/bin:\
$QCDNUM_ROOT/bin:\
$SOFT/hoppet-1.1.5_build/bin:\
$SOFT/lhapdf-5.8.9_build/bin:\
"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:\
$BLAS/lib:\
$QCDNUM_ROOT/lib:\
$SOFT/hoppet-1.1.5_build/lib:\
$SOFT/lhapdf-5.8.9_build/lib:\
"