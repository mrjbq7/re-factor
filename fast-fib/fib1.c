#include <gmp.h>
#include <stdio.h>
#include <stdlib.h>

int
main(int argc, char **argv) {

  if(argc < 2) {
    fprintf(stderr, "Please enter a number of the Fibonacci series to compute.\n");
    return 1;
  }

  mpz_t first, second, sum, count, stop;

  mpz_init(first);
  mpz_init(sum);

  mpz_init_set_ui(second, 1);
  mpz_init_set_ui(count, 1);
  mpz_init_set_str(stop, argv[1], 10);

  while(mpz_cmp(stop, count)) {
    mpz_add(sum, first, second);
    mpz_set(first, second);
    mpz_set(second, sum);
    mpz_add_ui(count, count, 1);
  }

  mpz_out_str(stdout, 10, sum);
  printf("\n");

  return 0;
}

