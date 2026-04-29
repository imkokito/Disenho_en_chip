//apenas esta en pruebas
#include "MKL25Z4.h"
#include <stdio.h>

#define RS 0x04
#define RW 0x10
#define EN 0x20

typedef enum { RUNNING, PAUSED } estado_t;
volatile estado_t estado = RUNNING;
volatile uint8_t contador_100ms = 0;

void Init_TPM0(void);
void Init_Button(void);

void keypad_init(void);
char keypad_getkey(void);

void LCD_init(void);
void LCD_command(unsigned char command);
void LCD_data(unsigned char data);
void LCD_sendstring(char *str);

void delayMs(int n);
void delayUs(int n);

//MAIN
int main(void)
{
    __disable_irq();

    Init_TPM0();
    Init_Button();
    keypad_init();
    LCD_init();

    LCD_command(0x01);
    LCD_sendstring("RUNNING");

    __enable_irq();

    while (1)
    {
        char key = keypad_getkey();

        if (key == 'B') // '*'
        {
            delayMs(200);

            estado = RUNNING;
            contador_100ms = 0;

            LCD_command(0x01);
            LCD_sendstring("RUNNING");
        }

        delayMs(10);
    }
}

//BUTTON
void Init_Button(void)
{
    SIM->SCGC5 |= SIM_SCGC5_PORTA_MASK;

    PORTA->PCR[1] = PORT_PCR_MUX(1) |
                    PORT_PCR_PE_MASK |
                    PORT_PCR_PS_MASK |
                    PORT_PCR_IRQC(0xA);

    PTA->PDDR &= ~(1 << 1);

    NVIC_EnableIRQ(PORTA_IRQn);
}

void PORTA_IRQHandler(void)
{
    if (PORTA->ISFR & (1 << 1))
    {
        estado = PAUSED;

        LCD_command(0x01);
        LCD_sendstring("PAUSED");

        PORTA->ISFR = (1 << 1);
    }
}

//TIMER
void Init_TPM0(void)
{
    SIM->SCGC6 |= 0x01000000;
    SIM->SOPT2 |= 0x01000000;

    TPM0->SC = 0;
    TPM0->MOD = 37500;

    TPM0->SC = 0x07 | 0x40 | 0x08;

    NVIC_EnableIRQ(TPM0_IRQn);
}

void TPM0_IRQHandler(void)
{
    TPM0->SC |= 0x80;

    if (estado == PAUSED) return;

    contador_100ms++;

}

//KEYPAD
void keypad_init(void)
{
    SIM->SCGC5 |= 0x0800;

    for (int i = 0; i < 8; i++)
        PORTC->PCR[i] = 0x103;

    PTC->PDDR = 0x0F;
}

char keypad_getkey(void)
{
    int row, col;
    const char row_select[] = {0x01,0x02,0x04,0x08};

    PTC->PDDR |= 0x0F;
    PTC->PCOR = 0x0F;
    delayUs(2);

    col = PTC->PDIR & 0xF0;
    PTC->PDDR = 0;

    if (col == 0xF0) return 0;

    for (row = 0; row < 4; row++)
    {
        PTC->PDDR = 0;
        PTC->PDDR |= row_select[row];
        PTC->PCOR = row_select[row];

        delayUs(1);
        col = PTC->PDIR & 0xF0;

        if (col != 0xF0) break;
    }

    PTC->PDDR = 0;

    if (row == 4) return 0;

    if (col == 0xE0) return row*4+1;
    if (col == 0xD0) return row*4+2;
    if (col == 0xB0) return row*4+3;

    if (col == 0x70)
    {
        if(row == 0) return 'A';
        if(row == 1) return 'B';
        if(row == 2) return 'C';
        if(row == 3) return 'D';
    }

    return 0;
}
//LCD
void LCD_init(void)
{
    SIM->SCGC5 |= 0x1000;
    for(int i=0;i<8;i++) PORTD->PCR[i]=0x100;
    PTD->PDDR = 0xFF;

    SIM->SCGC5 |= 0x0200;
    PORTA->PCR[2]=PORTA->PCR[4]=PORTA->PCR[5]=0x100;
    PTA->PDDR |= 0x34;

    delayMs(30);
    LCD_command(0x30); delayMs(10);
    LCD_command(0x30); delayMs(1);
    LCD_command(0x30);

    LCD_command(0x38);
    LCD_command(0x06);
    LCD_command(0x01);
    LCD_command(0x0F);
}

void LCD_command(unsigned char command)
{
    PTA->PCOR = RS | RW;
    PTD->PDOR = command;
    PTA->PSOR = EN;
    delayMs(1);
    PTA->PCOR = EN;
}

void LCD_data(unsigned char data)
{
    PTA->PSOR = RS;
    PTA->PCOR = RW;
    PTD->PDOR = data;
    PTA->PSOR = EN;
    delayMs(1);
    PTA->PCOR = EN;
}

void LCD_sendstring(char *str)
{
    while (*str) LCD_data(*str++);
}

//DELAY
void delayMs(int n)
{
    for(int i=0;i<n;i++)
        for(int j=0;j<3000;j++)
            __asm("nop");
}

void delayUs(int n)
{
    for(int i=0;i<n*50;i++)
        __asm("nop");
}
