#!/bin/bash
#SBATCH --job-name=dlio_bench
#SBATCH --nodes=1
#SBATCH --time=10:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

set -e

BASE_DIR=${SLURM_SUBMIT_DIR}
VENV_DIR="${BASE_DIR}/venv"
CONFIG_DIR="${BASE_DIR}/config"
RESULTS_DIR="${BASE_DIR}/results"
DLIO_DIR="${BASE_DIR}/dlio_benchmark"
SCRATCH_DIR="${BASE_DIR}/dlio_data_${SLURM_JOB_ID}"
BENCHMARKS=$(ls "${CONFIG_DIR}"/workload | sed 's/\.yaml$//' | xargs -0 -- basename)
MACHINEFILE="nodes.$SLURM_JOB_ID"
TASK_COUNTS=(1 2 4 6 8)

module load arch_gpu_sc/current openmpi/4.1.6.15.1

srun -l hostname | sort -n | awk '{print $2}' >"$MACHINEFILE"
mkdir -p "$SCRATCH_DIR" "$RESULTS_DIR"

function cleanup() {
    echo "Cleaning up resources..."
    rm -f "$MACHINEFILE"
    rm -rf "$SCRATCH_DIR"
    echo "Cleanup complete."
}
trap cleanup EXIT SIGINT SIGTERM SIGHUP

function dlio_setup() {
    pushd "$BASE_DIR" || exit 1
    if [ ! -d "$VENV_DIR" ]; then
        echo "Creating Python virtual environment..."
        python3 -m venv venv
    fi

    source "$VENV_DIR/bin/activate"

    if [ ! -f "$VENV_DIR/bin/dlio_benchmark" ]; then
        echo "Installing dlio_benchmark..."
        pushd "$DLIO_DIR" || exit 1
        pip install .
        popd || exit 1
    fi
    popd || exit 1
}

function dlio_run() {
    pushd "$SCRATCH_DIR" || exit 1
    
    for ntasks in "${TASK_COUNTS[@]}"; do
        for bench in $BENCHMARKS; do
            echo "======================================================================"
            echo "Starting benchmark: $bench with $ntasks tasks"
            echo "======================================================================"

            echo "--> Step 1: Generating data for $bench..."
            mpirun -np "$ntasks" \
                dlio_benchmark \
                --config-dir "$CONFIG_DIR" \
                workload="$bench" \
                ++workload.workflow.generate_data=True \
                ++workload.workflow.train=False \
                ++workload.workflow.evaluation=False

            echo "--> Step 2: Running benchmark for $bench..."
            mpirun -np "$ntasks" \
                dlio_benchmark \
                --config-dir "$CONFIG_DIR" \
                workload="$bench" \
                ++workload.workflow.generate_data=False \
                ++workload.workflow.train=True \
                ++workload.workflow.evaluation=True

            echo "--> Step 3: Copying results for $bench with $ntasks tasks..."
            mkdir -p "$RESULTS_DIR/$bench/$ntasks"
            cp -av "$SCRATCH_DIR/hydra_log/$bench"/* "$RESULTS_DIR/$bench/$ntasks/"
            rm -rf "$SCRATCH_DIR/hydra_log/$bench"
            
            echo "--> Completed benchmark run for: $bench with $ntasks tasks."
        done
    done

    popd || exit 1
}

echo "Starting DLIO benchmark suite."
dlio_setup
dlio_run
echo "Benchmark suite finished successfully."
