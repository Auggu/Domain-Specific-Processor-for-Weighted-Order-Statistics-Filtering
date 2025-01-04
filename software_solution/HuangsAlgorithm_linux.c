#define m 15
#define n 10
#define r 2
#define median 13
#define th 12

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

int tmdn = 0;
int mdn = 0;

void init_image(char image[][n]) {
    int c = 0;
    for (int i=0; i<m; i++){
        for(int j=0; j<n; j++){
           image[i][j] = c;
           c++;
        }
    }
}


void init_H(char H[256], char X[][n], int line){
    tmdn = 0;
    mdn = 0;
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

void get_median(char H[256]){
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
                printf("%d\n", g1);
            }
            get_median(H);
            Y[i][j] = mdn;
        }
    }
}

int main(){
    char X[m][n];
    char Y[m][n];
    init_image(X);
    print_image(X);

    filter_image_linear(X, Y);
    print_image(Y);
    return 0;
 }
