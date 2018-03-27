
# compiler
. /cvmfs/sft.cern.ch/lcg/contrib/gcc/4.9/x86_64-slc6/setup.sh
# cernlib
export CERN_ROOT=/cvmfs/sft.cern.ch/lcg/app/releases/ROOT/5.34.00/x86_64-slc6-gcc46-opt
# root
cd /cvmfs/sft.cern.ch/lcg/app/releases/ROOT/5.34.00/x86_64-slc6-gcc46-opt/root
. /cvmfs/sft.cern.ch/lcg/app/releases/ROOT/5.34.00/x86_64-slc6-gcc46-opt/root/bin/thisroot.sh
cd -


# directory:

export QCDNUM_ROOT="/afs/desy.de/user/m/mykytaua/sc_soft/todesy/qcdnum-17-01-13_build"
export XFITTER="/afs/desy.de/user/m/mykytaua/sc_soft/todesy/xFitter_CI_build"
export BLAS="/afs/desy.de/user/m/mykytaua/sc_soft/todesy/OpenBLAS_build"

export PATH="$PATH:\
$BLAS/bin:\
$QCDNUM_ROOT/bin:\
/afs/desy.de/user/m/mykytaua/sc_soft/todesy/hoppet-1.1.5_build/bin:\
/afs/desy.de/user/m/mykytaua/sc_soft/todesy/lhapdf-5.8.9_build/bin:\
"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:\
$BLAS/lib:\
$QCDNUM_ROOT/lib:\
/afs/desy.de/user/m/mykytaua/sc_soft/todesy/hoppet-1.1.5_build/lib:\
/afs/desy.de/user/m/mykytaua/sc_soft/todesy/lhapdf-5.8.9_build/lib:\
"