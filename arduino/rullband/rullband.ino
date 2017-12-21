/*
  CS >>> D10
  SCLK >> D13
  DI  >>> D11
*/
#include <SPI.h>
#include <EEPROM.h>

struct handle {
  byte t0;
  byte t1;
  byte t2;
  char d0;
  unsigned long getTime() {
    return ((unsigned long)t2 << 16) | ((unsigned long)t1 << 8) | (t0);
  }
  int getHeight() {
    return d0;
  }
};




// Setup pins
int CS= 10;          // Chip select
int i=0;
int forward = A0;
int backward = A3;

// Adress to the digital potentiometer
byte address = 0x11; 

// Variables for receiving new programs
unsigned long lastRecieved = 0;
const unsigned long TIME_THRESHOLD = 1000;
byte value = 0;
int index = 0;


// Variables for execution of program
float current_time;
byte handle_index = 0;
handle current_handle;
handle next_handle;
bool done = false;
byte lengthOfProgram = 0;


void(* resetFunc) (void) = 0;//declare reset function at address 0


void setup()
{
  Serial.begin(9600);
  pinMode(CS, OUTPUT);
  pinMode(forward, OUTPUT);
  pinMode(backward, OUTPUT);
  SPI.begin();

  EEPROM.get(0, lengthOfProgram);
  EEPROM.get(1, current_handle);
  EEPROM.get(1 + sizeof(handle), next_handle);
  
  // Stop the band at startup
  noMotion();
  Serial.println("Start execution of program"); 
}

void loop()
{
  index = 0;

  // If we have a new program sent to us. 
  if (Serial.available() > 0) {

    // Receive program.
    lastRecieved = millis();
    while (millis() - lastRecieved < TIME_THRESHOLD) {

      if (Serial.available()) {
        if (index >= EEPROM.length()){
          Serial.println("Reached end of eeprom memory!");
          index = 0;
        }
        
        // read the incoming byte:
        value = Serial.read();
      
        // say what you got:
        Serial.print("I received: ");
        Serial.println(value, DEC);
    
        // Save value to EEPROM memory
        EEPROM[index] = value;
    
        // Increase index to next iteration 
        index++;
        lastRecieved = millis();
      }
    }

    // New program upload done
    String msg = "Upload of new program done (";
    msg.concat(index - 1);
    msg.concat(" bytes)");
    Serial.println(msg);
    Serial.flush();
    resetFunc();  //call reset
  }
  
  if (done) {
    return;
  }
  
  current_time = ((float)millis()/1000.0);

  while (current_time > next_handle.getTime()) {
    Serial.println("Update handle to next");
    handle_index += sizeof(handle);
    if(handle_index > (lengthOfProgram-2) * sizeof(handle)){
      done = true;
      Serial.println("DONE!");
      return;
    }
    current_handle = next_handle;
    EEPROM.get(1+handle_index + sizeof(handle), next_handle);
    return;
  }
  //Serial.print("Current handle: ");
  //printHandle(current_handle);
  char speed = interpolate(current_handle, next_handle, current_time);
  setSpeed(speed);
  delay(400);
}

char interpolate(struct handle p0, struct handle p1, float t) {
  signed long x0 = p0.getTime();
  signed long x1 = p1.getTime();
  char y0 = p0.getHeight();
  char y1 = p1.getHeight();
  return y0 + (t - x0) * (y1 - y0) / (x1 - x0);
}


// Set control signals to backward direction
void backwardMotion(){
    digitalWrite(forward, LOW);
    digitalWrite(backward,HIGH);
}

// Set control signals to forward direction
void forwardMotion(){
    digitalWrite(backward, LOW);
    digitalWrite(forward,HIGH);
}

// Set control signals to no motion
void noMotion(){
    digitalWrite(backward, LOW);
    digitalWrite(forward,  LOW);
}

// Set speed of the band (value range -128 to 127)
int setSpeed(char value)
{
  if(value < 0)
    backwardMotion();
  else if (value > 0)
    forwardMotion();
  else if(value == 0)
    noMotion();

  
  digitalWrite(CS, LOW);
  SPI.transfer(address);
  SPI.transfer(abs(value));
  digitalWrite(CS, HIGH);
}
