float foo(float a, float b) {
  float x;
  float y;
  if (a < b) {
    float z = 2.0;
    x = b - a;
    y = z + a;
  } else {
    float z = 3.0;
    x = a - b;
    y = z + b;
  }
  return x + y;
}

float main() {
  float x = foo(foo(4.0, 6.0), 3.0);
  return 0;
}
