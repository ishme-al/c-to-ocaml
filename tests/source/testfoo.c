int foo(int a, int b) {
  int x = a + b;
  x = 3;
  return a + b;
}

int main() {
  int a = foo(3, 5);
	return 0;
}