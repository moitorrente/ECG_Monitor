import processing.serial.*;


Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[] values;
int valTemp, valMax=0;
int w=350;


//Variables filtro
int[] yvals;
int[] yvals2;
float[] coefficients = {-0.000487378497927441, -0.000630782362712316, -0.00104199475618086, -0.00168679002205603, -0.00250577433562457, -0.00342031518478175, -0.00434060926332915, -0.00517503135464734, -0.00583975823542259, -0.00626762428509976, 1.06279211659556, -0.00626762428509976, -0.00583975823542259, -0.00517503135464734, -0.00434060926332915, -0.00342031518478175, -0.00250577433562457, -0.00168679002205603, -0.00104199475618086, -0.000630782362712316, -0.000487378497927441};
int coefNum = 20;
int[] filter;
float[] ecg = {2298.05184113369, 2286.83124129436, 2255.49741420776, 2253.50852069654, 2257.21838391230, 2246.06627442300, 2256.73608741211, 2256.29399398874, 2241.80529789420, 2261.75797333402, 2278.61308572749, 2235.75732124709, 2216.50144744927, 2343.02680807968, 2661.26861216043, 2935.67054008404, 2769.73520400829, 2346.97186729650, 2126.07926331286, 2156.77421953497, 2247.23895400535, 2271.55504607982, 2280.48439302832, 2293.54960818539, 2289.11932351904, 2283.56011912360, 2286.97548929553, 2310.46341689704, 2318.57047204078, 2308.72489001124, 2320.14077326133, 2334.44544699605, 2340.55481542387, 2360.22065590068, 2373.77976798530, 2386.73541844989, 2420.53656080837, 2440.04861879383, 2451.21346265694, 2476.44137929882, 2497.62085540840, 2508.03143351348, 2486.78887759062, 2443.99713285169, 2412.69208508356, 2361.26984964866, 2301.74710985958, 2280.51278347517, 2276.32889664736, 2267.93145852141, 2257.67040358117, 2254.76771429381, 2254.60862024810, 2255.37357444317, 2270.60086547008, 2270.15767967870, 2257.72011436001, 2271.18444508697, 2277.81424537910, 2264.94599077171, 2264.77003366566, 2274.40801081741, 2277.76582317635, 2271.57055267392, 2271.16763398268, 2281.72317377765, 2276.72932102348, 2265.27727869480, 2264.57015316450, 2257.69583511051, 2270.66945577336, 2284.10029653086, 2258.53504497867, 2253.42444439608, 2265.24395763118, 2262.65676635562, 2259.91691481433, 2255.47711001316, 2265.90344316737, 2266.40412371138, 2256.04633486176, 2271.10714996435, 2274.80260715123, 2262.16522247723, 2263.67603728029, 2266.95572752001, 2262.41914522564, 2265.28925390950, 2271.63846582171, 2271.95887786859, 2276.12655482583, 2292.50260965442, 2312.71179931533, 2309.08038825416, 2324.06065082274, 2350.81838389121, 2319.58510999775, 2285.07311431556, 2275.73233654391, 2270.31743620363, 2252.67462041811, 2231.02039105802, 2238.15544681632, 2240.64299001621, 2242.59297567906, 2243.09967239695, 2251.83272371974, 2256.67611463452, 2201.80419708111, 2230.20048731110, 2471.34688722758, 2815.65243912571, 2893.39925406345, 2546.20722387070, 2186.24662986857, 2102.33903432082, 2184.89216169188, 2241.41462225243, 2247.14955153657, 2257.53056549213, 2260.92911675587, 2284.94548379745, 2294.18883671787, 2275.76717350616, 2284.04937078043, 2297.63962863855, 2301.99139613895, 2302.02576803187, 2308.84273291822, 2322.39465419233, 2332.04175372157, 2341.98728615958, 2354.01470308695, 2386.59500894435, 2416.89733066458, 2436.04303112320, 2450.18918649767, 2454.26700288211, 2460.92647003431, 2428.40583089250, 2374.34308149621, 2327.97966319815, 2274.83399953732, 2245.46565170180, 2233.42270415351, 2228.75508063847, 2231.52400041005, 2224.17776407164, 2208.89813212080, 2209.37306938274, 2220.11293569520, 2217.83024182600, 2221.73615446443, 2229.12179465182, 2235.41199314910, 2240.30982619589, 2228.50565912478, 2226.76407574718, 2242.67617833037, 2245.15097391618, 2238.60281596561, 2249.20079335965, 2251.55577038743, 2228.59800364051, 2224.56809576385, 2234.94898539083, 2229.41434264965, 2230.15460471922, 2234.50922392323, 2228.91789741553, 2232.23307796647, 2235.65524363535, 2233.04344336476, 2228.36690438269, 2223.57531808192, 2229.50794232365, 2230.72330694951, 2229.84034773814, 2240.53468955350, 2241.93387326136, 2222.36424012463, 2222.85182638466, 2238.61273894224, 2225.73896185315, 2231.30343975913, 2244.93791883252, 2241.19642598801, 2251.90287949041, 2242.05139407832, 2238.86590884159, 2272.48243386633, 2297.42226832510, 2296.90040609614, 2302.86672414785, 2331.76372951011, 2314.04651083629, 2289.73026787104, 2291.64909701836, 2244.09749160260, 2226.55611267199, 2250.57882029546, 2244.43110354989, 2236.21871193395, 2246.80176345792, 2259.59796417520, 2241.35094502819, 2230.25059642740, 2227.55797741093, 2241.93305337153, 2412.92221157424, 2759.90651167878, 2922.69274019145, 2637.83502032750, 2259.56594072206, 2098.06235339773, 2148.35078706895, 2276.79618084811, 2293.61651548724, 2281.37146924588, 2300.28952163688, 2291.82080269479, 2300.67705140626, 2312.21760491041, 2316.63416403802, 2326.41575576860, 2320.20578235800, 2322.79394041556, 2325.29781608226, 2326.96694861351, 2360.79263467286, 2391.99705492325, 2411.38319744230, 2429.37016989923, 2441.01867744095, 2469.58170414815, 2488.37650726547, 2486.77765461587, 2498.00404448374, 2486.39617297611, 2436.53024270384, 2388.45563122612, 2343.60613368345, 2303.88960626702, 2276.87108607401, 2254.14351846665, 2247.25615198471, 2259.98102340548, 2273.76316960474, 2271.98085458599, 2266.43446167584, 2267.43585470431, 2265.77780588073, 2265.32934137350, 2266.52734628526, 2272.07128554836, 2278.55492595045, 2278.26305376160, 2288.36120574534, 2291.00686229402, 2274.96548413088, 2273.57733145748, 2263.65380445816, 2253.22924025904, 2274.25226073895, 2282.37803877745, 2268.45404064409, 2267.26587851549, 2287.79276518187, 2286.56531018572, 2267.51297861526, 2272.87878375626, 2272.31964858441, 2274.34445616703, 2278.16891920054, 2269.83074102140, 2273.24822010071, 2266.31273904590, 2256.11505963405, 2264.34265426824, 2276.19213815924, 2271.74140864893, 2260.82387627766, 2266.90437975167, 2271.26241073774, 2270.92444021246, 2273.79011521519, 2263.76432503483, 2260.01262406433, 2294.25236878655, 2319.63388407061, 2321.95925050486, 2341.27281347165, 2341.01207769849, 2323.56325825326, 2302.61495911086, 2271.27828122506, 2263.06658731263, 2256.42097921668, 2253.53039838087, 2256.25576115280, 2240.89164151095, 2256.87792003394, 2264.04199871043, 2239.55199354010, 2242.77792604193, 2228.67796380451, 2247.54117427400, 2441.74923101363, 2787.16002577867, 2907.32539706716, 2578.35503159880, 2220.21335404167, 2115.09604017177, 2173.65241836148, 2252.84646544562, 2248.56057511044, 2244.72738327360, 2266.00894128783, 2270.63904505998, 2272.93697965696, 2281.94692377588, 2288.60220772488, 2271.70905067346, 2276.32320351464, 2295.04620951209, 2290.91663345356, 2309.38391111008, 2334.19704627695, 2352.57411998935, 2372.84245799879, 2380.62053337232, 2407.63828690894, 2432.35760662340, 2446.83186484098, 2460.56203538685, 2452.05274454677, 2437.40828394155, 2388.94340169454, 2333.32287177418, 2290.90693214195, 2226.60634757340, 2208.86131430523, 2212.07532295687, 2188.12030324135, 2200.45268364257, 2209.36100418839, 2188.30289657295, 2189.11447243405, 2196.26626238535, 2194.34671765261, 2194.12739486166};


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

char led0 = 'A';
char led1 = 'C';

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

  fill(255);
  textAlign(LEFT);
  textFont(BPMFont, width*0.019);
  pushMatrix();
  rotate(-HALF_PI);
  text("R-R Time", width*-0.59, height*0.04);
  popMatrix();
  text("R-R Fluctuations Samples", width*0.05, height*0.96);
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

    if (button1.release) {
      port.write('A');
    } else {
      port.write('B');
    }
  }

  //Control del switch de Frecuencia
  if (button3.press || button4.press) {
    button3.releaseEvent(width*0.75+width*0.245/2+width*0.002, height*0.34, width*0.245/2-width*0.002, height*0.185/2);
    button4.releaseEvent(width*0.75+width*0.245/2+width*0.002, height*0.34+height*0.185/2, width*0.245/2-width*0.002, height*0.185/2);

    if (button3.release) {
      port.write('C');
    } else {
      port.write('D');
    }
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
  if (w==0) w=350;
//  val=3*floor(height*3.25-(ecg[w]));
  println(val);

  signalTimeCounter();

  valTemp=val;

  //Nuevo
  //----------------------------------------------------------------------------------------------------------
  for (int i = 1; i < width; i++) { 
    yvals[i-1] = yvals[i];
    yvals2[i-1] = yvals2[i];
  } 

  w--;


  yvals[width-1] = notchFilter(val);

  yvals2[width-1] = delayFilter(val);


  for (int i=320; i<width*0.95; i++) {

    if (i==width*0.95-1) {
      strokeWeight(5);
      stroke(255);
    } else {
      strokeWeight(1);
      stroke(#19AF3A);
    }


    if (notchButton.release) {
      line(width-i+1, height/10+yvals[i-1]/4, width-i, height/10+yvals[i]/4);
    } else {
      line(width-i+1, height/10+yvals2[i-1]/4, width-i, height/10+yvals2[i]/4);
    }
    stroke(#CE1F1F);
    strokeWeight(1);
  }

  float increment = (320-width*0.95)/7;
  stroke(255);
  line(width*0.74, height*0.91, width*0.05, height*0.91);

  for (int i=0; i<7; i++) {
    stroke(#FF0F0F);
    strokeWeight(2);

    line(width+i*increment-320, height*0.7+RR[i]*2, width+increment*(i+1)-320, height*0.7+RR[i+1]*2);
    strokeWeight(1);

    stroke(255);

    line(width+increment*(i+1)-320, height*0.70+RR[i+1]*2, width+increment*(i+1)-320, height*0.910);

    line(width-320, height*0.70+RR[0]*2, width-320, height*0.910);

    strokeWeight(7);
    point(width+increment*(i+1)-320, height*0.70+RR[i+1]*2);
    point(width-320, height*0.70+RR[0]*2);
    strokeWeight(1);
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


   //   if (RR1+RR2<BPM*3 || RR[0]==0) {
if (RR[0]==0) {
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