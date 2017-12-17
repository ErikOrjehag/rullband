#include <EEPROM.h>

struct handle {
  byte t0;
  byte t1;
  byte t2;
  char d0;
  unsigned long getTime() {
    return ((unsigned long)t2 << 16) | ((unsigned long)t1 << 8) | (t0);
  }
  char getHeight() {
    return d0;
  }
};


float current_time;
byte handle_index = 0;
handle current_handle;
handle next_handle;
bool done = false;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  /*
  handle data[] = {{0,0,0 ,0},
                   {10,0,0 ,0},
                   {15,0,0 ,100},
                   {30,0,0 ,100},
                   {45,0,0 ,0},
                   {50,0,0 ,0},
                   {70,0,0 ,-100},
                   {100,0,0,-100},
                   {120,0,0,0},
                   {150,0,0,0}};
  Serial.println("Initialize eeprom");
  byte var;
  for(int i = 0; i < 13; i++){
    printHandle(EEPROM.get(i*sizeof(handle)+1, current_handle));
  }
  for(int i = 0; i < 13*sizeof(handle); i++){
    Serial.println(EEPROM.get(1+i, var));
  }*/
  EEPROM.get(1, current_handle);
  EEPROM.get(1+sizeof(handle), next_handle);
}


void loop() {
  if(done){
    Serial.println("DONE!");
    delay(4000);
    return;
  }
  current_time = ((float)millis()/1000.0);

  while (current_time > next_handle.getTime()) {
    Serial.println("Update handle to next");
    handle_index+=sizeof(handle);
    if(handle_index > 12*sizeof(handle)){
      done = true;
      return;
    }
    current_handle = next_handle;
    EEPROM.get(1+handle_index + sizeof(handle), next_handle);
    return;
  }
  //Serial.print("Current handle: ");
  //printHandle(current_handle);
  int speed = interpolate(current_handle, next_handle, current_time);
  setSpeed(speed);
  delay(400);
}
void printHandle(handle h){

  Serial.print("Height: ");
  Serial.print((int)h.getHeight());
  Serial.print("\t time: ");
  Serial.print(h.getTime());
  Serial.print("\t @ ");
  Serial.println(millis());
}
int interpolate(struct handle p0, struct handle p1, float t) {
  signed long x0 = p0.getTime();
  signed long x1 = p1.getTime();
  char y0 = p0.getHeight();
  char y1 = p1.getHeight();/*
  Serial.print("x0: ");
  Serial.print(x0);
  Serial.print("\t x1: ");
  Serial.print(x1);
  Serial.print("\t y0: ");
  Serial.print(y0,DEC);
  Serial.print("\t y1: ");
  Serial.print(y1,DEC);
  Serial.print("\t t: ");
  Serial.print(t);
  Serial.print("\t t-x0: ");
  Serial.print((t - x0));
  Serial.print("\t y diff: ");
  Serial.print(y1 - y0);
  Serial.print(",\t x diff: ");
  Serial.print(x1 - x0);
  Serial.print(",\t k value: ");
  Serial.print((y1 - y0) / (x1 - x0));
  Serial.print(",\t delta y: ");
  Serial.println((t - x0) * (y1 - y0) / (x1 - x0));*/
  return y0 + (t - x0) * (y1 - y0) / (x1 - x0);
}


void setSpeed(int speed){
  //Serial.print("Set speed to: ");
  Serial.println(speed);
}

