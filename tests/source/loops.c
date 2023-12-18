// #include <stdio.h>
int notmain()
{
    int x = 1 + 2;
    int y=2 ;
    for(int a =0, b= 0; a<10; a++) {
        x = x + 1;
        a= a +1;
        y = x +1;
    }
    while( x< 3) {
        // x= x - 1;
        x--;
    }
    int accum = 0;
    for(int a =0; a<2; a++) {
        for(int b = 0; b<2; b++) {
            accum = accum + a;
        }
    }
    return 0;
}
