/*
  AnalogReadSerial
  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.
  This example code is in the public domain.
  http://www.arduino.cc/en/Tutorial/AnalogReadSerial
*/
// the setup routine runs once when you press reset:
int dPIN[5] = {12,11,9,8,7};
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
//  for (int i = 0; i < 5; i++) {
//    pinMode(dPIN[i],OUTPUT);
//  }
  
}
// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
//  digitalWrite(dPIN[0],HIGH);
//  for (int i = 1; i < 5; i++) {
//    digitalWrite(dPIN[i],LOW);
//  }
  int sensorValue0 = analogRead(A0);
  delay(10);
//  for (int i = 0; i < 5; i++) {
//    digitalWrite(dPIN[i],LOW);
//  }
//  digitalWrite(dPIN[1],HIGH);
  int sensorValue1 = analogRead(A1);
  delay(10);
//  for (int i = 0; i < 5; i++) {
//    digitalWrite(dPIN[i],LOW);
//  }
//  digitalWrite(dPIN[2],HIGH);
  int sensorValue2 = analogRead(A2);
  delay(10);
//  for (int i = 0; i < 5; i++) {
//    digitalWrite(dPIN[i],LOW);
//  }
//  digitalWrite(dPIN[3],HIGH);
  int sensorValue3 = analogRead(A3);
  delay(10);
//  for (int i = 0; i < 5; i++) {
//    digitalWrite(dPIN[i],LOW);
//  }
//  digitalWrite(dPIN[4],HIGH);
  int sensorValue4 = analogRead(A4);
  // print out the value you read:
  Serial.print(sensorValue0);
  Serial.print("\t\t");
  Serial.print(sensorValue1);
  Serial.print("\t\t");
  Serial.print(sensorValue2);
  Serial.print("\t\t");
  Serial.print(sensorValue3);
  Serial.print("\t\t");
  Serial.println(sensorValue4);
  delay(10);        // delay in between reads for stability
}
