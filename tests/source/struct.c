struct myStruct {
  int a;
  int b;
  float c;
  char d;
};


int main() {
  struct myStruct str = {1, 2, 3.0, 'a'};
  // str.a = 2;
  int a = str.a;
  int b = str.b;
  int m = str.a + str.b;

  char d = str.d;
  d ='a';
  return 0;
}
