#!/bin/bash

#SBATCH -q nvidia-xxl
#SBATCH -p nvidia
#SBATCH -C 80g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:a100:1
#SBATCH --time=71:59:59
#SBATCH --mem=50GB
#SBATCH --job-name=example

module purge

# Load the Conda module
source ~/.bashrc

# Activate conda environment
conda activate kovjl

# Call Julia script
julia example.jl