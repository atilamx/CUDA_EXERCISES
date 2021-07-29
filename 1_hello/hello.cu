#include<stdio.h>

__global__ void cuda_hello(){
    int a = 4;
    int c;
    c = a + 5; 
    printf("testing");
    __syncthreads();
}

int main() {
    cuda_hello<<<1,1>>>(); 
    return 0;
}
