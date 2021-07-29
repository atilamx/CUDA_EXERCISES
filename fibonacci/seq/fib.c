#include <stdio.h>
#include <math.h>

float raise(float base, int exponent)
{
  float result=1;
    for (exponent; exponent>0; exponent--) 
      {
        result = result * base;
      }
  return result;
}

int 
 main(int argc, char const *argv[])
{
  //12 bytes
  //long double a[2000000];  
  float golden = 1.61803398875;

  //formula 
  float result = (raise(golden, 8) - raise((1 - golden),8) )/2.23606797749979;

  printf("result %d", float);   

}



//9 223 372 036 854 775 807
//6 440 026 026 417 911 337
//(golden^n) 90 MAX
//golden= 1.61803398875
// n=4; (((golden^n) ) - ((1 - golden)^n)) )/2.23606797749979


// n=4; (((golden^n) * (golden^n) ) - ( (1 - golden)^n) * ((1 - golden)^n) )/2.23606797749979

//10000/128