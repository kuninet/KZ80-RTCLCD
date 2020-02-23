/*
  RTC-7301DG READ

*/

/* PPI I/O PORT DEFINE */
#define PPI_A     0xC0
#define PPI_B     0xC1
#define PPI_C     0xC2
#define PPI_CTL   0xC3

#define RTC_CE_ON   0x0C
#define RTC_CE_OFF  0x0D
#define RTC_RD_ON   0x08
#define RTC_RD_OFF  0x09
#define RTC_WR_ON   0x0A
#define RTC_WR_OFF  0x0B

#define PPIBOUT 0x80
#define PPIBIN 0x82

/* YOBI MESSGAE */
char *SUN = "SUN";
char *MON = "MON";
char *TUE = "TUE";
char *WED = "WED";
char *THU = "THU";
char *FRI = "FRI";
char *SAT = "SAT";
char *yobi_tbl[7];

void yobi_tabl_init(){
	yobi_tbl[0] = SUN;
	yobi_tbl[1] = MON;
	yobi_tbl[2] = TUE;
	yobi_tbl[3] = WED;
	yobi_tbl[4] = THU;
	yobi_tbl[5] = FRI;
	yobi_tbl[6] = SAT;
}

/*
        PPI CTL
*/
void ppi_ctl(unsigned char c){
       outp(PPI_CTL,c); 
}

/*
        PPI-A OUT
*/
void ppi_a(unsigned char c){
       outp(PPI_A,c); 
}

/*
        PPI-B OUT
*/
void ppi_b(unsigned char c){
       outp(PPI_B,c); 
}

/*
        PPI-C OUT
*/
void ppi_c(unsigned char c){
       outp(PPI_C,c); 
}


/*
        RTC WRITE
*/
void rtc_write(unsigned char wreg,unsigned char wdat){
        ppi_a(wreg);
        ppi_b(wdat);
        ppi_ctl(RTC_RD_OFF);
        ppi_ctl(RTC_CE_ON);
        ppi_ctl(RTC_WR_ON);
        ppi_ctl(RTC_WR_OFF);
        ppi_ctl(RTC_CE_OFF);
}

/*
        RTC BANK0 START
*/
void rtc_start(){
     rtc_write(0x0F,0x00);   
}


/*
        RTC BANK0 SEL
*/
void rtc_bank0(){
     rtc_write(0x0F,0x02);   
}

/*
        RTC BANK1 SEL
*/
void rtc_bank1(){
     rtc_write(0x0F,0x06);   
}

/*
        RTC BANK2 SEL
*/
void rtc_bank2(){
     rtc_write(0x0F,0x0A);   
}


void wait(int n,int m){
        int i,j;
        for(i = 0;i < m;i++){ ; 
                for(j = 0;j < n;j++){ ; }
        }
}


/*
        RTC READ
*/
unsigned char rtc_read(unsigned char reg){
        unsigned char c;
        ppi_a(reg);
        ppi_ctl(RTC_WR_OFF);
        ppi_ctl(RTC_CE_ON);
        ppi_ctl(RTC_RD_ON);
        c = (unsigned char)inp(PPI_B);
        c = ( c & 0x0f ) + '0';
        if (c > '9'){c = 'X';}  
        ppi_ctl(RTC_RD_OFF);
        ppi_ctl(RTC_CE_OFF);
        return c;
}

/*
        PPI INIT
*/
void ppi_init(){
        ppi_ctl(PPIBOUT);
        ppi_ctl(RTC_CE_OFF);
        ppi_ctl(RTC_WR_OFF);
        ppi_ctl(RTC_RD_OFF);

}

main(){
        unsigned char reg,c;
        int i;
        ppi_init();
        rtc_start();

        yobi_tabl_init();
        ppi_ctl(PPIBIN);
        ppi_ctl(RTC_CE_OFF);
        ppi_ctl(RTC_WR_OFF);
        ppi_ctl(RTC_RD_OFF);
        ppi_ctl(RTC_CE_ON);
        wait(255,1);

        for(reg = 0x0E;reg >= 0x0B;reg--){
                c = rtc_read(reg);
                putchar(c);
        }
        putchar('/');
        for(reg = 0x0A;reg >= 0x09;reg--){
                c = rtc_read(reg);
                putchar(c);
        }
        putchar('/');
        for(reg = 0x08;reg >= 0x07;reg--){
                c = rtc_read(reg);
                putchar(c);
        }
        putchar(' ');

        c = rtc_read(0x06) - '0';
        printf(" %s ",yobi_tbl[c]);


        for(reg = 0x05;reg >= 0x04;reg--){
                c = rtc_read(reg);
                putchar(c);
        }
        putchar(':');
        for(reg = 0x03;reg >= 0x02;reg--){
                c = rtc_read(reg);
                putchar(c);
        }
        putchar(':');
        c = rtc_read(0x01);
        putchar(c);

        c = rtc_read(0);
        putchar(c);

        putchar('\n');

}