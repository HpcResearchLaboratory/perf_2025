#!/bin/bash
#SBATCH --job-name=dlio_bench
#SBATCH --partition=tupi
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --time=10:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

set -e

BASE_DIR=${SLURM_SUBMIT_DIR}
VENV_DIR="${BASE_DIR}/venv"
CONFIG_DIR="${BASE_DIR}/config"
RESULTS_DIR="${BASE_DIR}/results"
DLIO_DIR="${BASE_DIR}/dlio_benchmark"
SCRATCH_DIR="${SCRATCH}dlio_data"
BENCHMARKS=$(ls "${CONFIG_DIR}"/workload | sed 's/\.yaml$//' | xargs -0 -- basename)
MACHINEFILE="nodes.$SLURM_JOB_ID"

srun -l hostname | sort -n | awk '{print $2}' >"$MACHINEFILE"
mkdir -p "$SCRATCH_DIR" "$RESULTS_DIR"

function cleanup() {
    rm -f $MACHINEFILE
}

trap cleanup EXIT SIGINT SIGTERM SIGHUP

function dlio_setup() {
    pushd "$BASE_DIR" || exit 1
    if [ ! -f "$VENV_DIR" ]; then
        python3 -m venv venv
    fi

    source "$VENV_DIR/bin/activate"

    if [ ! -f "$VENV_DIR/bin/dlio_benchmark" ]; then
        pip install -e "$DLIO_DIR"
    fi
    popd || exit 1
}

function dlio_run() {
    pushd "$SCRATCH_DIR" || exit 1
    for bench in $BENCHMARKS; do
        echo "++++++++++++++++++++++Running data generation for: $bench ++++++++++++++++++++++"
        mpirun -np "$SLURM_NTASKS" \
            dlio_benchmark \
	    --config-dir "$CONFIG_DIR" \
            workload="$bench" \
            ++workload.workflow.generate_data=True \
            ++workload.workflow.train=False \
            ++workload.workflow.evaluation=False
        echo "++++++++++++++++++++++Completed data generation for: $bench ++++++++++++++++++++++"

        echo "+++++++++++++++++++++++Running benchmark: $bench ++++++++++++++++++++++"
        mpirun -np "$SLURM_NTASKS" \
            dlio_benchmark \
	    --config-dir "$CONFIG_DIR" \
            workload="$bench" \
            ++workload.workflow.generate_data=False \
            ++workload.workflow.train=True \
            ++workload.workflow.evaluation=True
        echo "+++++++++++++++++++++++Completed benchmark: $bench ++++++++++++++++++++++"

        echo "+++++++++++++++++++++++Copying results for: $bench ++++++++++++++++++++++"
        cp -av "$SCRATCH_DIR/hydra_log/$bench" "$RESULTS_DIR/$bench"
        echo "+++++++++++++++++++++++Completed copying results for: $bench ++++++++++++++++++++++"
    done

    popd || exit 1
}

dlio_setup
dlio_run
