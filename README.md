# I/O Patterns in Deep Learning Workloads

## Structure

```
analysis/io_patterns_analysis.ipynb  # Analysis notebook
results/benchmark_results.csv        # Results data
config/workload/                     # DLIO configurations
doc/paper.pdf                        # Report
```

## Reproducing

### 1. Clone

```bash
git clone --recurse-submodules https://github.com/HpcResearchLaboratory/perf_2025.git
cd perf_2025
```

### 2. Allocate node

```bash
salloc --partition=<partition> --nodes=1 --ntasks=8 --time=4:00:00
```

### 3. Start Jupyter on node

```bash
cd analysis
uv sync
uv run jupyter notebook --no-browser --port=8888
```

### 4. SSH tunnel (from local machine)

```bash
ssh -N -L 8888:localhost:8888 <user>@<login-node>
```

Then open `http://localhost:8888` in browser.

## Dependencies

- Python >= 3.10
- [uv](https://astral.sh/uv)
- MPI
