#include <cstdio>

#define gpuErrchk(ans)                    \
  {                                       \
    gpuAssert((ans), __FILE__, __LINE__); \
  }

inline void gpuAssert(
    cudaError_t code,
    const char *file,
    int line)
{
  if (code != cudaSuccess)
  {
    fprintf(
        stderr, "GPUassert: %s %s %d\n",
        cudaGetErrorString(code), file, line);
  }
}

__global__ void dummy_kernel(float *domain, float *res, int N, int M)
{
  int rows = blockIdx.y * blockDim.y + threadIdx.y;
  int cols = blockIdx.x * blockDim.x + threadIdx.x;

  if (rows > 0 && cols > 0 && rows < N - 1 && cols < M - 1)
  {
    res[rows * M + cols] = 0.25 * (domain[rows * M + cols - 1] + domain[rows * M + cols + 1] + domain[(rows - 1) * M + cols] + domain[(rows + 1) * M + cols]);
  }
}

void printMat(float *mat, int M, int N)
{
  for (int i = 0; i < M * N; i++)
  {
    printf("%.3f ", mat[i]);
    if (!((i + 1) % M) && i != 0)
      printf("\n");
  }
}

// NE CHANGEZ PAS CETTE SIGNATURE ET NE DEPLACEZ PAS CETTE FONCTION !!!
float *heat_solver(
    int N, int M, int T,
    float *north, float *south,
    float *east, float *west,
    dim3 grid_dim, dim3 block_dim)
{
  if (!T)
    T = 1;
  const size_t n_bytes = sizeof(float) * (M * N);
  float *matrix = (float *)malloc(sizeof(float) * (N * M));
  for (int i = 0; i < M; i++)
  {
    matrix[i] = north[i];
    matrix[(N - 1) * M + i] = south[i];
  }
  for (int i = 0; i < N - 2; i++)
  {
    matrix[(i + 1) * M] = west[i];
    matrix[(i + 2) * M - 1] = east[i];
  }

  float *res = (float *)malloc(sizeof(float) * (N * M));
  for (int i = 0; i < M; i++)
  {
    res[i] = north[i];
    res[(N - 1) * M + i] = south[i];
  }
  for (int i = 0; i < N - 2; i++)
  {
    res[(i + 1) * M] = west[i];
    res[(i + 2) * M - 1] = east[i];
  }
  float *d_domain;
  float *d_res;
  gpuErrchk(cudaMalloc(&d_domain, n_bytes));
  gpuErrchk(cudaMalloc(&d_res, n_bytes));
  gpuErrchk(cudaMemcpy(d_domain, matrix, n_bytes, cudaMemcpyHostToDevice));
  gpuErrchk(cudaMemcpy(d_res, res, n_bytes, cudaMemcpyHostToDevice));

  cudaEvent_t start, stop;
  gpuErrchk(cudaEventCreate(&start));
  gpuErrchk(cudaEventCreate(&stop));

  cudaEventRecord(start);
  for (int i = 0; i < T; i++)
  {
    dummy_kernel<<<grid_dim, block_dim>>>(d_domain, d_res, N, M);
    gpuErrchk(cudaDeviceSynchronize());
    float *tmp = d_res;
    d_res = d_domain;
    d_domain = tmp;
  }
  gpuErrchk(cudaEventRecord(stop));
  gpuErrchk(cudaEventSynchronize(stop));
  float milliseconds = 0;
  gpuErrchk(cudaEventElapsedTime(&milliseconds, start, stop));
  printf("T=%d N=%d M=%d %f ms\n", T, N, M, milliseconds);
  gpuErrchk(cudaMemcpy(matrix, d_domain, n_bytes, cudaMemcpyDeviceToHost));
  // printMat(matrix,M, N);
  gpuErrchk(cudaFree(d_domain));
  gpuErrchk(cudaFree(d_res));
  free(res);
  return matrix;
}
