int main() {
  int a = 1;
  float b = 3.0;
  if (a < 2) {
    float a = 2.0;
    b = a;
  }
  a = 3;
  return 0;
}