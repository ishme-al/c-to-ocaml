int main() {
  int x = 0;
  int y = 0;
  if (x >= y) {
    x = x + 1;
  } else if (x == y) {
    x = x + y;
  } else {
    y = y + 1;
  }

  return 0;
}