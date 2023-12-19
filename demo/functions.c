int test1(int a, int b) {
    return a + b;
}

int test2(int a, char b) {
    return a;
}

char test3(int a, char b) {
    a = a * 2;
    a = a + 3;
    return b;
}

char test4(int a, int b) {
    if (a > b) {
        return a;
    }
    return b;
}


int fibonacci(int n) {
    if (n <= 1) {
        return n;
    } else {
        int temp = fibonacci(n-1);
        int temp2 = fibonacci(n-2);
        return temp + temp2;
    }
}

