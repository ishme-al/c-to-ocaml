int foo(int a, int b) {
  int x = a;
  int y = b;
  return x + y;
}

int main() {
  int x = foo(foo(4, 6), 3);
  return 0;
}