// The world pixel by pixel 2020
// Aidan Fowler
// Rectangular tiles rotating based on function relative to tangent of distance between mouse and tile
// Hue determined by function relative to sin of distance between mouse and tile
// Saturation and Brightness based on current mouseX and mouseY
// Depth of tile based on function relative to distance from mouse to tile (can change scale with mouse click)
// Size of tile based on function relative to sin of distance form mosue
// Press 'p'key to turn paint mode on and off
// Click mouse to change depth of tile field 

int cellSize= 8;                 
float count = 0;
float distanceToMouseSave = 0;
float hue= 0;
float rotation = 0;
float saturation = 0;
float scale = 0;
float value = 0;
boolean paint = false;
float zDistance = -.5;

void setup() {
  size(1300, 800, P3D);   
  colorMode(HSB, 100);
  noCursor();
}

void draw() {
  count-=1;
  lights(); // we want the 3D to be shaded

  for (int x = 0; x < width; x+=cellSize) {
    for (int y = 0; y < height; y+=cellSize) {
      float distanceToMouse= dist(x, y, mouseX, mouseY);   
      distanceToMouseSave = distanceToMouse;
      pushMatrix();                                         
      translate(x, y, distanceToMouse*zDistance);           
      distanceToMouse+= count;  
      distanceToMouse /= 80; 
      hue = map(sin(distanceToMouse), -1, 1, 0, 100); 
      rotation = map(tan(distanceToMouse*2), -1, 1, 0, TWO_PI);
      saturation = mouseX/13;
      value = mouseY/8+55;    
      rotateX(rotation);
      fill(hue, saturation, value);
      scale = map(sin(distanceToMouse*32), -1, 1, -2, 2);
      rect(0, 0, cellSize+scale, cellSize+scale);
      popMatrix();
    }
  }

  if (!paint) {
    fill(0, 0, 255, 5);
    rect(0, 0, width, height);
  }
}

void mouseClicked() {
  zDistance+=1;
  if (zDistance >=5.5) {
    zDistance = -.5;
  }
}

void keyPressed() {
  if (key == 'p') {
    paint = !paint;
  }
}
