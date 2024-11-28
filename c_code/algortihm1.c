#define m 15
#define n 10
#define r 1
#define median 5

/*
#include <stdio.h>
void print_image(char image[][n]){
    for (int i=0; i<m; i++){
        printf("[");
        for(int j=0; j<n; j++){
           printf("%3d. ", (unsigned char)image[i][j]);
        }
        printf("]\n");
    }
}

void print_H(char H[256]){
    for(int i = 0; i < 256; i++){
        if(H[i] != 0) printf("%d: %d\n",i,(unsigned char) H[i]);
    }
    printf("\n");
}
*/

asm("li sp, 0x100000"); // SP set to 1 MB
asm("jal main");        // call main
asm("li a7, 10");       // prepare ecall exit
asm("ecall");

void init_image(char image[][n]) {
    int c = 0;
    for (int i=0; i<m; i++){
        for(int j=0; j<n; j++){
           image[i][j] = c;
           c++;
        }
    }
}


void prints(volatile int x){ // ptr is passed through register a0
  asm("li a7, 1"); //You must decide the value of x
  asm("ecall");
}

void init_H(char H[256], char X[][n], int line){
    for(int i = 0; i < 256; i++){
        H[i] = 0;
    }
    for(int i = -r; i <= r; i++){
        for(int j = -r-1; j < r; j++){
            if(j < 0 || i+line < 0) H[0] ++;
            else H[X[i+line][j]] ++;
        }
    }

}

char get_median(char H[256]){
    char sum = 0;
    char res = 0;
    while(1){
        sum += H[res];
        if(sum >= median){
            prints(res);
            return res;
        }
        res ++;
    }
}

void filter_image_linear(char X[][n], char Y[][n]){
    char H[256];
    int line = 0;

    for(int i = 0; i < m; i++){
        init_H(H, X, i);
        for (int j = 0; j < n; j++) {
            int r_x = j-r-1;
            int a_x = j+r;
            for (int k = -r; k <= r; k++){
                int y = i+k;
                if (r_x < 0 || y < 0 || r_x >= n || y >= m) H[0] --;
                else H[X[y][r_x]]--;

                if (a_x < 0 || y < 0 || a_x >= n || y >= m) H[0] ++;
                else H[X[y][a_x]] ++;
            }
            Y[i][j] = get_median(H);
        }
    }
}

int main(){
    char X[m][n];
    char Y[m][n];
    init_image(X);

    filter_image_linear(X, Y);
    return 0;
 }
