struct myStruct {
  int a;
  int b;
  float c;
  char d;
};

int main() {
  struct myStruct str = {1, 2, 3.0, 'a'};
  str.a = 2;

  return 0;
}