import processing.serial.*;


Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[] values;
int valTemp, valMax=0;


//Variables filtro
int[] yvals;
int[] yvals2;
float[] coefficients = {-0.000487378497927441, -0.000630782362712316, -0.00104199475618086, -0.00168679002205603, -0.00250577433562457, -0.00342031518478175, -0.00434060926332915, -0.00517503135464734, -0.00583975823542259, -0.00626762428509976, 1.06279211659556, -0.00626762428509976, -0.00583975823542259, -0.00517503135464734, -0.00434060926332915, -0.00342031518478175, -0.00250577433562457, -0.00168679002205603, -0.00104199475618086, -0.000630782362712316, -0.000487378497927441};
int coefNum = 20;
int[] filter;


long oneHzSample=1000000/120;
boolean serialInited=false;
boolean up=false;
Handle handle;
Button button1, button2, button3, button4, notchButton;
Dropdown dropdown;
String[] serialPorts = new String[Serial.list().length];


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
int counter1=0;
int counter2=0;
int RR1=0;
int RR2=0;

int[] RR;
int BPM=0;

void setup() {
  //fullScreen();
  size(1200, 800);
  surface.setResizable(true);
  smooth();
  //  values = new int[2800];
  myFont = createFont("Verdana", 32);
  timeFont = createFont("S7display.ttf", 32);
  BPMFont = createFont("Calibri-Bold", 32);

  //Thread para el parpadeo del corazón
  thread("timer");
  //Thread para la reconexión automática
  thread("checkConnection");

  dropdown = new Dropdown(width*0.8, height*0.09, width*0.007);
  handle = new Handle(width*0.025-(width*0.010), height*0.06, 0, width*0.01, height*0.01);     //Handle del trigger
  button1 = new Button(width*0.75, height*0.34, (width*0.245)/2-width*0.002, height*0.185, 5); //Ganancia 100
  button2 = new Button(width*0.75, height*0.296, (width*0.245)/2-width*0.002, height*0.23, 5); //Ganancia 1000
  button3 = new Button(width*0.75, height*0.34, (width*0.245)/2-width*0.002, height*0.185, 5); //Frecuencia 0.5Hz
  button4 = new Button(width*0.75, height*0.296, (width*0.245)/2-width*0.002, height*0.23, 5); //Frecuencia 0.05Hz
  notchButton = new Button(width*0.75, height*0.296, (width*0.245)/2-width*0.002, height*0.23, 5); //Botón Notch

  //Estado inicial de los botones de switch de Ganancia y Frecuencia
  button1.release=true;
  button3.release=true;

  //Valores para mostrar la señal
  yvals = new int[2800];  
  yvals2 = new int[2800];
  filter = new int[coefNum];
  RR = new int[8];
}

void draw() {
  background(0);

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

  //Actualizar y mostrar los botones
  updateButtons();


  dropdown.display(width*0.98, height*0.020, width*0.011);
  dropdown.displayPorts();
}


void updateButtons() {
  button1.update();
  button1.display(width*0.75, height*0.34, (width*0.245)/2-width*0.002, height*0.185/2, 5, "100");
  button2.update();
  button2.display(width*0.75, height*0.34+height*0.185/2, (width*0.245)/2-width*0.002, height*0.185/2, 5, "1000");
  button3.update();
  button3.display(width*0.75+width*0.245/2+width*0.002, height*0.34, width*0.245/2-width*0.002, height*0.185/2, 5, "0.5 Hz");
  button4.update();
  button4.display(width*0.75+width*0.245/2+width*0.002, height*0.34+height*0.185/2, width*0.245/2-width*0.002, height*0.185/2, 5, "0.05 HZ");
  notchButton.update();
  notchButton.display(width*0.75, height*0.532, width*0.245/2-width*0.002, height*0.185/2, 5, "Notch");
}

void mouseReleased() {
  //Control del handle del trigger
  handle.releaseEvent();

  //Control del switch de Ganancia
  if (button1.press || button2.press) {
    button1.releaseEvent(width*0.75, height*0.34, (width*0.245)/2-width*0.002, height*0.185/2);
    button2.releaseEvent(width*0.75, height*0.34+height*0.185/2, (width*0.245)/2-width*0.002, height*0.185/2);
  }

  //Control del switch de Frecuencia
  if (button3.press || button4.press) {
    button3.releaseEvent(width*0.75+width*0.245/2+width*0.002, height*0.34, width*0.245/2-width*0.002, height*0.185/2);
    button4.releaseEvent(width*0.75+width*0.245/2+width*0.002, height*0.34+height*0.185/2, width*0.245/2-width*0.002, height*0.185/2);
  }

  //Control del botón de Notch
  if (notchButton.overRect(width*0.75, height*0.532, width*0.245/2-width*0.002, height*0.185/2)) {
    notchButton.release=!notchButton.release;
  }


  if (dropdown.overTriangle()) {
    println(Serial.list().length);
    println(Serial.list());
    dropdown.released=!dropdown.released;
  }
}

void mousePressed() {
  button1.pressedEvent(width*0.75, height*0.34, (width*0.245)/2-width*0.002, height*0.185/2); 
  button2.pressedEvent(width*0.75, height*0.34, (width*0.245)/2-width*0.002, height*0.185/2);
  button3.pressedEvent(width*0.75+width*0.245/2+width*0.002, height*0.34, width*0.245/2-width*0.002, height*0.185/2);
  button4.pressedEvent(width*0.75+width*0.245/2+width*0.002, height*0.34, width*0.245/2-width*0.002, height*0.185/2);
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


//Thread de calculo de tiempo para mostrar los BPM del símbolo del corazón
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
  text(BPM, width*0.98, height*0.16);
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
  noStroke();
  if (serialInited) {
    fill(#0AFF39);
  } else {
    fill(#FF0000);
  }
  ellipse(width*0.97, height*0.025, height*0.02, height*0.02);
}


//Muestra los cuadrados laterales
void squares() {
  fill(0);
  stroke(255);
  //  rect(width*0.75, height*0.532, width*0.245, height*0.23, 5);
  rect(width*0.75, height*0.767, width*0.245, height*0.23, 5);
  rect(width*0.75, height*0.060, width*0.245, height*0.23, 5);

  fill(0);
  rect(width*0.75+width*0.245/2+width*0.002, height*0.296, width*0.245/2-width*0.002, height*0.10, 5);
  rect(width*0.75, height*0.296, (width*0.245)/2-width*0.002, height*0.10, 5);
  fill(255);
  textFont(BPMFont, width*0.019);
  text("F -3dB", width*0.94, height*0.31);
  text("Ganancia", width*0.81, height*0.31);
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

  signalTimeCounter();

  valTemp=val;

  //Nuevo
  //----------------------------------------------------------------------------------------------------------
  for (int i = 1; i < width; i++) { 
    yvals[i-1] = yvals[i];
    yvals2[i-1] = yvals2[i];
  } 


  yvals[width-1] = notchFilter(val);

  yvals2[width-1] = delayFilter(val);


  for (int i=320; i<width*0.95; i++) {
   
    if(i==width*0.95-1){
      strokeWeight(5);
      stroke(255);
    }else{
       strokeWeight(1);
        stroke(#19AF3A);
    }
    
   
    if (notchButton.release)
    {
      line(width-i+1, height/10+yvals[i-1]/4, width-i, height/10+yvals[i]/4);
    } else {
      line(width-i+1, height/10+yvals2[i-1]/4, width-i, height/10+yvals2[i]/4);
    }
    stroke(#CE1F1F);
    strokeWeight(1);
  }
  
  float increment = (320-width*0.95)/7;
  
  
  for (int i=0; i<7; i++){
    line(width+i*increment-320, height*0.7+RR[i]*2,width+increment*(i+1)-320, height*0.7+RR[i+1]*2);
    
  }

  /* Antiguo!!! 
   ---------------------------------------------------------------------------------------------------------------  
   for (int i=0; i<width-1; i++) {
   values[i] = values[i+1];
   }
   
   //Shift
   values[width-1] = val;
   
   
   stroke(#19AF3A);
   //Muestra la señal ECG
   for (int x=1*round(width*0.28); x<width-(28); x++) {
   line((width-x), (height-aux*height-getY(values[x-1])), (width-1-x), height-aux*height-getY(values[x]));
   
   }
   -----------------------------------------------------------------------------------------------------------------
   */
}

//Contador de tiempo entre pico y pico según el valor del trigger
void signalTimeCounter() {
  int sumaRR=0;
  //Comprueba la pendiente de la señal
  if (val>handle.triggerInt) {
    if (val>valTemp) {
      up=true;
    } else {
      up=false;
    }
  }

  //Contador de tiempo ascendente
  if (up) {
    if (counter1>1) {
      RR1=counter1;
      println("RR1: "+RR1);
    }
    counter1=0;
    counter2++;
  } else {
    //Countador de tiempo descendente
    if (counter2>1) {
      RR2=counter2;
      println("RR2: " + RR2);


      if (RR1+RR2<BPM*3 || RR[0]==0) {

        for (int i=0; i<7; i++) {
          RR[i]=RR[i+1];
        }
        
        RR[7]=RR1+RR2;

        for (int i=0; i<8; i++) {
          sumaRR = sumaRR + RR[i]; 
          println(i+" "+RR[i]);
        }
        BPM=sumaRR/8;
      }
    }

    counter1++;
    counter2=0;
  }
}

//Devuelve el valor de la posicion Y de la señal ECG
int getY(int val) {
  return (int)(val / 4095.0f * height*0.42) - 1;
}

int notchFilter(int val) {
  float temp=0;

  for (int i = coefNum-1; i > 0; i--) {
    filter[i] = filter[i-1];
  }

  filter[0]=val;

  for (int i = coefNum-1; i> 0; i--) {
    temp=temp+filter[i]*coefficients[i];
    //    println(temp);
  }
  return int(temp/3);
}

int delayFilter(int val) {
  float temp=0;

  for (int i = coefNum-1; i > 0; i--) {
    filter[i] = filter[i-1];
  }

  filter[0]=val;

  return int(filter[coefNum-1]/3);
}