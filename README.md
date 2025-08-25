# sscad 2025
 
## dlio tests

### Default
 
Data generation: 

```bash
mpirun -np 8 \
    dlio_benchmark \
        --config-dir ./config \
        workload=default_custom \
        ++workload.workflow.generate_data=True \
        ++workload.workflow.train=False \
        ++workload.workflow.evaluation=False
```

Benchmark:

```bash
mpirun -np 8 \
    dlio_benchmark \
        --config-dir ./config \
        workload=default_custom \
        ++workload.workflow.generate_data=False \
        ++workload.workflow.train=True \
        ++workload.workflow.evaluation=True

```

### unet3d

Data generation: 

```bash
mpirun -np 8 \
    dlio_benchmark \
        --config-dir ./config \
        workload=unet3d_h100_custom \
        ++workload.workflow.generate_data=True \
        ++workload.workflow.train=False \
        ++workload.workflow.evaluation=False
```

Benchmark:

```bash
mpirun -np 8 \
    dlio_benchmark \
        --config-dir ./config \
        workload=unet3d_h100_custom \
        ++workload.workflow.generate_data=False \
        ++workload.workflow.train=True \
        ++workload.workflow.evaluation=True
```

### Megatron deepspeed LNLL

Data generation: 

```bash
mpirun -np 8 \
    dlio_benchmark \
        --config-dir ./config \
        workload=megatron_deepspeed_LLNL_custom \
        ++workload.workflow.generate_data=True \
        ++workload.workflow.train=False \
        ++workload.workflow.evaluation=False
```

Benchmark:

```bash
mpirun -np 8 \
    dlio_benchmark \
        --config-dir ./config \
        workload=megatron_deepspeed_LLNL_custom \
        ++workload.workflow.generate_data=False \
        ++workload.workflow.train=True \
        ++workload.workflow.evaluation=True
```

### Cosmoflow

Data generation: 

```bash
mpirun -np 8 \
    dlio_benchmark \
        --config-dir ./config \
        workload=cosmoflow_h100_custom \
        ++workload.workflow.generate_data=True \
        ++workload.workflow.train=False \
        ++workload.workflow.evaluation=False
```

Benchmark:

```bash
mpirun -np 8 \
    dlio_benchmark \
        --config-dir ./config \
        workload=cosmoflow_h100_custom \
        ++workload.workflow.generate_data=False \
        ++workload.workflow.train=True \
        ++workload.workflow.evaluation=True
```

