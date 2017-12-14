/*
this program taken from arduino Example .
  modified by By Mohannad Rawashdeh
  http://www.genotronex.com
https://www.instructables.com/

  This code used to control the digital potentiometer
  MCP41100 connected to  arduino Board
  CS >>> D10
  SCLK >> D13
  DI  >>> D11
  PA0 TO VCC
  PBO TO GND
  PW0 TO led with resistor 100ohm .
*/
#include <SPI.h>
byte address = 0x11;
int CS= 10;
int i=0;

int forward = A0;
int backward = A3;

void setup()
{
  pinMode (CS, OUTPUT);
  SPI.begin();
  // adjust high and low resistance of potentiometer
  // adjust Highest Resistance .
  pinMode(forward, OUTPUT);
  pinMode(backward, OUTPUT);
  stopping();
  delay(10000);
}

void goBackward(){
    digitalWrite(forward, LOW);
    digitalWrite(backward,HIGH);
}

void goForward(){
    digitalWrite(backward, LOW);
    digitalWrite(forward,HIGH);
}

void stopping(){
    digitalWrite(backward, LOW);
    digitalWrite(forward,  LOW);
}
void loop()
{
    goForward();

    for (i = 0; i <= 255; i++)
    {
      digitalPotWrite(i);
      delay(50);
    }
    delay(1000);
    for (i = 255; i >= 0; i--)
    {
      digitalPotWrite(i);
      delay(50);
    }
    delay(3000);


    goBackward();
    
    for (i = 0; i <= 255; i++)
    {
      digitalPotWrite(i);
      delay(50);
    }
    delay(1000);
    for (i = 255; i >= 0; i--)
    {
      digitalPotWrite(i);
      delay(50);
    }
    delay(3000);
}

int digitalPotWrite(int value)
{
  digitalWrite(CS, LOW);
  SPI.transfer(address);
  SPI.transfer(value);
  digitalWrite(CS, HIGH);
}
