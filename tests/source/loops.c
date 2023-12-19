// #include <stdio.h>
int notmain()
{
    int x = 1 + 2;
    int y=2 ;
    // for(int a =0, b= 0; a<10; a++) {
    //     x = x + 1;
    //     // if( x>3) {
    //         break;
    //     // }
    //     // break;
    //     a= a +1;
    //     y = x +1;
    //     break; 
    // }
    for(int a =0; a<3;a++) {
        a++;
        if(a > 1) {
            break;
        }
    }
    while( x< 3) {
        // x= x - 1;
        x--;
    }
    return 0;
}
