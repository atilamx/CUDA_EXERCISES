#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>

#define N 512
#define MAX_ERR 1e-6

//__global__ void vector_add(float *out, float *a, float *b, int n) {
//   int stride = 1;	
//   int tid = blockIdx.x * blockDim.x + threadIdx.x;
           //  0        *    256     +    1 = 1  | BLOCK0 |  
           //  0        *    256     +    2 = 2 

           //  1        *    256     +    1 = 257 | BLOCK1 |   
           //  1        *    256     +    2 = 258

//   out[tid] = a[tid] + b[tid];   
//}

void print_results(float *C){
  printf("[");
  for(int i = 0 ; i < 4; i++){
    printf("%f,",C[i]);
  }
  printf("]\n");
}

__global__ void vector_add(float *CUDA_A, float *CUDA_B, float *CUDA_C, int n) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  CUDA_C[tid] = CUDA_A[tid] + CUDA_B[tid];   
}

__global__ void vector_sub(float *CUDA_A, float *CUDA_B, float *CUDA_C, int n) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  CUDA_C[tid] = CUDA_A[tid] - CUDA_B[tid];
}

__global__ void vector_dot_product(float *CUDA_A, float *CUDA_B, float *CUDA_C,float *CUDA_K, int n) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;
  __shared__ float SHARED_K[1024];

  CUDA_C[tid] = CUDA_A[tid] * CUDA_B[tid];	
  // Only one kernel should apply the dot product
  __syncthreads();

  SHARED_K[tid] = CUDA_C[tid * 2] + CUDA_C[tid * 2 + 1];

  __syncthreads();
  if (tid == 0){
    *CUDA_K = SHARED_K[0] + SHARED_K[1]; 
  }
}

void print_vectors(){
  printf("A = {2.0,4.0,6.0,8.0}\n");
  printf("B = {1.0,2.0,3.0,10.0}\n");
};

int main(){
    float *C, *K;
    float *CUDA_A, *CUDA_B, *CUDA_C, *CUDA_K; 

    // Allocate host memory
    float A[4]= {2.0,4.0,6.0,10.0};
    float B[4]= {1.0,2.0,3.0,8.0};
    
    C = (float*)malloc(sizeof(float) * N);
    K = (float*)malloc(sizeof(float));

    // Allocate device memory
    cudaMalloc((void**)&CUDA_A, sizeof(float) * N);
    cudaMalloc((void**)&CUDA_B, sizeof(float) * N);
    cudaMalloc((void**)&CUDA_C, sizeof(float) * N);
    cudaMalloc((void**)&CUDA_C, sizeof(float) * N);
    cudaMalloc((void**)&CUDA_K, sizeof(float));

    // Transfer data from host to device memory
    cudaMemcpy(CUDA_A, A, sizeof(float) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(CUDA_B, B, sizeof(float) * N, cudaMemcpyHostToDevice);

    // Executing kernel 
    vector_add<<<1,4>>>(CUDA_A, CUDA_B, CUDA_C, N);
    cudaMemcpy(C, CUDA_C, sizeof(float) * N, cudaMemcpyDeviceToHost);

    //Executing kernel 
    puts("ADDING");
    print_vectors();
    print_results(C);

    vector_sub<<<1,4>>>(CUDA_A, CUDA_B, CUDA_C, N);
    cudaMemcpy(C, CUDA_C, sizeof(float) * N, cudaMemcpyDeviceToHost);
    puts("SUBSTRACTING");
    print_vectors();
    print_results(C);

    vector_dot_product<<<1,4>>>(CUDA_A, CUDA_B, CUDA_C, CUDA_K, N);
    cudaMemcpy(C, CUDA_C, sizeof(float) * N, cudaMemcpyDeviceToHost);
    puts("DOT_PRODUCT");
    print_vectors();

    print_results(C);

    cudaMemcpy(K, CUDA_K, sizeof(float), cudaMemcpyDeviceToHost);

    printf("\nDot product result %f\n", *K);
    // Deallocate device memory
    cudaFree(CUDA_A);
    cudaFree(CUDA_B);
    cudaFree(CUDA_C);

    // Deallocate host memory
    //free(A); 
    //free(B); 
    free(C);
}

