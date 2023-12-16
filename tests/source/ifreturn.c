int foo(int a) {
  int b = 3;
  if (a > 0) {
    b = b + a;
    return b;
  }

  return b * 2;
}

int main() {
  int x = foo(5);
  return 0;
}