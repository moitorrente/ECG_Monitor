import processing.serial.*;


Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[] values;

long oneHzSample=1000000/120;
boolean serialInited=false;
Handle handle;

PFont myFont, timeFont, BPMFont;
float shift=1;
int day = day();
int month = month();
int year = year();
int hour, minute, second;
String heart="♥";
float aux=0.5;//tweak
boolean beat=true;
int COM=0;

void setup() {
  //fullScreen();
  size(1200, 800);
  surface.setResizable(true);
  smooth();
  values = new int[4000];
  myFont = createFont("Verdana", 32);
  timeFont = createFont("S7display.ttf", 32);
  BPMFont = createFont("Calibri-Bold", 32);
  thread("timer");
  thread("checkConnection");
  handle = new Handle(width*0.025-(width*0.010), height*0.06, 0, width*0.01, height*0.01);
  initSerial();
}

void draw() {
  background(0);
  //Comprobar conexion serie
  //checkConnection();

  //Mostrar header
  header();

  //Mostrar cuadrados laterales
  squares();

  //Mostrar fecha y hora
  time();

  //Mostrar informacion BMP
  BPMDisplay();

  //Mostrar señal ECG
  ECGdisplay();

  //Actualizar y mostrar barra trigger
  handle.update(width*0.025-(width*0.010), height*0.06, width*0.01, height*0.01);
  handle.display(width*0.025-(width*0.010), height*0.06, width*0.01, height*0.01);
}

void mouseReleased() {
  handle.releaseEvent();
}

void checkConnection() {
  while (true) {
    if (serialInited) {
      delay(2000);
      if (port.last() == -1) {
        port.stop();
        serialInited=false;
        initSerial();
      }
    } else {
      serialInited=false;
      initSerial();
    }
  }
}

void initSerial() {
  try {
    port = new Serial(this, Serial.list()[1], 19200);
    //   println("Serial communication inited");
    serialInited=true;
  } 
  catch(RuntimeException e) {
    //   println("Serial communication not inited");
    serialInited=false;
  }
}


//Thread de calculo de tiempo para mostrar los BPM del simbolo del corazón
void timer() {
  while (true) {  
    delay(500);
    beat=!beat;
  }
}


//Muestra la información de BPM
void BPMDisplay() {
  fill(#FF0F0F);
  textFont(BPMFont, width*0.05);
  if (beat) {
    text(heart, width*0.79, height*0.10);
  }
  textFont(BPMFont, width*0.024);
  text("BPM", width*0.79, height*0.21);
  textAlign(RIGHT, CENTER);
  textFont(BPMFont, width*0.092);
  text(130, width*0.98, height*0.16);
}


//Muestra el header
void header() {
  stroke(#0AC699);
  fill(#0AC699);
  rect(0, 0, width, height*0.05);
  fill(255);
  textFont(myFont, height*0.041);
  textAlign(CENTER, CENTER);
  text("ECG Monitor", width*0.5, height*0.020);
  if (serialInited) {
    fill(#0AFF39);
  } else {
    fill(#FF0000);
  }
  ellipse(width*0.99, height*0.025, height*0.02, height*0.02);
}


//Muestra los cuadrados laterales
void squares() {
  fill(0);
  stroke(254);
  rect(width*0.75, height*0.060, width*0.245, height*0.23, 5);
  rect(width*0.75, height*0.296, width*0.245, height*0.23, 5);
  rect(width*0.75, height*0.532, width*0.245, height*0.23, 5);
  rect(width*0.75, height*0.767, width*0.245, height*0.23, 5);
}


//Muestra fecha y hora
void time() {
  hour=hour();
  minute=minute();
  second=second();

  String time = String.valueOf(nf(hour, 2)+":"+nf(minute, 2)+":"+nf(second, 2));
  String date = String.valueOf(nf(day, 2)+"/"+nf(month, 2)+"/"+year);

  fill(255);
  textFont(BPMFont, width*0.024);
  text(date, width*0.92, height*0.81);
  textFont(timeFont, width*0.042);
  text(time, width*0.873, height*0.93);
}


//Lee los valores del puerto serie
void ECGdisplay() {
  if (serialInited) {
    while (port.available() >= 3) {
      if (port.read() == 0xff) {
        val = (port.read() << 8) | (port.read());
      }
    }
  }
  for (int i=0; i<width-1; i++) {
    values[i] = values[i+1];
  }

  //Shift
  values[width-1] = val;

  stroke(#19AF3A);
  //strokeWeight(2);
  //Muestra la señal ECG
  for (int x=1*round(width*0.28); x<width-(28); x++) {
    line((width-x), (height-aux*height-getY(values[x-1])), (width-1-x), height-aux*height-getY(values[x]));
  }
}

//Devuelve el valor de la posicion Y de la señal ECG
int getY(int val) {
  return (int)(val / 4095.0f * height*0.42) - 1;
}