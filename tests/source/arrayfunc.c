#include <stdio.h>

int foo (int x[3]) {
    x[0] = 0;
    return x[0];
}

int main () {
    int x[3] = {1, 2, 3};
    printf("x array:\n");
    for (int i = 0; i < 3; i = i + 1) {
        x[i] = x[i] + 1;
        printf("%d, ", x[i]);
    }

    int j = 2;
    while (j > 0) {
        printf("%d, ", x[j]);
        j = j - 1;
    }

    int y = foo(x);
    printf("\ny: %d\n", y);
    return 0;
}
