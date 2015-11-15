class Handle {
  float x, y;
  float boxx, boxy;
  float stretch;
  float sizex, sizey;
  float trigger=0;

  boolean over;
  boolean press;
  boolean locked=false;
  PFont handleFont;

  Handle(float ix, float iy, float il, float isx, float isy) {
    x = ix;
    y = iy;
    stretch = il;
    sizex = isx;
    sizey = isy;
    boxx = x+stretch - sizex/2;
    boxy = y - sizey/2;
  }

  void update(float ix, float iy, float isx, float isy) {
    boxx = ix;
    boxy = iy + stretch;
    sizex = isx;
    sizey = isy;
    if (press) {
      stretch = lock(mouseY-height*0.03-sizey/2, height*0.005-sizey/2, height*0.45-sizey/2);
  //    println("1: "+stretch);
  //    println(height*0.03-sizey/2);
      trigger=abs((map(stretch, (height*0.03-sizey/2)*17.8, 0, 0, 1024)));
    }
    overEvent();
    pressEvent();
  }

  void overEvent() {
    if (overRect(boxx, boxy, sizex, sizey)) {
      over = true;
    } else {
      over = false;
    }
  }

  void pressEvent() {
    if (over && mousePressed || locked) {
      press = true;
      locked = true;
      stroke(255);
      line(boxx, boxy+sizey/2, boxx+width*0.700, boxy+sizey/2);
      
      //
      fill(255);
      textFont(myFont, height*0.03);
      textAlign(CENTER, CENTER);
      text(floor(trigger), -boxx+width*0.7, boxy+2*sizey);
       //<>// //<>// //<>//
      //
      noCursor();
    } else {
      cursor();
      press = false;
    }
  }

  void releaseEvent() {
    locked = false;
  }

  void display(float ix, float iy, float isx, float isy) {
    sizex = isx;
    sizey = isy;
    //Linea barra

    if (over || press) {
      fill(255);
      stroke(255);
      rect(boxx, boxy, sizex, sizey);
      line(width*0.02, height*0.06, width*0.02, height*0.51);
    } else {
      fill(0);
      stroke(#8B8787);
      line(width*0.02, height*0.06, width*0.02, height*0.51);
      rect(boxx, boxy, sizex, sizey);
    }
  }


  boolean overRect(float x, float y, float width, float height) {
    if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
      return true;
    } else {
      return false;
    }
  }

  float lock(float val, float minv, float maxv) { 
    float aux;
    // return  min(max(floor(val), floor(minv)), floor(maxv));

    if (val > minv) {
      aux = val;
    } else {
      aux = minv;
    }

    if (maxv < aux) {
      aux = maxv;
    }

    return aux;
  }
}