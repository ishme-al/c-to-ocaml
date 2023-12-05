int foo(int a, int b) {
  int x;
  int y;
  if (a < b) {
    int z = 2;
    x = b - a;
    y = z + a;
  } else {
    int z = 3;
    x = a - b;
    y = z + b;
  }
  return x + y;
}

int main() {
  int x = foo(foo(4, 6), 3);
  return 0;
}