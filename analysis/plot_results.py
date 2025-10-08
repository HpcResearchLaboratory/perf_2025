import json
import matplotlib.pyplot as plt
import pandas as pd
import glob
import os

def main():
    data = []
    for file_path in glob.glob("results/**/summary.json", recursive=True):
        with open(file_path, "r") as f:
            summary = json.load(f)
            model_name = file_path.split("/")[1]
            num_accelerators = summary["num_accelerators"]
            au = summary["metric"]["train_au_mean_percentage"]
            au_std = summary["metric"]["train_au_stdev_percentage"]
            io_throughput = summary["metric"]["train_io_mean_MB_per_second"]
            io_throughput_std = summary["metric"]["train_io_stdev_MB_per_second"]
            data.append([model_name, num_accelerators, au, au_std, io_throughput, io_throughput_std])

    df = pd.DataFrame(data, columns=["model", "processes", "accelerator_usage", "accelerator_usage_std", "io_throughput", "io_throughput_std"])
    df = df.sort_values(by=["model", "processes"])

    plt.figure(figsize=(10, 6))
    for model in df["model"].unique():
        model_df = df[df["model"] == model]
        plt.errorbar(model_df["processes"], model_df["accelerator_usage"], yerr=model_df["accelerator_usage_std"], marker='o', label=model, capsize=5)
    plt.title("Accelerator Usage vs. Number of Processes")
    plt.xlabel("Number of Processes")
    plt.ylabel("Accelerator Usage (%)")
    plt.grid(True)
    plt.legend()
    plt.savefig("accelerator_usage_with_std.png")
    plt.close()

    plt.figure(figsize=(10, 6))
    for model in df["model"].unique():
        model_df = df[df["model"] == model]
        plt.errorbar(model_df["processes"], model_df["io_throughput"], yerr=model_df["io_throughput_std"], marker='o', label=model, capsize=5)
    plt.title("I/O Throughput vs. Number of Processes")
    plt.xlabel("Number of Processes")
    plt.ylabel("I/O Throughput (MB/s)")
    plt.grid(True)
    plt.legend()
    plt.savefig("io_throughput_with_std.png")
    plt.close()

if __name__ == "__main__":
    main()
