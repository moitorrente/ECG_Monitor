#include "Waveform.h"

#define oneHzSample 1000000/maxSamplesNum  // sample for the 1Hz signal expressed in microseconds 


int i = 0;
int sample;
int gain_1 = 13;
int gain_2 = 12;
int freq_1 = 11;
int freq_2 = 9;
char FREQ1 = 'A';
char FREQ2 = 'B';
char GAIN1 = 'C';
char GAIN2 = 'D';
char led;


boolean gainState = LOW;
boolean freqState = LOW;

void setup() {
  Serial.begin(19200);
  pinMode(gain_1, OUTPUT);
  pinMode(gain_2, OUTPUT);
  pinMode(freq_1, OUTPUT);
  pinMode(freq_2, OUTPUT);
  pinMode(13, OUTPUT);
}

void loop() {

  digitalWrite(gain_1, gainState);
  digitalWrite(gain_2, !gainState);
  digitalWrite(freq_1, freqState);
  digitalWrite(freq_2, !freqState);
  
  int val = waveformsTable[1][i];
  Serial.write(0xff);
  Serial.write((val >> 8) & 0xff);
  Serial.write(val & 0xff);
  i++;
  if (i == maxSamplesNum) // Reset the counter to repeat the wave
    i = 0;
  delayMicroseconds(oneHzSample * 5); // Hold the sample value for the sample time



}

void serialEvent() {
  led = Serial.read();


  if (led == FREQ1) //if we get a 1
  {
    freqState = LOW;
  }
  else if (led == FREQ2)
  {
    freqState = HIGH;
  }

  else if (led == GAIN1)
  {
    gainState = LOW;
  }
  else if (led == GAIN2)
  {
    gainState = HIGH;
  }

}


