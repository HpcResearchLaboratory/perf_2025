import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Read data
df = pd.read_csv('../results/benchmark_results.csv')

# Create figure with two subplots
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Prepare data for grouped bar chart
categories = {
    'Process\nScaling': df[df['Parameter'] == 'baseline'][['Value', 'Procs', 'AU (%)', 'I/O (MB/s)']].copy(),
    'Data\nFormat': df[df['Parameter'] == 'format'][['Value', 'AU (%)', 'I/O (MB/s)']].copy(),
    'Read\nThreads': df[df['Parameter'] == 'read'][['Value', 'AU (%)', 'I/O (MB/s)']].copy(),
    'Batch\nSize': df[df['Parameter'] == 'batch'][['Value', 'AU (%)', 'I/O (MB/s)']].copy(),
    'Shuffling': df[df['Parameter'].isin(['file', 'sample'])][['Parameter', 'Value', 'AU (%)', 'I/O (MB/s)']].copy(),
    'Record\nSize': df[df['Parameter'] == 'record'][['Value', 'AU (%)', 'I/O (MB/s)']].copy(),
}

# Flatten data for plotting
au_data = []
io_data = []
labels = []

# Process scaling
for _, row in categories['Process\nScaling'].iterrows():
    labels.append(f"{int(row['Procs'])} proc")
    au_data.append(row['AU (%)'])
    io_data.append(row['I/O (MB/s)'])

# Add separator
labels.append('')
au_data.append(0)
io_data.append(0)

# Data format
format_map = {'png': 'PNG', 'hdf5': 'HDF5'}
# Add NPZ baseline
baseline_4proc = df[(df['Parameter'] == 'baseline') & (df['Procs'] == 4)].iloc[0]
labels.append('NPZ')
au_data.append(baseline_4proc['AU (%)'])
io_data.append(baseline_4proc['I/O (MB/s)'])
for _, row in categories['Data\nFormat'].iterrows():
    labels.append(format_map.get(row['Value'], row['Value']))
    au_data.append(row['AU (%)'])
    io_data.append(row['I/O (MB/s)'])

# Add separator
labels.append('')
au_data.append(0)
io_data.append(0)

# Read threads
thread_order = ['threads_1', 'threads_8', 'threads_16']
thread_labels = {'threads_1': '1 thr', 'threads_8': '8 thr', 'threads_16': '16 thr'}
for t in thread_order:
    row = categories['Read\nThreads'][categories['Read\nThreads']['Value'] == t]
    if not row.empty:
        row = row.iloc[0]
        labels.append(thread_labels[t])
        au_data.append(row['AU (%)'])
        io_data.append(row['I/O (MB/s)'])

# Add separator
labels.append('')
au_data.append(0)
io_data.append(0)

# Batch size
batch_order = ['size_1', 'size_4', 'size_14']
batch_labels = {'size_1': 'batch 1', 'size_4': 'batch 4', 'size_14': 'batch 14'}
for b in batch_order:
    row = categories['Batch\nSize'][categories['Batch\nSize']['Value'] == b]
    if not row.empty:
        row = row.iloc[0]
        labels.append(batch_labels[b])
        au_data.append(row['AU (%)'])
        io_data.append(row['I/O (MB/s)'])

# Add separator
labels.append('')
au_data.append(0)
io_data.append(0)

# Record size
record_labels = {'length_bytes_10485760': '10 MB', 'length_bytes_536870912': '512 MB'}
for _, row in categories['Record\nSize'].iterrows():
    labels.append(record_labels.get(row['Value'], row['Value']))
    au_data.append(row['AU (%)'])
    io_data.append(row['I/O (MB/s)'])

# Plot AU
x = np.arange(len(labels))
colors = ['#2ecc71' if v > 80 else '#3498db' if v > 50 else '#e74c3c' for v in au_data]
bars1 = axes[0].bar(x, au_data, color=colors, edgecolor='black', linewidth=0.5)
axes[0].set_ylabel('Accelerator Utilization (%)', fontsize=11)
axes[0].set_title('Accelerator Utilization by Configuration', fontsize=12, fontweight='bold')
axes[0].set_xticks(x)
axes[0].set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
axes[0].set_ylim(0, 105)
axes[0].axhline(y=90, color='green', linestyle='--', alpha=0.5, label='90% target')
axes[0].grid(axis='y', alpha=0.3)

# Plot I/O
io_data_gb = [v/1000 for v in io_data]  # Convert to GB/s
colors_io = ['#2ecc71' if v > 8 else '#3498db' if v > 4 else '#e74c3c' for v in io_data_gb]
bars2 = axes[1].bar(x, io_data_gb, color=colors_io, edgecolor='black', linewidth=0.5)
axes[1].set_ylabel('I/O Throughput (GB/s)', fontsize=11)
axes[1].set_title('I/O Throughput by Configuration', fontsize=12, fontweight='bold')
axes[1].set_xticks(x)
axes[1].set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
axes[1].set_ylim(0, 12)
axes[1].grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('accelerator_usage.png', dpi=150, bbox_inches='tight')
plt.savefig('io_throughput.png', dpi=150, bbox_inches='tight')

# Also save individual plots
fig1, ax1 = plt.subplots(figsize=(10, 5))
colors = ['#2ecc71' if v > 80 else '#3498db' if v > 50 else '#e74c3c' for v in au_data]
ax1.bar(x, au_data, color=colors, edgecolor='black', linewidth=0.5)
ax1.set_ylabel('Accelerator Utilization (%)', fontsize=11)
ax1.set_title('Accelerator Utilization by Configuration', fontsize=12, fontweight='bold')
ax1.set_xticks(x)
ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
ax1.set_ylim(0, 105)
ax1.axhline(y=90, color='green', linestyle='--', alpha=0.5)
ax1.grid(axis='y', alpha=0.3)
plt.tight_layout()
plt.savefig('accelerator_usage.png', dpi=150, bbox_inches='tight')
plt.close()

fig2, ax2 = plt.subplots(figsize=(10, 5))
ax2.bar(x, io_data_gb, color=colors_io, edgecolor='black', linewidth=0.5)
ax2.set_ylabel('I/O Throughput (GB/s)', fontsize=11)
ax2.set_title('I/O Throughput by Configuration', fontsize=12, fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
ax2.set_ylim(0, 12)
ax2.grid(axis='y', alpha=0.3)
plt.tight_layout()
plt.savefig('io_throughput.png', dpi=150, bbox_inches='tight')
plt.close()

print("Plots saved: accelerator_usage.png, io_throughput.png")
