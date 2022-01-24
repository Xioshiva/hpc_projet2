// NE CHANGEZ PAS CE HEADER !!!
#pragma once
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

// NE CHANGEZ PAS CE PROTOTYPE !!!
float* heat_solver(
  int N, int M, int T, 
  float* north, float* south, float* east, float* west,
  dim3 grid_dim, dim3 block_dim
);


void printMat(float *mat, int M, int N);