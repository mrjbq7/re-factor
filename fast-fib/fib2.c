#include <gmp.h>
#include <stdio.h>
#include <stdlib.h>

int
main(int argc, char **argv) {

  if(argc < 2) {
    fprintf(stderr, "Please enter a number of the Fibonacci series to compute.\n");
    return 1;
  }

  mpz_t sum;

  mpz_init(sum);
  mpz_fib_ui(sum, atoi(argv[1]));
  mpz_out_str(stdout, 10, sum);
  printf("\n");

  return 0;
}

