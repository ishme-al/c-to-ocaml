#include <stdio.h>

int recursive(int n) {
    printf("recursive(%d)\n", n);
    if (n > 1) {
        return recursive(recursive(n-1));
    }
    return n;
}

int main() {
    int x = recursive(5);
    return 0;
}