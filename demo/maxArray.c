int getMax(int[] arr, int n) {
    int temp = arr[0];
    for(int x=0; x<n; x++) {
        if(arr[x] > temp) {
            temp = arr[x];
        }
    }
    return temp;
}