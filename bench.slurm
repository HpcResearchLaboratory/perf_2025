#!/bin/bash
#SBATCH --job-name=dlio_bench
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --time=10:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

###############################################################################
# CONFIGURATION - Modify these variables for your cluster
###############################################################################

# SLURM partition (override with: sbatch --partition=<name> bench.slurm)
#SBATCH --partition=lncc-gh200

# Environment modules to load (space-separated)
# Set to empty string if not using modules
MODULES="arch_gpu_sc/current openmpi/4.1.6.15.1"

# Task counts to benchmark
TASK_COUNTS=(1 2 4 6 8)

###############################################################################
# END CONFIGURATION
###############################################################################

set -e

BASE_DIR=${SLURM_SUBMIT_DIR:-$(pwd)}
CONFIG_DIR="${BASE_DIR}/config"
RESULTS_DIR="${BASE_DIR}/results"
DLIO_DIR="${BASE_DIR}/dlio_benchmark"
SCRATCH_DIR="${BASE_DIR}/dlio_data_${SLURM_JOB_ID:-$$}"
BENCHMARKS=$(ls "${CONFIG_DIR}"/workload | sed 's/\.yaml$//')
MACHINEFILE="nodes.${SLURM_JOB_ID:-$$}"

# Load modules if specified
if [ -n "$MODULES" ]; then
    echo "Loading modules: $MODULES"
    module load $MODULES
fi

# Create machine file for MPI (only in SLURM environment)
if [ -n "$SLURM_JOB_ID" ]; then
    srun -l hostname | sort -n | awk '{print $2}' >"$MACHINEFILE"
fi

mkdir -p "$SCRATCH_DIR" "$RESULTS_DIR"

function cleanup() {
    echo "Cleaning up resources..."
    rm -f "$MACHINEFILE"
    rm -rf "$SCRATCH_DIR"
    echo "Cleanup complete."
}
trap cleanup EXIT SIGINT SIGTERM SIGHUP

function check_uv() {
    if ! command -v uv &> /dev/null; then
        echo "ERROR: uv is not installed."
        echo "Install it with: curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
}

function dlio_setup() {
    echo "Setting up DLIO benchmark with uv..."
    pushd "$BASE_DIR" || exit 1

    # Sync dependencies (installs dlio_benchmark from submodule)
    uv sync

    popd || exit 1
}

function dlio_run() {
    pushd "$SCRATCH_DIR" || exit 1

    echo "======================================================================"
    echo "STEP 1: Data Generation"
    echo "======================================================================"
    for bench in $BENCHMARKS; do
        echo "--> Generating data for: $bench using $SLURM_NTASKS tasks..."
        mpirun -np "${SLURM_NTASKS:-8}" \
            uv run --project "$BASE_DIR" dlio_benchmark \
            --config-dir "$CONFIG_DIR" \
            workload="$bench" \
            ++workload.workflow.generate_data=True \
            ++workload.workflow.train=False \
            ++workload.workflow.evaluation=False
        echo "--> Data generation complete for: $bench"
    done

    echo "======================================================================"
    echo "STEP 2: Benchmark Runs"
    echo "======================================================================"
    for ntasks in "${TASK_COUNTS[@]}"; do
        for bench in $BENCHMARKS; do
            echo "----------------------------------------------------------------------"
            echo "Running benchmark: $bench with $ntasks tasks"
            echo "----------------------------------------------------------------------"

            mpirun -np "$ntasks" \
                uv run --project "$BASE_DIR" dlio_benchmark \
                --config-dir "$CONFIG_DIR" \
                workload="$bench" \
                ++workload.workflow.generate_data=False \
                ++workload.workflow.train=True \
                ++workload.workflow.evaluation=True

            echo "--> Copying results for $bench with $ntasks tasks..."
            mkdir -p "$RESULTS_DIR/$bench/$ntasks"
            cp -av "$SCRATCH_DIR/hydra_log/$bench"/* "$RESULTS_DIR/$bench/$ntasks/"
            rm -rf "$SCRATCH_DIR/hydra_log/$bench"

            echo "--> Completed benchmark run for: $bench with $ntasks tasks"
        done
    done

    popd || exit 1
}

echo "======================================================================"
echo "DLIO Benchmark Suite"
echo "======================================================================"
echo "Base directory: $BASE_DIR"
echo "Config directory: $CONFIG_DIR"
echo "Results directory: $RESULTS_DIR"
echo "Benchmarks: $BENCHMARKS"
echo "Task counts: ${TASK_COUNTS[*]}"
echo "======================================================================"

check_uv
dlio_setup
dlio_run

echo "Benchmark suite finished successfully."
