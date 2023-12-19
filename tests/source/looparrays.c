int main() {
  int b[3] = {1, 2, 3};
  int sum = 0;

  for(int x= 0; x<3;x++) {
    sum = sum + b[x];
  }

  for (int i = 0; i < 3; i = i + 1) {
        b[i]= b[i] +1;
        printf("%d, ", b[i]);
    }

  int x = b[2] + 3;
  
  b[1] = 3;
  // int c = b[2] + 1;
  // b[2] = 1;

  int a[3];

  // float c[3];

  return 0;
  // exit()
}