#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>

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

void print_results(float *ARRAY, int array_size){
  printf("[");
  for(int i = 0; i < array_size; i++){
    printf("{");	  
    for(int j = 0; j < array_size; j++){
      printf("%.1f,",ARRAY[(i * array_size) +j]); 
    }	    
    printf("}\n");	  
  }
  printf("]");
  printf("\n");
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

int main(){
    int array_size = 100;
    float *C, *A, *B;
    float *CUDA_A, *CUDA_B,  *CUDA_C; 

    
    A = (float *)malloc(array_size * array_size * sizeof(float));
    B = (float *)malloc(array_size * array_size * sizeof(float));
  
    float a = 5.0;

   for(int i=0;i<20000;i++){
    for(int i = 0; i<(array_size * array_size); i++){
      A[i] = ((float)rand()/(float)(RAND_MAX)) * a;
      B[i] = ((float)rand()/(float)(RAND_MAX)) * a;
    } 

    C = (float *)malloc(array_size * array_size *sizeof(float) );

    // Allocate device memory
    cudaMalloc((void**)&CUDA_A, sizeof(float) * array_size * array_size);
    cudaMalloc((void**)&CUDA_B, sizeof(float) * array_size * array_size);
    cudaMalloc((void**)&CUDA_C, sizeof(float) * array_size * array_size);


       // Transfer data from host to device memory
      cudaMemcpy(CUDA_A, A, sizeof(float) * array_size * array_size, cudaMemcpyHostToDevice);
      cudaMemcpy(CUDA_B, B, sizeof(float) * array_size * array_size, cudaMemcpyHostToDevice);

      vector_dot_product<<<array_size,array_size>>>(CUDA_A, CUDA_B, CUDA_C, array_size);

      cudaMemcpy(C, CUDA_C, sizeof(float) * array_size * array_size, cudaMemcpyDeviceToHost);

      puts("DOT_PRODUCT");
      print_results(A,array_size);
      print_results(B,array_size);
      puts("C VALUE");
      print_results(C,array_size);

      // Deallocate device memory
      cudaFree(CUDA_A);
      cudaFree(CUDA_B);
      cudaFree(CUDA_C);

      free(C);
    }

    
        // Deallocate host memory

}

