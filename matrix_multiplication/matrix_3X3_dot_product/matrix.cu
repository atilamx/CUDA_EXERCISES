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
  int row = 3;
  int col = 3;
  float mul[6];
  float res;
  //Data is not visible to threads in other blocks you idiot!
  for(int i = 0; i < 3; i++){
    //we need to flatten the stupid array 
    //mul[i] = CUDA_A[bid * row + (bid * col) + i] * CUDA_B[ i * row + tid];
    mul[i] = CUDA_A[bid * col + i] * CUDA_B[ i * row + tid];

  }

  res = mul[0] + mul[1] + mul[2];
  
  // Only one kernel should apply the dot product
  __syncthreads();
 
  //CUDA_C[(bid*2) + tid] = local_address[tid];
  //if (bid == 0) { 
    CUDA_C[(bid*3) + tid] = res;
  //}
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
    float A[3][3] = {
      {2.0,5.0,2.0},
      {1.0,2.0,4.0},
      {4.0,2.0,2.0}
    };

    float B[3][3] = {
      {3.0,5.0,3.0},
      {2.0,3.0,5.0},
      {7.0,1.0,3.0}
    };
    
    C = (float *)malloc(3*3*sizeof(float) * N);

    // Allocate device memory
    cudaMalloc((void**)&CUDA_A, sizeof(float) * N);
    cudaMalloc((void**)&CUDA_B, sizeof(float) * N);
    cudaMalloc((void**)&CUDA_C, sizeof(float) * N);

    // Transfer data from host to device memory
    cudaMemcpy(CUDA_A, A, sizeof(float) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(CUDA_B, B, sizeof(float) * N, cudaMemcpyHostToDevice);

    vector_dot_product<<<3,3>>>(CUDA_A, CUDA_B, CUDA_C, N);
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

