#include <stdio.h>

int foo(int a) {
    if (a > 0) {
        return foo(a - 1);
    } else {
        return a;
    }
}

int main() {
    int x = foo(5);
    printf("x: %d\n", x);
    return 0;
}
