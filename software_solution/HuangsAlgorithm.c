//#define m 100
//#define n 150
#define pixels 100*150
/*
#define r 2
#define median 13
#define th 12
*/
#define r 3
#define th ((r*2+1)*(r*2+1)/2)

#include "input.h"

asm("li sp, 0x100000"); // SP set to 1 MB
asm("jal main");        // call main
asm("li a7, 10");       // prepare ecall exit
asm("ecall");

int tmdn = 0;
int mdn = 0;

void init_image(unsigned char image[][n]) {
    int c = 0;
    for (int i=0; i<m; i++){
        for(int j=0; j<n; j++){
           image[i][j] = c;
           c++;
        }
    }
}


void prints(volatile int x){
    asm("li a7, 1");
    asm("ecall");
    asm("li a7, 11");
    asm("li a0, 32");
    asm("ecall");

}

void print_line(){
    asm("li a7, 11");
    asm("li a0, 10");
    asm("ecall");
}

int get_cycles(){
    int result;
    asm volatile(
        "li a7, 31; ecall;"
        : "=r"(result) :
        : );
    return result;
}

void init_H(int H[256], unsigned char X[][n], int line){
    tmdn = 0;
    mdn = 0;
    for(int i = 0; i < 256; i++){
        H[i] = 0;
    }
    for(int i = -r; i <= r; i++){
        for(int j = -r-1; j < r; j++){
            if(j < 0 || i+line < 0 || i+line >= m) H[0] ++;
            else H[X[i+line][j]] ++;
        }
    }
  }


void get_median(int H[256]){
    if(tmdn > th){
        while(tmdn > th){
            mdn --;
            tmdn = tmdn - H[mdn];
        }
    }else{
        while(tmdn + H[mdn] <= th){
            tmdn = tmdn + H[mdn];
            mdn++;
        }
    }
   //prints(mdn);
}


void filter_image_linear(unsigned char X[][n], unsigned char Y[][n]){
    int H[256];

    for(int i = 0; i < m; i++){
        init_H(H, X, i);
        for (int j = 0; j < n; j++) {
            int r_x = j-r-1;
            int a_x = j+r;
            for (int k = -r; k <= r; k++){
                unsigned char g1;
                int y = i+k;
                if (r_x < 0 || y < 0 || r_x >= n || y >= m) g1 = 0;
                else g1 = X[y][r_x];
                H[g1] --;
                if (g1 < mdn) tmdn --;

                if (a_x < 0 || y < 0 || a_x >= n || y >= m) g1 = 0;
                else g1 = X[y][a_x];
                H[g1] ++;
                if(g1 < mdn) tmdn ++;
            }
            //int cycles = get_cycles();
            get_median(H);
            //prints(get_cycles()-cycles);
            //print_line();
            Y[i][j] = mdn;
        }
        //print_line();
    }
}

int main(){
    //unsigned char X[m][n];
    unsigned char Y[m][n];
    //init_image(X);
    filter_image_linear(X, Y);
    return 0;
 }
