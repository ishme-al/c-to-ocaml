int foo(int a) {
  if (a == 0) {
    return 0;
  }

  int x = 4 + a;
  return x;
}

int main() {
  int x = foo(5);
  return 0;
}