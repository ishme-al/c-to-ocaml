#include <stdio.h>

struct myStructure {
    int a;
    int b;
    char c;
    float d;
};

int transformAB ( struct myStructure str) {
    int c = str.a * str.b;
    int b = str.a + str.b;
    // int c = str.a * str.b;
    return b + c;
};

int addAb ( struct myStructure str) {
    return str.a + str.b;
};

int multAb ( struct myStructure str) {
    return str.a * str.b;
};

int subAb ( struct myStructure str) {
    return str.a - str.b;
};

int divideAb ( struct myStructure str) {
    return str.a / str.b;
};

struct myStructure initialize () {
    struct myStructure str = {1, 2, 'a', 3.0};
    return str;
}

struct myStructure combine (struct myStructure str, struct myStructure str2) {
    struct myStructure str3 = {str.a + str2.a,  str.b + str2.b, str.c, str.d };
    return str3;
}



int main() {
    struct myStructure str = {1, 2, 'a', 3.0};
    struct myStructure str2 = initialize();

    struct myStructure str3 = combine(str, str2);
    int a = transformAB(str);
    int b = addAb(str);
    int c = multAb(str);
    int d = subAb(str);
    int e = divideAb(str);
    printf("a: %d\n", a);
    printf("b: %d\n", b);
    printf("c: %d\n", c);
    printf("d: %d\n", d);
    printf("e: %d\n", e);
    return 0;
}