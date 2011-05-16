#include <gmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int
main(int argc, char **argv) {

    if(argc < 2) {
    fprintf(stderr, "Please enter a number of the Fibonacci series to compute.\n");
    return 1;
    }

    uint32_t v = atoi(argv[1]);

    mpz_t a, b, c, tmp1, tmp2, new_a, new_b;

    mpz_init(a);
    mpz_init(b);
    mpz_init(c);
    mpz_init(tmp1);
    mpz_init(tmp2);
    mpz_init(new_a);
    mpz_init(new_b);

    mpz_init_set_ui(a, 1);
    mpz_init_set_ui(b, 0);
    mpz_init_set_ui(c, 1);

    int bits = 31;
    while (bits > 0 && !((v >> bits) & 1)) {
        bits--;
    }
    while (bits >= 0) {

        if((v >> bits) & 1) {
            mpz_add(tmp1, a, c);
            mpz_mul(new_a, tmp1, b);

            mpz_mul(tmp1, b, b);
            mpz_mul(tmp2, c, c);
            mpz_add(new_b, tmp1, tmp2);
        } else {
            mpz_mul(tmp1, a, a);
            mpz_mul(tmp2, b, b);
            mpz_add(new_a, tmp1, tmp2);

            mpz_add(tmp1, a, c);
            mpz_mul(new_b, tmp1, b);
        }

        mpz_set(a, new_a);
        mpz_set(b, new_b);
        mpz_add(c, a, b);
        bits--;
    }

    mpz_out_str(stdout, 10, b);
    printf("\n");

    return 0;
}

