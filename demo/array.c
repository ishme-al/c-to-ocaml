int main() {
  int b[3] = {1, 2, 3};
  int x = b[2] + 3;
  b[1] = 3;
  int c = b[2] + 1;
  b[2] = 1;

  int a[3];

  float d[3];



  return 0;


  // exit()
}

int sum(int arr[3]) {
    int sum = 0;
    for(int x= 0; x<3;x++) {
        sum = sum + arr[x];
    }
    return sum;
}
