#!/bin/sh
#SBATCH --job-name=resMain
#SBATCH --output=resMain.o%j
#SBATCH --partition=shared-gpu
#SBATCH --time=01:00:00
#SBATCH --gpus=1
#SBATCH --nodelist=gpu007

echo $SLURM_NODELIST

srun ./laplace_gpu.out $1 $2 $3