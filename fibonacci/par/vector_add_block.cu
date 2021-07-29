#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>

#define N 64
#define MAX_ERR 1e-6

__global__ void vector_add(float *out, float *a, float *b, int power) {
  //int stride = 1;	
  int tid = blockIdx.x * blockDim.x + threadIdx.x;
           //  0        *    256     +    1 = 1  | BLOCK0 |  
           //  0        *    256     +    2 = 2 

           //  1        *    256     +    1 = 257 | BLOCK1 |   
           //  1        *    256     +    2 = 258

  //out[tid] = a[tid] + b[tid];  
  float golden = 1.61803398875;	
  
  float golden_to_power = pow(golden,power);
  float golden_minus_one_to_power = pow((1 - golden),power); 

  out[tid] = golden_to_power - golden_minus_one_to_power;
}

int main(){
    float *a, *b, *out;
    float *d_a, *d_b, *d_out; 

    // Allocate host memory
    a   = (float*)malloc(sizeof(float) * N);
    b   = (float*)malloc(sizeof(float) * N);
    out = (float*)malloc(sizeof(float) * N);


    // Allocate device memory
    cudaMalloc((void**)&d_a, sizeof(float) * N);
    cudaMalloc((void**)&d_b, sizeof(float) * N);
    cudaMalloc((void**)&d_out, sizeof(float) * N);

    // Executing kernel 
    int power = 100;
    vector_add<<<1,1>>>(d_out, d_a, d_b, power);
    
    // Transfer data back to host memory
    cudaMemcpy(out, d_out, sizeof(float) * N, cudaMemcpyDeviceToHost);

    float result = out[0]/2.23606797749979;
    printf("out[0] = %lF\n", result);
    //printf("PASSED\n");

    // Deallocate device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_out);

    // Deallocate host memory
    free(a); 
    free(b); 
    free(out);
}
