int maxArray(int arr[20]) {
    int max = arr[0];
    for (int i = 1; i < 20; i = i + 1) {
        if (arr[i] >= max) {
            max = arr[i];
        }
    }
    return max;
}

int main() {
    int arr[20] = {1, 2, 3, 4, 5, 6, 7, 8, 20, 10,
                   11, 12, 13, 14, 15, 16, 17, 18, 19, 9};
    int max = maxArray(arr);
    printf("max: %d\n", max);
    return 0;
}