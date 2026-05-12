#include "MKL25Z4.h"
#include <stdio.h>
#include <stdlib.h>

/*
 * things to add:
 * - Timers with interruption rather than delays.
 * 	- every 100ms there is an interruption and the position updates,
 * 		measures time to see how much it moved, checks limits so it doesnt fall, etc
 *  - for the stop button thats gonna be in the web page
 */

// LCD CONTROL
// PTA2 -> RS
// PTA4 -> RW
// PTA5 -> EN
// PTD0-PTD3 -> DATA
#define RS 0x04
#define RW 0x10
#define EN 0x20

// ULTRASONICO
// PTB0 -> TRIG
// PTB1 -> ECHO
#define TRIG 0x01
#define ECHO 0x02

// INPUT MOTORES CON L293D
// PTB2-PTB5
#define IN1 0x04   // PTB2
#define IN2 0x08   // PTB3

#define IN3 0x100  // PTC8
#define IN4 0x200  // PTC9

// VARIABLES GLOBALES
char buffer[32];

float posX = 0;
float posY = 0;

float targetX = 0;
float targetY = 0;

//PROTOTIPOS
// DELAYS
void delayMs(int n);
void delayUs(int n);

//LCD
void LCD_init(void);
void LCD_nibble(unsigned char data);
void LCD_command(unsigned char command);
void LCD_data(unsigned char data);
void LCD_sendstring(char *str);

//KEYPAD
void keypad_init(void);
char keypad_getkey(void);
float keypad_getnumber(char axis);

//ULTRASONIC
void ultrasonic_init(void);
float medir_distancia(void);

//MOTOR
void motor_init(void);
void motor_forward(void);
void motor_backward(void);
void motor_stop(void);

// MAIN
int main(void)
{
    __disable_irq();// for future interruptions

    LCD_init();
    keypad_init();
    ultrasonic_init();
    motor_init();

    __enable_irq();// for future interruptions

    // ask for X coordinate
    targetX = keypad_getnumber('X');

    delayMs(500);

    // ask for Y coordinate
    targetY = keypad_getnumber('Y');

    delayMs(500);

    LCD_command(0x01); //clear screen
    LCD_sendstring("MOVIENDO...");
    delayMs(1000);

    while(1)
    {
        float distancia = medir_distancia();// thingy for ultrasonic sensor

        // Detect obstacle 3cm away
        if(distancia <= 3.0)
        {
            LCD_command(0x01);
            LCD_sendstring("OBSTACULO");

            motor_backward();
            delayMs(1000);

            posX -= 2;
            if(posX < 0) posX = 0;
        }
        else
        {
            motor_forward();

            posX += 1;

            if(posX >= targetX && posY < targetY)
            {
                posY += 1;
            }
        }

        LCD_command(0x01);

        sprintf(buffer,"X:%.0f Y:%.0f",posX,posY);//show coordinates in LCD
        LCD_sendstring(buffer);

        delayMs(300);

        if(posX >= targetX && posY >= targetY)
        {
            motor_stop();

            LCD_command(0x01);
            LCD_sendstring("DESTINO");

            LCD_command(0xC0);
            LCD_sendstring("ALCANZADO");

            while(1);
        }
    }
}

// MOTOR INITIALIZATION
void motor_init(void)
{
    SIM->SCGC5 |= 0x0400; // PORTB CLOCK
    SIM->SCGC5 |= 0x0800; // PORTC CLOCK

    PORTB->PCR[2] = 0x100; //PIN AS GPIO
    PORTB->PCR[3] = 0x100;

    PORTC->PCR[8] = 0x100;
    PORTC->PCR[9] = 0x100;

    PTB->PDDR |= IN1 | IN2; //out
    PTC->PDDR |= IN3 | IN4;
}
void motor_forward(void)
{
    PTB->PSOR = IN1; //1
    PTB->PCOR = IN2; //0

    PTC->PSOR = IN3; //1
    PTC->PCOR = IN4; //0
}
void motor_backward(void)
{
    PTB->PSOR = IN2; //1
    PTB->PCOR = IN1; //0

    PTC->PSOR = IN4; //1
    PTC->PCOR = IN3; //0
}
void motor_stop(void)
{
    PTB->PCOR = IN1 | IN2; //0
    PTC->PCOR = IN3 | IN4;
}


// ULTRASONIC
void ultrasonic_init(void)
{
    SIM->SCGC5 |= 0x0400;//clock enable

    PORTB->PCR[0] = 0x100;// PIN as GPIO
    PORTB->PCR[1] = 0x100;

    PTB->PDDR |= TRIG; //out
    PTB->PDDR &= ~ECHO; //IN
}

float medir_distancia(void)
{
    uint32_t tiempo = 0;

    PTB->PCOR = TRIG;// init 0
    delayUs(2);

    PTB->PSOR = TRIG;// TRIGGER 1
    delayUs(10);
    PTB->PCOR = TRIG;// TRIGGER 0

    while(!(PTB->PDIR & ECHO));//while echo = 0 wait

    while(PTB->PDIR & ECHO)// when echo = 1 count
    {
        tiempo++;
        delayUs(1);
    }

    return (tiempo * 0.0343)/2;
}

// KEYPAD
void keypad_init(void)
{
    SIM->SCGC5 |= 0x0800; //clock enable

    for(int i=0;i<8;i++)
        PORTC->PCR[i]=0x103;// PIN as GPIO

    PTC->PDDR=0x0F;// LPTC as 1
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
    if (col == 0x70) return row*4+4;

    return 0;
}

float keypad_getnumber(char axis)
{
    char input[8];
    int index=0;
    char key;

    LCD_command(0x01);

    sprintf(buffer,"Ingresa %c:",axis);
    LCD_sendstring(buffer);

    LCD_command(0xC0);

    while(1)
    {
        key = keypad_getkey();

        if(key >= 1 && key <= 9)
        {
            input[index++] = key + '0';
            LCD_data(key + '0');
            delayMs(250);
        }

        if(key == 14) // tecla 0
        {
            input[index++] = '0';
            LCD_data('0');
            delayMs(250);
        }

        if(key == 13) // tecla *
        {
            input[index] = '\0';
            return atof(input);
        }
    }
}

// LCD INITIALIZATION
void LCD_init(void)
{
    SIM->SCGC5 |= 0x1000;

    PORTD->PCR[0]=0x100;
    PORTD->PCR[1]=0x100;
    PORTD->PCR[2]=0x100;
    PORTD->PCR[3]=0x100;

    PTD->PDDR |= 0x0F;

    SIM->SCGC5 |= 0x0200;

    PORTA->PCR[2]=0x100;
    PORTA->PCR[4]=0x100;
    PORTA->PCR[5]=0x100;

    PTA->PDDR |= 0x34;

    delayMs(30);

    LCD_nibble(0x03);
    delayMs(5);

    LCD_nibble(0x03);
    delayUs(150);

    LCD_nibble(0x03);
    delayUs(150);

    LCD_nibble(0x02);

    LCD_command(0x28);
    LCD_command(0x0C);
    LCD_command(0x06);
    LCD_command(0x01);
}

void LCD_nibble(unsigned char data)
{
    PTD->PCOR=0x0F;
    PTD->PSOR=(data&0x0F);

    PTA->PSOR=EN;
    delayUs(50);
    PTA->PCOR=EN;
}

void LCD_command(unsigned char command)
{
    PTA->PCOR=RS|RW;

    LCD_nibble((command>>4)&0x0F);
    LCD_nibble(command&0x0F);

    delayMs(2);
}

void LCD_data(unsigned char data)
{
    PTA->PSOR=RS;
    PTA->PCOR=RW;

    LCD_nibble((data>>4)&0x0F);
    LCD_nibble(data&0x0F);

    delayUs(50);
}

void LCD_sendstring(char *str)
{
    while(*str)
        LCD_data(*str++);
}

// DELAYS
void delayUs(int n)
{
    for(int i=0;i<n*50;i++)
        __asm("nop");
}

void delayMs(int n)
{
    for(int i=0;i<n;i++)
        for(int j=0;j<3000;j++)
            __asm("nop");
}
