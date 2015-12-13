class Dropdown {
  PFont dropdownFont;
  float x, y, p;
  boolean overTriangle=false, overOption=false;
  color triangleColor, overColor;
  boolean released=false;
  Dropdown(float ix, float iy, float ip) {
    x = ix;
    y = iy;
    p = ip;
    dropdownFont =createFont("Arial", 20, true);
  }

  void display(float ix, float iy, float ip) {
    x=ix;
    y=iy;
    p=ip;
    if (overTriangle()) {
      triangleColor=#8E8E8E;
      stroke(#8E8E8E);
    } else {
      triangleColor=#FFFFFF;
    }
    fill(triangleColor);
    // noStroke();
    smooth();
    if (released) {
      triangle (x+p/2, y, x, y+p/2, x+p, y+p/2);
    } else {
      triangle(x, y, x+p, y, x+p/2, y+p/2);
    }
  }


  boolean overTriangle() {
    overTriangle = mouseX > x && mouseX < x+p && mouseY < y+p/2 && mouseY > y;
    if (overTriangle) {
      return true;
    } else {
      return false;
    }
  }

  boolean overOption(float posx, float posy, float posxfin, float posyfin) {
    overOption = mouseX >  posx && mouseX < posx+posxfin && mouseY < posy+posyfin && mouseY > posy;
    if (overOption) {
      return true;
    } else {
      return false;
    }
  }

  void displayPorts() {
    if (released) {
      fill(0);
      stroke(255);
      rect(x-width*0.20, y+height*0.02, width*0.21, 2*((y+p+height*0.02)*Serial.list().length), 5);
      fill(255);
      textFont(dropdownFont, width*0.015);
      text("Puertos disponibles", x-width*0.09, y+height*0.05);
      for (int i=1; i<Serial.list().length+1; i++) {
        if (overOption(x-width*0.14, height*0.04+y+height*0.04*i, width*0.14, y+p/2)) {
          overColor=#7784F5;
        } else {
          overColor=255;
        }
        fill(overColor);
        rect(x-width*0.17, height*0.04+y+height*0.04*i, width*0.17, y+p/2, 5);
        textAlign(CENTER, CENTER);
        fill(0);
        textFont(dropdownFont, width*0.01);
        text(Serial.list()[i-1], x-width*0.09, height*0.05+y+height*0.04*i);
      }
      //    rect(width*0.76, y*(Serial.list().length+1)+p*0.7, width*0.09, y*0.9);
    }
  }
}