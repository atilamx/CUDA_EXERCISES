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
int calculate_no_threads(int array_size){
  if(array_size/256 < 1){
    return 1;  
  } else {
    return array_size/256;
  }
}

void print_results(float *ARRAY, int array_size){
  printf("[");
  for(int i = 0; i < array_size; i++){
    printf("{");	  
    for(int j = 0; j < array_size; j++){
      printf("%1.1f,",ARRAY[(i * array_size) +j]); 
    }	    
    printf("}\n");	  
  }
  printf("]");
  printf("\n");
}

__global__ void vector_dot_product(float *CUDA_A, float *CUDA_B, float *CUDA_C,float *CUDA_T,int array_size,int no_threads) {
  int tid = threadIdx.x;
  int bid = blockIdx.x;

  int row_no = array_size;
  int col_no = array_size;
  float *mul = (float *)malloc(sizeof(float) * array_size);
  double *sum = (double *)malloc(sizeof(double) * 300);

  //Make multiplications 
  for (int p = 0; p < array_size; p++){
    for(int i = 0; i < array_size; i++){
      for (int j = 0; j < array_size; j++){	  
        mul[((i*array_size)+j) + p*array_size*array_size] = CUDA_A[p * col_no + j] * CUDA_B[ j * row_no + i];
      }	    
    }
  }
   
  float res=0.0;
   //sum all multiplications a1.a2+b1.b3
   for(int r=0;r<array_size;r++){
    for(int j=0;j<array_size;j++){
      for(int k=0;k<array_size;k++){
        res += mul[k+(j*array_size)+(r*(array_size*array_size))]; 	  
      }

      sum[j+(r*array_size)] = res;
      res = 0;
    }
   }

  for(int j = 0;j<300;j++){
    //CUDA_C[(i*array_size) + j] = mul[(i*row_no)+j]; 
    //place all the results back to the array	  
    CUDA_T[j] = sum[j]; 
  }
  
  __syncthreads();
 
}

int main(){
    int array_size = 3;
    float *C, *A, *B, *T;
    float *CUDA_A, *CUDA_B,  *CUDA_C, *CUDA_T; 
    
    A = (float *)malloc(array_size * array_size * sizeof(float));
    B = (float *)malloc(array_size * array_size * sizeof(float));
    T = (float *)malloc(300 * sizeof(float));
  
    float a = 4.0;

    for(int i = 0; i<(array_size * array_size); i++){
      A[i] = ((float)rand()/(float)(RAND_MAX)) * a;
      B[i] = ((float)rand()/(float)(RAND_MAX)) * a;
    } 

    //Fill remaining bytes in array with 1s
    //for(int i = 0; i<300;i++){
    //  T[i] = 1;
   // }

    C = (float *)malloc(array_size * array_size *  sizeof(float) );

    // Allocate device memory
    cudaMalloc((void**)&CUDA_A, sizeof(float) * array_size * array_size);
    cudaMalloc((void**)&CUDA_B, sizeof(float) * array_size * array_size);
    cudaMalloc((void**)&CUDA_C, sizeof(float) * array_size * array_size);
    cudaMalloc((void**)&CUDA_T, sizeof(float) * 300);

    // Transfer data from host to device memory
    cudaMemcpy(CUDA_A, A, sizeof(float) * array_size * array_size, cudaMemcpyHostToDevice);
    cudaMemcpy(CUDA_B, B, sizeof(float) * array_size * array_size, cudaMemcpyHostToDevice);
    cudaMemcpy(CUDA_T, T, sizeof(float) * array_size * array_size, cudaMemcpyHostToDevice);

    printf("calculate_no_threads %d\n",calculate_no_threads(array_size)); 
    vector_dot_product<<<1,calculate_no_threads(array_size)>>>(CUDA_A, CUDA_B, CUDA_C, CUDA_T,array_size,calculate_no_threads(array_size));

    cudaMemcpy(C, CUDA_C, sizeof(float) * array_size * array_size, cudaMemcpyDeviceToHost);
    cudaMemcpy(T, CUDA_T, sizeof(float) * 300, cudaMemcpyDeviceToHost);

    puts("DOT_PRODUCT");
    print_results(A,array_size);
    print_results(B,array_size);

    puts("MATRIX MULTI");
    print_results(T,array_size);

    // Deallocate device memory
    cudaFree(CUDA_A);
    cudaFree(CUDA_B);
    cudaFree(CUDA_C);

    free(C);
    // Deallocate host memory
}

