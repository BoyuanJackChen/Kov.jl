#!/bin/bash

#SBATCH -q nvidia-xxl
#SBATCH -p nvidia
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:a100:1
#SBATCH --time=71:59:59
#SBATCH --mem=80GB
#SBATCH --job-name=exp

module purge

# Load the Conda module
source ~/.bashrc

# Activate conda environment
conda activate kovjl

# Call Julia script
julia experiments.jl