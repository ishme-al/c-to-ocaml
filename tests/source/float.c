int main() {
  float a = 1.;
  float b = 2.3;
  float c = a + b;
  float d = a * b;
  float e;
  if (b == 0.0) {
    e = 0.0;
  } else {
    e = a / b;
  }
  printf ("c = %f\n", c);
  printf ("d = %f\n", d);
  return 0;
}