int main()
{
    int x = 0;
    int y= 0;
    
    if(x > y) {
        x = x + 1;
    } else {
        y = y + 1;
    }
     if(x == 0) {
        x = y;
     }

     if(x == y) {
        x = x + y  ;   
    }
    return 0;
}