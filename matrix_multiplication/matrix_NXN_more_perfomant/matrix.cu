#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>

int calculate_no_threads(int array_size){
 return 4;  
}

void print_results(double *ARRAY, int array_size){
  printf("[\n");
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

__global__ void vector_dot_product(double *CUDA_A, double *CUDA_B, double *CUDA_C,double *CUDA_T,int array_size,int no_threads) {
  int tid = threadIdx.x;
  int bid = blockIdx.x;
  int row_no = array_size;
  int col_no = array_size;
  float todo=0;
  //Make multiplications 
  for (int p = 0; p < array_size; p++){
    for(int i = 0; i < array_size; i++){
      for (int j = 0; j < array_size; j++){	  
	todo = todo + CUDA_A[p * col_no + j] * CUDA_B[ j * row_no + i];
      }	    

      CUDA_T[chin++]=todo;
      todo = 0;
    }
  }
}

int main(){
    //int array_size = 7900;
    int array_size = 4;
    double *C, *A, *B, *T;
    double *CUDA_A, *CUDA_B,  *CUDA_C, *CUDA_T; 
    
    A = (double *)malloc(array_size * array_size * sizeof(double));
    B = (double *)malloc(array_size * array_size * sizeof(double));
    T = (double *)malloc((array_size*array_size) * sizeof(double));
    C = (double *)malloc(array_size * array_size *  sizeof(double) );
  
    double a = 1.5;

    for(int i = 0; i<(array_size * array_size); i++){
      A[i] = ((double)rand()/(double)(RAND_MAX)) * a;
      B[i] = ((double)rand()/(double)(RAND_MAX)) * a;
    } 

    // Allocate device memory
    cudaMalloc((void**)&CUDA_A, sizeof(double) * array_size * array_size);
    cudaMalloc((void**)&CUDA_B, sizeof(double) * array_size * array_size);
    cudaMalloc((void**)&CUDA_C, sizeof(double) * array_size * array_size);
    cudaMalloc((void**)&CUDA_T, sizeof(double) * (array_size*array_size));

    // Transfer data from host to device memory
    cudaMemcpy(CUDA_A, A, sizeof(double) * array_size * array_size, cudaMemcpyHostToDevice);
    cudaMemcpy(CUDA_B, B, sizeof(double) * array_size * array_size, cudaMemcpyHostToDevice);
    cudaMemcpy(CUDA_T, T, sizeof(double) * array_size * array_size, cudaMemcpyHostToDevice);

    printf("calculate_no_threads %d\n",calculate_no_threads(array_size)); 
    vector_dot_product<<<1,calculate_no_threads(array_size)>>>(CUDA_A, CUDA_B, CUDA_C, CUDA_T,array_size,calculate_no_threads(array_size));

    cudaMemcpy(C, CUDA_C, sizeof(double) * array_size * array_size, cudaMemcpyDeviceToHost);
    cudaMemcpy(T, CUDA_T, sizeof(double) * (array_size*array_size), cudaMemcpyDeviceToHost);

    puts("DOT_PRODUCT");
    print_results(A,array_size);
    print_results(B,array_size);

    puts("MATRIX MULTI");
    print_results(T,array_size);
    //for(int i =0;i<array_size*array_size;i++){
    //  printf("%f,",T[i]);
   // }


    // Deallocate device memory
    cudaFree(CUDA_A);
    cudaFree(CUDA_B);
    cudaFree(CUDA_C);
    cudaFree(CUDA_T);

    free(C);
    free(A);
    free(B);
    free(T);
    // Deallocate host memory
}

