#!/bin/bash
#SBATCH --job-name=dlio_bench
#SBATCH --partition=poti
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --time=10:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

BASE_DIR=${SLURM_SUBMIT_DIR}
VENV_DIR="${BASE_DIR}/venv"
CONFIG_DIR="${BASE_DIR}/config"

if [! -f "$VENV_DIR" ] then
  python3 -m venv venv
fi

source $HOME/dlio_benchmark/dlio-venv/bin/activate

MACHINEFILE="nodes.$SLURM_JOB_ID"
srun -l hostname | sort -n | awk '{print $2}' > $MACHINEFILE
 
mpirun -np $SLURM_NTASKS \
	dlio_benchmark \
    	  workload=default \
    	  ++workload.workflow.generate_data=False \
    	  ++workload.workflow.train=True \
    	  ++workload.workflow.evaluation=True
      
