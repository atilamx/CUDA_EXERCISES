#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>

int calculate_no_threads(int array_size){
 return 1;  
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

void vector_dot_product(double *CUDA_A, double *CUDA_B, double *CUDA_C,double *CUDA_T,int array_size,int no_threads) {
  int row_no = array_size;
  int col_no = array_size;
  double todo = 0;
  int chin=0;
  for (int row = 0; row < array_size; row++){
    for(int i = 0; i < array_size; i++){
      for (int j = 0; j < array_size; j++){	  
	todo = todo + CUDA_A[row * col_no + j] * CUDA_B[ j * row_no + i];
      }	    

      CUDA_T[chin++]=todo;
      todo = 0;
    }
  }
}

int main(){
    int array_size =3;
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

    printf("calculate_no_threads %d\n",calculate_no_threads(array_size)); 
    vector_dot_product(A, B, C, T,array_size,calculate_no_threads(array_size));

    puts("DOT_PRODUCT");
    print_results(A,array_size);
    print_results(B,array_size);

    puts("MATRIX MULTI");
    print_results(T,array_size);

    free(C);
    free(A);
    free(B);
    free(T);
}

