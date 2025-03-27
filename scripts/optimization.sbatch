#!/bin/bash

#SBATCH -q nvidia-xxl
#SBATCH -p nvidia
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:a100:1
#SBATCH --time=71:59:59
#SBATCH --mem=80GB

# Define start and end indices
START_IDX=1
END_IDX=520

# Set job name dynamically
#SBATCH --job-name=${START_IDX}-${END_IDX}

module purge

# Load the Conda module
source ~/.bashrc

# Activate conda environment
conda activate kovjl

# Print variables for debugging
echo "Running experiment with benchmark indices from $START_IDX to $END_IDX"

# Call Julia script with arguments
julia optimization_experiments.jl $START_IDX $END_IDX