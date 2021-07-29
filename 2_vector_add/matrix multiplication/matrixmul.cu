#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>


#define N 512
#define MAX_ERR 1e-6

// __global__ matrix_add(int *out; int *A, int *B){


// }

void test_pass_function_array(int A[], int B[]){


}

int main(){
    
    //Create new matrix 
    int A = [1,2,3];
    int B = [2,3,3]; 

    int *d_a, *d_b, *d_out;

    // // Allocate device memory
    // cudaMalloc((void**)&d_a, sizeof(int) * 3);
    // cudaMalloc((void**)&d_b, sizeof(int) * 3);
    // cudaMalloc((void**)&d_out, sizeof(int) * 3);
 
    // // Executing kernel 

    // matrix_add<<1,1>>>(d_out, d_a, d_b, N);
     
    test_pass_function_array(A, B);

    printf("out[0] = %f\n", out[0]);
    printf("PASSED\n");

}
