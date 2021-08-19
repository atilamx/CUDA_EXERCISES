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
  for(int i = 0 ; i < 20; i++){
    printf("%f,",C[i]);
  }
  printf("]\n");
}

__global__ void vector_dot_product(float *CUDA_A, float *CUDA_B, float *CUDA_C,int n) {
  int tid = threadIdx.x;
  int bid = blockIdx.x;
  __shared__ float SHARED_SUM[4];
  extern __shared__ float SHARED_PRODUCTS[4];
  int row = n;
  int col = n;
  int index = n;
  float *mul = (float *)malloc(sizeof(float) * n);
  float res;
  //Data is not visible to threads in other blocks you idiot!
  for(int i = 0; i < n; i++){
    //we need to flatten the stupid array 
    mul[i] = CUDA_A[bid * col + i] * CUDA_B[ i * row + tid];
  }
  //aggregate all the multiplications a11*b11 + .. + ann*bnn 
  for(int j = 0;j<n;j++){
    res += mul[j];
  }
  
  __syncthreads();
 
  CUDA_C[(bid*n) + tid] = res;
}

void print_vectors(){
  printf("A=[{2.0,5.0,2.0}\n");
  printf("   {1.0,2.0,4.0}]\n");
  printf("   {4.0,2.0,2.0}]\n");
  printf("B=[{3.0,5.0,3.0}\n");
  printf("   {2.0,3.0,5.0}]\n");
  printf("   {7.0,1.0,3.0}]\n");
};

int main(){
    float *C;
    float *CUDA_A, *CUDA_B,  *CUDA_C; 

    // Allocate host memory
    float A[4][4] = {
      {2,5,3,4},
      {1,2,3,2},
      {1,3,4,2},
      {1,3,4,4}
    };

    float B[4][4] = {
      {3,5,3,2},
      {2,3,2,3},
      {2,2,3,2},
      {2,2,2,3}
    };
    
    C = (float *)malloc(8*8*sizeof(float) * N);

    // Allocate device memory
    cudaMalloc((void**)&CUDA_A, sizeof(float) * N);
    cudaMalloc((void**)&CUDA_B, sizeof(float) * N);
    cudaMalloc((void**)&CUDA_C, sizeof(float) * N);

    // Transfer data from host to device memory
    cudaMemcpy(CUDA_A, A, sizeof(float) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(CUDA_B, B, sizeof(float) * N, cudaMemcpyHostToDevice);
    vector_dot_product<<<4,4>>>(CUDA_A, CUDA_B, CUDA_C, 4);
    cudaMemcpy(C, CUDA_C, sizeof(float) * 500, cudaMemcpyDeviceToHost);
    puts("DOT_PRODUCT");
    print_vectors();
    print_results(C);


    //printf("\nDot product result %f\n", *K);
    // Deallocate device memory
    cudaFree(CUDA_A);
    cudaFree(CUDA_B);
    cudaFree(CUDA_C);

    // Deallocate host memory
    //free(A); 
    //free(B); 
    free(C);
}

