#include <cstdio>
#include <time.h>
#include "laplace_solver.cuh"

int main(int argc, char *argv[])
{
  // vous pouvez remplacer l'instruction suivante, elle est uniquement
  // présente pour que la démo/squelette compile/fonctionne
  const size_t N = atoi(argv[1]), M = atoi(argv[2]), T = atoi(argv[3]);
  float *north = (float *)malloc(sizeof(float) * M);
  float *south = (float *)malloc(sizeof(float) * M);
  float *east = (float *)malloc(sizeof(float) * (N - 2));
  float *west = (float *)malloc(sizeof(float) * (N - 2));
  for(int i = 0; i < M; i++){
    north[i] = 1.0;
    south[i] = 1.0;
  }
  for(int i = 0; i < N-2; i++){
    east[i] = 1.0;
    west[i] = 1.0;
  }
  float *heated = heat_solver(
      N, M, T,
      north, south, east, west,
      dim3(N/32 + 1,M/32 + 1 , 1), dim3(32, 32, 1));
  return 0;
}
