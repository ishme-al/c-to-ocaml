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


