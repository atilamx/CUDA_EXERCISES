#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>

int calculate_no_threads(int array_size){
 if(array_size<256){
   return array_size;	 
 } else {
   return 1024;
 }
}

void print_results(double *ARRAY, int array_size){
  printf("[\n");
  for(int i = 0; i < array_size; i++){
    printf("{");	  
    for(int j = 0; j < array_size; j++){
      printf("%1.1lf,",ARRAY[(i * array_size) +j]); 
    }	    
    printf("}\n");	  
  }
  printf("]");
  printf("\n");
}

__global__ void vector_dot_product(double *CUDA_A, double *CUDA_B, double *CUDA_C,double *CUDA_T,int array_size,int no_threads) {
  int tid = threadIdx.x;
  int bid = blockIdx.x;
  
  int row_count = array_size;
  int col_count = array_size;
  int NumberThreads = no_threads;
  int batch = array_size/NumberThreads;
  int Remaninder = array_size%NumberThreads;
  
  int StartRow;
  int EndRow; 
  
  StartRow = batch * tid; //For testing replace tid with 0..n batch

  if (StartRow == 0){
    EndRow = StartRow + batch + Remaninder;
  } else {
    StartRow = StartRow + Remaninder;
    EndRow = StartRow + batch;
  }

  int StarTingPoint =  array_size*StartRow;

  int increment = 0;
  float product = 0;

  for (int row = StartRow; row < EndRow; row++){
    for(int column = 0; column < array_size; column++){
      for (int cell = 0; cell < array_size; cell++){	  
	product = product + CUDA_A[row * col_count + cell] * CUDA_B[ cell * row_count + column];
      }	    

      CUDA_T[(StarTingPoint)+increment++] = product;
      product = 0;
    }
  }
   __syncthreads();
}

int main(){
    //int array_size = 7900;
    int array_size = 3000;
    double *C, *A, *B, *T;
    double *CUDA_A, *CUDA_B,  *CUDA_C, *CUDA_T; 
    
    A = (double *)malloc(array_size * array_size * sizeof(double));
    B = (double *)malloc(array_size * array_size * sizeof(double));
    T = (double *)malloc((array_size*array_size) * sizeof(double));
    C = (double *)malloc(array_size * array_size *  sizeof(double) );
  
    double a = 0.5;

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

