#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include "ruby.h"
#include "extconf.h"
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
  printf("ADDING\n");
  printf("[");
  for(int i = 0 ; i < 3; i++){
    printf("%f,",C[i]);
  }
  printf("]\n");
}

void print_results_sub(float *C){
  printf("SUBSTRACTING\n");

   printf("[");
   for(int i = 0 ; i < 3; i++){
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


extern "C"
void some(){
    float *C, *K;
    float *CUDA_A, *CUDA_B, *CUDA_C, *CUDA_K; 

    // Allocate host memory
    float A[3]= {2.0,4.0,6.0};
    printf("A = {2.0,4.0,6.0}\n");
    float B[3]= {1.0,2.0,3.0};
    printf("B = {1.0,2.0,3.0}\n");

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
    char str[100];
    int i;
    // Executing kernel 
    //for(;;){
     // printf( "Enter a value :");
     // scanf("%d",&i);

      //printf( "\nYou entered: %d \n",i);

      vector_add<<<1,3>>>(CUDA_A, CUDA_B, CUDA_C, N);
      cudaMemcpy(C, CUDA_C, sizeof(float) * N, cudaMemcpyDeviceToHost);

      //Executing kernel 

      print_results(C);

      vector_sub<<<1,3>>>(CUDA_A, CUDA_B, CUDA_C, N);
      cudaMemcpy(C, CUDA_C, sizeof(float) * N, cudaMemcpyDeviceToHost);

      print_results_sub(C);
    
    //}
    cudaFree(CUDA_A);
    cudaFree(CUDA_B);
    cudaFree(CUDA_C);

    // Deallocate host memory
    //free(A); 
    //free(B); 
    free(C);
}

VALUE rb_print_length(VALUE self, VALUE str) {
  if (RB_TYPE_P(str, T_STRING) == 1) {
    some();	  
    return rb_sprintf("String length: %d", RSTRING_LEN(str));
  }

  return Qnil;
}

__global__ void simple_kernel(float *CUDA_A, float *CUDA_C) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;
   //if (tid == 0){
     CUDA_C[tid] = CUDA_A[tid] + 3;
   //}
}

int simple_vector(int v){
  float A[3]= {2.0,4.0,6.0};
  float *C;
  float j = (float) v;

  C = (float*)malloc(sizeof(float) * N);
  A[0] =(float) v;
  printf("pasaste -> %f\n",j);
  float *CUDA_A, *CUDA_C;

  cudaMalloc((void**)&CUDA_A, sizeof(float) * 4);
  cudaMalloc((void**)&CUDA_C, sizeof(float) * 4);

  cudaMemcpy(CUDA_A, A, sizeof(float)*4, cudaMemcpyHostToDevice);

  simple_kernel<<<1,4>>>(CUDA_A, CUDA_C);

  cudaMemcpy(C, CUDA_C, sizeof(float) * 4, cudaMemcpyDeviceToHost); 

  printf("and_we_got-> %f\n",C[0]);
  printf("and_we_got-> %f\n",C[1]);
  printf("and_we_got-> %f\n",C[2]);
  printf("and_we_got-> %d\n",(int)(5.0*(C[0]+C[1]+C[2])));
  return (5.0)*(C[0]+C[1]+C[2]);
}

static VALUE get_number_from_card(VALUE self, VALUE value) {
  Check_Type(value, T_FIXNUM);

  int number_in = NUM2INT(value);
  int number_out = simple_vector(number_in);
  return INT2NUM(number_out);
}

extern "C"
void Init_nvidia()
{
  rb_define_global_function("print_length", rb_print_length, 1);
  rb_define_global_function("get_number_from_card", get_number_from_card, 1);
}

