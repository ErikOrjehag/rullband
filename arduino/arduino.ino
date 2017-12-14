/*
  CS >>> D10
  SCLK >> D13
  DI  >>> D11
*/
#include <SPI.h>
byte address = 0x11; // Select the first potentiometer, and write data to it
int CS= 10;          // Chip select
int i=0;

int forward = A0;
int backward = A3;

void setup()
{
  pinMode(CS, OUTPUT);
  pinMode(forward, OUTPUT);
  pinMode(backward, OUTPUT);
  SPI.begin();

  // Stop the band at startup
  stopping();
  // Wait 10s before start
  delay(10000); 
}

// Set control signals to backward direction
void goBackward(){
    digitalWrite(forward, LOW);
    digitalWrite(backward,HIGH);
}

// Set control signals to forward direction
void goForward(){
    digitalWrite(backward, LOW);
    digitalWrite(forward,HIGH);
}

// Set control signals to no motion
void stopping(){
    digitalWrite(backward, LOW);
    digitalWrite(forward,  LOW);
}

void loop()
{
    goForward();

    // Ramp up speed forward direction
    for (i = 0; i <= 255; i++)
    {
      digitalPotWrite(i);
      delay(50);
    }
    delay(1000);
    // Ramp down speed forward direction
    for (i = 255; i >= 0; i--)
    {
      digitalPotWrite(i);
      delay(50);
    }
    delay(3000);


    goBackward();
    
    // Ramp up speed backward direction
    for (i = 0; i <= 255; i++)
    {
      digitalPotWrite(i);
      delay(50);
    }
    delay(1000);
    // Ramp down speed backward direction
    for (i = 255; i >= 0; i--)
    {
      digitalPotWrite(i);
      delay(50);
    }
    delay(3000);
}


// Write data to the digital potentiometer
int digitalPotWrite(int value)
{
  digitalWrite(CS, LOW);
  SPI.transfer(address);
  SPI.transfer(value);
  digitalWrite(CS, HIGH);
}
