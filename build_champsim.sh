#!/bin/sh
# ChampSim configuration
BRANCH=$1                # branch/*.bpred
L1D_PREFETCHER=$2        # prefetcher/*.l1d_pref
L2C_PREFETCHER=$3        # prefetcher/*.l2c_pref
LLC_REPLACEMENT=$4       # replacement/*.llc_repl
NUM_CORE=$5              # tested up to 8-core system
CACHE_CONFIG=$6          # ni, in, ex
PRINT_REUSE_STATS=$7     # print reuse distance stats
PRINT_ACCESS_PATTERN=$8  # print sequence of demand access addresses
PRINT_OFFSET_PATTERN=$9  # print sequence of offsets in demand accesses
PRINT_STRIDE_DISTRIBUTION=${10}
PRINT_MLP=${11}

############## Some useful macros ###############
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

embed_newline()
{
   local p="$1"
   shift
   for i in "$@"
   do
      p="$p\n$i"         # Append
   done
   echo -e "$p"          # Use -e
}
#################################################

# Sanity check
if [ ! -f ./branch/${BRANCH}.bpred ] || [ ! -f ./prefetcher/${L1D_PREFETCHER}.l1d_pref ] || [ ! -f ./prefetcher/${L2C_PREFETCHER}.l2c_pref ] || [ ! -f ./replacement/${LLC_REPLACEMENT}.llc_repl ]; then
	echo "${BOLD}Possible Branch Predictor: ${NORMAL}"
	LIST=$(ls branch/*.bpred | cut -d '/' -f2 | cut -d '.' -f1)
	p=$( embed_newline $LIST )
	echo "$p"

	echo "${BOLD}Possible L1D Prefetcher: ${NORMAL}"
	LIST=$(ls prefetcher/*.l1d_pref | cut -d '/' -f2 | cut -d '.' -f1)
	p=$( embed_newline $LIST )
	echo "$p"

	echo
	echo "${BOLD}Possible L2C Prefetcher: ${NORMAL}"
	LIST=$(ls prefetcher/*.l2c_pref | cut -d '/' -f2 | cut -d '.' -f1)
	p=$( embed_newline $LIST )
	echo "$p"

	echo
	echo "${BOLD}Possible LLC Replacement: ${NORMAL}"
	LIST=$(ls replacement/*.llc_repl | cut -d '/' -f2 | cut -d '.' -f1)
	p=$( embed_newline $LIST )
	echo "$p"
	exit
fi

# Check for multi-core
if [ "$NUM_CORE" != "1" ]
then
    echo "${BOLD}Building multi-core ChampSim...${NORMAL}"
    sed -i.bak 's/\<NUM_CPUS 1\>/NUM_CPUS '${NUM_CORE}'/g' inc/champsim.h
	sed -i.bak 's/\<DRAM_CHANNELS 1\>/DRAM_CHANNELS 2/g' inc/champsim.h
	sed -i.bak 's/\<DRAM_CHANNELS_LOG2 0\>/DRAM_CHANNELS_LOG2 1/g' inc/champsim.h
else
    echo "${BOLD}Building single-core ChampSim...${NORMAL}"
fi
echo

# Change prefetchers and replacement policy
cp branch/${BRANCH}.bpred branch/branch_predictor.cc
cp prefetcher/${L1D_PREFETCHER}.l1d_pref prefetcher/l1d_prefetcher.cc
cp prefetcher/${L2C_PREFETCHER}.l2c_pref prefetcher/l2c_prefetcher.cc
cp replacement/${LLC_REPLACEMENT}.llc_repl replacement/llc_replacement.cc

# Collect cache configuration
# 0 = ni
# 1 = in
# 2 = ex
MF_CACHE_CONFIG=0

if [ "$CACHE_CONFIG" = "ni" ]
then
	MF_CACHE_CONFIG=0
elif [ "$CACHE_CONFIG" = "in" ]
then
	MF_CACHE_CONFIG=1
elif [ "$CACHE_CONFIG" = "ex" ]
then
	MF_CACHE_CONFIG=2
else
	echo "Invalid option for CACHE_CONFIG"
	exit 1
fi

# Check for additional print options
MF_PRINT_REUSE_STATS=0
MF_PRINT_ACCESS_PATTERN=0
MF_PRINT_OFFSET_PATTERN=0
MF_PRINT_STRIDE_DISTRIBUTION=0
MF_PRINT_MLP=0

if [ "$PRINT_REUSE_STATS" = "rd" ]
then
	MF_PRINT_REUSE_STATS=1
elif [ "$PRINT_REUSE_STATS" = "no" ]
then
	MF_PRINT_REUSE_STATS=0
else
	echo "Invalid option for PRINT_REUSE_STATS"
	exit 1
fi

if [ "$PRINT_ACCESS_PATTERN" = "ap" ]
then
	MF_PRINT_ACCESS_PATTERN=1
elif [ "$PRINT_ACCESS_PATTERN" = "no" ]
then
	MF_PRINT_ACCESS_PATTERN=0
else
	echo "Invalid option for PRINT_ACCESS_PATTERN"
	exit 1
fi

if [ "$PRINT_OFFSET_PATTERN" = "op" ]
then
	MF_PRINT_OFFSET_PATTERN=1
elif [ "$PRINT_OFFSET_PATTERN" = "no" ]
then
	MF_PRINT_OFFSET_PATTERN=0
else
	echo "Invalid option for PRINT_OFFSET_PATTERN"
	exit 1
fi

if [ "$PRINT_STRIDE_DISTRIBUTION" = "sd" ]
then
	MF_PRINT_STRIDE_DISTRIBUTION=1
elif [ "$PRINT_STRIDE_DISTRIBUTION" = "no" ]
then
	MF_PRINT_STRIDE_DISTRIBUTION=0
else
	echo "Invalid option for PRINT_STRIDE_DISTRIBUTION"
	exit 1
fi

if [ "$PRINT_MLP" = "mlp" ]
then
	MF_PRINT_MLP=1
elif [ "$PRINT_MLP" = "no" ]
then
	MF_PRINT_MLP=0
else
	echo "Invalid option for PRINT_MLP"
	exit 1
fi

# Build
mkdir -p bin
rm -f bin/champsim
make clean
make cache_config=$MF_CACHE_CONFIG print_reuse_stats=$MF_PRINT_REUSE_STATS \
	 print_access_pattern=$MF_PRINT_ACCESS_PATTERN \
	 print_offset_pattern=$MF_PRINT_OFFSET_PATTERN \
	 print_stride_distribution=$MF_PRINT_STRIDE_DISTRIBUTION \
	 print_mlp=$MF_PRINT_MLP

# Sanity check
echo ""
if [ ! -f bin/champsim ]; then
    echo "${BOLD}ChampSim build FAILED!${NORMAL}"
    echo ""
    exit
fi

echo "${BOLD}ChampSim is successfully built"
echo "Branch Predictor: ${BRANCH}"
echo "L1D Prefetcher: ${L1D_PREFETCHER}"
echo "L2C Prefetcher: ${L2C_PREFETCHER}"
echo "LLC Replacement: ${LLC_REPLACEMENT}"
echo "Cores: ${NUM_CORE}"
BINARY_NAME="${BRANCH}-${L1D_PREFETCHER}-${L2C_PREFETCHER}-${LLC_REPLACEMENT}-${NUM_CORE}core-${CACHE_CONFIG}-${PRINT_REUSE_STATS}-${PRINT_ACCESS_PATTERN}-${PRINT_OFFSET_PATTERN}-${PRINT_STRIDE_DISTRIBUTION}-${PRINT_MLP}"
echo "Binary: bin/${BINARY_NAME}${NORMAL}"
echo ""
mv bin/champsim bin/${BINARY_NAME}


# Restore to the default configuration
sed -i.bak 's/\<NUM_CPUS '${NUM_CORE}'\>/NUM_CPUS 1/g' inc/champsim.h
sed -i.bak 's/\<DRAM_CHANNELS 2\>/DRAM_CHANNELS 1/g' inc/champsim.h
sed -i.bak 's/\<DRAM_CHANNELS_LOG2 1\>/DRAM_CHANNELS_LOG2 0/g' inc/champsim.h

cp branch/bimodal.bpred branch/branch_predictor.cc
cp prefetcher/no.l1d_pref prefetcher/l1d_prefetcher.cc
cp prefetcher/no.l2c_pref prefetcher/l2c_prefetcher.cc
cp replacement/lru.llc_repl replacement/llc_replacement.cc
