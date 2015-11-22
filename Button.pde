class Button {
  float x, y;
  float boxx, boxy;
  float sizex, sizey;
  float trigger=0;
  int round;
  String text;

  boolean over=false;
  boolean press=false;
  boolean release=false;
  boolean locked=false;
  PFont buttonFont;

  Button(float ix, float iy, float isx, float isy, int ir) {
    x = ix;
    y = iy;
    sizex = isx;
    sizey = isy;
    round=ir;
    buttonFont = createFont("Verdana", 32);
  }

  void update() {
    overEvent();
  }

  void display(float ix, float iy, float isx, float isy, int ir, String itext) {
    x = ix;
    y = iy;
    sizex = isx;
    sizey = isy;
    round=ir;

    if (over && !release) {
      fill(80);
    } else if (!over && !release) {
      fill(40);
    } else if (!over && release) {
      fill(#0AC699);
    } else {
      fill(#0AC699);
    }


    stroke(255);
    rect(x, y, sizex, sizey, round);

    fill(255);
    textAlign(CENTER, CENTER);
    textFont(buttonFont, height*0.03);
    text(itext, x+sizex/2, y+sizey/2);
  }

  void overEvent() {
    if (overRect(x, y, sizex, sizey)) {
      over = true;
    } else {
      over = false;
    }
  } 

  boolean overRect(float x, float y, float sizex, float sizey) {
    if (mouseX >= x && mouseX <= x+sizex && mouseY >= y && mouseY <= y+sizey) {
      return true;
    } else {
      return false;
    }
  }

  void releaseEvent(float x, float y, float sizex, float sizey) {
    if (overRect(x, y, sizex, sizey)) {
      release = true;
    } else if (!overRect(x, y, sizex, sizey)) {
      release = false;
    }
  }

  void pressedEvent(float x, float y, float sizex, float sizey) {
    if (overRect(x, y, sizex, 2*sizey)) {
      press = true;
    } else if (!overRect(x, y, sizex, 2*sizey)) {
      press = false;
    }
  }
}