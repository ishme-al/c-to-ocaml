#include <stdio.h>

int main() {
  int a = 0;
  int arr[3] = {1, 2, 3};
  a++;
  arr[0]++; 
  printf("%d\n", a);

  printf("array:\n");
  for (int i = 0; i < 3; i++) {
    printf("%d\n", arr[i]);
  }
  return 0;
}