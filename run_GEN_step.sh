#!/bin/bash
# POSIX

show_help() {
    echo "Usage: ${0##*/} [-i INPUT_DIR] [-o OUTPUT_DIR] [--process_label PROCESS_LABEL] [-n NEVENTS] [--cmssw_rel CMSSW_RELEASE] [--job_number JOB_NUMBER]..."
    exit 1
}

die() {
    printf '%s\n' "$1" >&2
    exit 0
}

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
PROCESS_LABEL=;
INPUT_DIR=$PWD;
OUTPUT_DIR=$PWD;
EVENTS=100;
THREADS=8
JOB_NUMBER=0
CMSSW_RELEASE=10_6_27

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -i|--input_dir)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                INPUT_DIR=$2
                echo "** GEN step: Looking for fragment into $INPUT_DIR directory"
                shift
            else
                echo "** GEN step: Using $INPUT_DIR as default input input path"
            fi
            ;;
        -o|--output_dir)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                OUTPUT_DIR=$2
                echo "** GEN step: Using $OUTPUT_DIR as output directory"
                shift
            else
                echo "** GEN step: Using $INPUT_DIR as default output directory"
            fi
            ;;
        --job_number) 
            if [ "$2" ]; then
                JOB_NUMBER=$2
                shift
            fi
            ;;
        --process_label)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                PROCESS_LABEL=$2
                echo "** GEN step: Using ${PROCESS_LABEL}_fragment.py as input fragment"
                shift
            else
                die '** GEN step ERROR: "--process_label" requires a non-empty option argument.'
            fi
            ;;
        -n|--nevents)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                EVENTS=$2
                echo "** GEN step: Producing $EVENTS (input value)"
                shift
            else
                echo "** GEN step: Producing $EVENTS (default value)"
            fi
            ;;
        --cmssw_rel)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                CMSSW_RELEASE=$2
                echo "** GEN step: Using CMSSW_${CMSSW_RELEASE}"
                shift
            fi
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

OUT_FILENAME_GEN=${PROCESS_LABEL}_${JOB_NUMBER}_GEN.root
CFG_FILENAME_GEN=${PROCESS_LABEL}_GEN_cfg.py

export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_${CMSSW_RELEASE}/src ] ; then
  echo release CMSSW_${CMSSW_RELEASE} already exists
else
  scram p CMSSW CMSSW_${CMSSW_RELEASE}
fi
cd CMSSW_${CMSSW_RELEASE}/src
eval `scram runtime -sh`
mkdir -pv $CMSSW_BASE/src/Configuration/GenProduction/python
cp $INPUT_DIR/${PROCESS_LABEL}_fragment.py $CMSSW_BASE/src/Configuration/GenProduction/python
scram b -j8
cd ../..

export CMSSW_SEARCH_PATH=${CMSSW_SEARCH_PATH}:/afs/cern.ch/work/l/llunerti/private/BsToDsMuNu_generation/GEN/CMSSW_10_6_27/src

#Generate config file
cmsDriver.py Configuration/GenProduction/python/${PROCESS_LABEL}_fragment.py --python_filename ${CFG_FILENAME_GEN} --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN --fileout file:${OUTPUT_DIR}/${OUT_FILENAME_GEN} --conditions 106X_upgrade2018_realistic_v4 --beamspot Realistic25ns13TeVEarly2018Collision --step GEN --geometry DB:Extended --nThreads $THREADS --era Run2_2018 --no_exec --mc -n $EVENTS

# Run generated config
cmsRun ${CFG_FILENAME_GEN} || exit $? ;
