#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <pthread.h>

int calculate_no_threads(int array_size){
 return 4;
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

struct test
{
  double *CUDA_A, *CUDA_B, *CUDA_C,*CUDA_T;
  int array_size, no_threads;
  double *C, *A, *B, *T;
  int index_for_thread;
};

typedef struct test struct1;

void * vector_dot_product_2(void* b){
  struct1 *c;
  c=(struct1*)b;
  if(c->index_for_thread == 3){
    //sleep(4);
    //return 1;
  }
  int array_size = c->array_size;
  int no_threads = c->no_threads;
  double *CUDA_A = c->A; 
  double *CUDA_B = c->B; 
  double *CUDA_C = c->C; 
  double *CUDA_T = c->T; 
  int index_for_thread = c->index_for_thread; 

  int tid = index_for_thread;
  pthread_t id = pthread_self();
  printf("[TREAD ID. %d,%d]\n",id,index_for_thread) ;
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
}


int main(){
    int array_size = 4500;
    double *C, *A, *B, *T;
    
    A = (double *)malloc(array_size * array_size * sizeof(double));
    B = (double *)malloc(array_size * array_size * sizeof(double));
    T = (double *)malloc((array_size*array_size) * sizeof(double));
    C = (double *)malloc(array_size * array_size * sizeof(double));
  
    double a = 1.5;

    for(int i = 0; i<(array_size * array_size); i++){
      A[i] = ((double)rand()/(double)(RAND_MAX)) * a;
      B[i] = ((double)rand()/(double)(RAND_MAX)) * a;
      C[i] = -1.1;
      T[i] = -1.11;
    } 

    puts("DOT_PRODUCT");
    //print_results(A,array_size);
    //print_results(B,array_size);

   pthread_t th[4];
   struct test structs[4];

   for (int i=0;i<4;i++){
     structs[i] = *(struct1 *)malloc(sizeof(struct1)); 
     structs[i].A=A;
     structs[i].B=B;
     structs[i].C=C;
     structs[i].T=T;
     structs[i].array_size = array_size;
     structs[i].no_threads = calculate_no_threads(array_size);
     structs[i].index_for_thread =i;
   }

   for (int i=0;i<4;i++){
     pthread_create(&th[i], NULL, vector_dot_product_2, (void*) &structs[i]);
   }

   void *status;

   for (int i=0;i<4;i++){
     pthread_join(th[i], &status);
   }

   int ret=1; 
   printf("Finish to execute threads ");
   printf("calculate_no_threads %d\n",calculate_no_threads(array_size)); 
    
   printf("MATRIX MULTI %d",ret);
   print_results(T,array_size);
    
   free(C);
   free(A);
   free(B);
   free(T);
}

