# I/O Patterns and Bottlenecks in Deep Learning Workloads

**Author:** Pablo Alessandro Santos Hugen
**Institution:** Institute of Informatics -- UFRGS
**Course:** Computer Systems Performance Analysis 2025/2

## Overview

This repository contains the experimental setup and analysis for studying I/O patterns and bottlenecks in deep learning workloads using the [DLIO Benchmark](https://github.com/argonne-lcf/dlio_benchmark).

The entire workflow (benchmarking + analysis) is controlled from a single **Jupyter notebook** using a literate programming approach.

## Repository Structure

```
.
├── analysis/
│   ├── experimental_design.csv      # Factorial experiment design (CSV)
│   ├── io_patterns_analysis.ipynb   # Main notebook (benchmark + analysis)
│   └── pyproject.toml               # Analysis dependencies (uv)
├── config/
│   └── workload/                    # DLIO workload configurations
│       ├── cosmoflow_h100_custom.yaml
│       ├── default_custom.yaml
│       ├── dlrm_custom.yaml
│       └── unet3d_h100_custom.yaml
├── dlio_benchmark/                  # DLIO benchmark (git submodule)
├── results/                         # Benchmark results (summary.json files)
├── pyproject.toml                   # Benchmark dependencies (uv)
└── README.md
```

## Prerequisites

- Python >= 3.10
- [uv](https://docs.astral.sh/uv/) package manager
- MPI implementation (OpenMPI, MPICH, etc.)

## Quick Start

### 1. Clone the Repository

```bash
git clone --recurse-submodules https://github.com/HpcResearchLaboratory/perf_2025.git
cd perf_2025
```

### 2. Install uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

### 3. Allocate an Interactive Node

```bash
salloc --partition=<your-partition> --nodes=1 --ntasks=8 --time=4:00:00
```

### 4. Launch Jupyter on the Allocated Node

```bash
cd analysis
uv sync
uv run jupyter notebook io_patterns_analysis.ipynb
```


### Experimental Design (CSV)

The file `analysis/experimental_design.csv` defines all experiments:

```csv

...
```

- `run=N` - Pending experiment
- `run=Y` - Completed experiment

The notebook automatically updates this file as benchmarks complete.

## Experimental Design

| Model | Framework | Epochs | Processes |
|-------|-----------|--------|-----------|
| cosmoflow_h100_custom | TensorFlow | 1 | 1, 2, 4, 6, 8 |
| default_custom | PyTorch | 10 | 1, 2, 4, 6, 8 |
| dlrm_custom | PyTorch | 3 | 1, 2, 4, 6, 8 |
| unet3d_h100_custom | PyTorch | 5 | 1, 2, 4, 6, 8 |

**Response Variables:**
- Accelerator Usage (AU) - percentage
- I/O Throughput (MB/s)

## Configuration

Edit the configuration cell in the notebook to match your cluster:

```python
MODULES = ["your-gpu-module", "your-mpi-module"]
MODULES = None
```

## Troubleshooting

### uv not found

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

### Submodule not initialized

```bash
git submodule update --init --recursive
```

### MPI errors

Ensure MPI is loaded/installed:

```bash
module load openmpi
mpirun --version
```

### Permission denied on results

```bash
chmod -R u+rw results/
```

## References

1. Devarajan, H. et al. (2021). "DLIO: A Data-Centric Benchmark for Scientific Deep Learning Applications." IEEE IPDPS.
2. Chowdhury, N. et al. (2023). "I/O for Machine Learning Applications on HPC Systems."
3. Patel, T. et al. (2023). "Characterizing ML I/O Workloads on Leadership Supercomputers." SC23.

## License

This project is for academic purposes as part of the Computer Systems Performance Analysis course at UFRGS.
