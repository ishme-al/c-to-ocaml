int main() {
    int a = 1;
    int b = 2;
    int c = 3;
    if (a == 1 && b == 2) {
        c = 4;
    }
    if (a == 1 || b == 2) {
        c = 5;
    }
    printf("%d\n", c);
    return 0;
}