#include <EEPROM.h>

void setup() {
  Serial.begin(9600);
}


unsigned long lastRecieved;
const unsigned long TIME_THRESHOLD = 5000;
byte value = 0;   // for incoming serial data
int index = 0;


// Variables for execution of program
float current_time;
byte handle_index = 0;
handle current_handle;
handle next_handle;
bool done = false;



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

void loop() {
  
  // send data only when you receive data:
  if (Serial.available() > 0) {
    if(millis() - lastRecieved > TIME_THRESHOLD){
      Serial.println("New program detected");
      index = 0;
    }
    if(index >= EEPROM.length()){
      Serial.println("Reached end of eeprom memory");
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
