int foo() {
  int x = 0;
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 3; j++) {
      x++;
    }
  }

  for (int i = 0; i < 3; i++) {
    while (x > 3) {
      x--;
    }
  }

  return x;
}