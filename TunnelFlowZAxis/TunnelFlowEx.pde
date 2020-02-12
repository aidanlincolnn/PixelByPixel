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
float hue= 0;
float rotation = 0;
float rotation2 = 0;
float rotation3 = 0;
float scale = 0;
boolean paint = false;
float zDistance = -0;
int modeCount = 5;
boolean rotateZ = false;

void setup() {
  size(1600, 900, P3D);   
  colorMode(HSB, 100);
  noCursor();
}

void draw() {
  count-=1;
  lights(); // we want the 3D to be shaded

  for (int x = 0; x < width; x+=cellSize) {
    for (int y = 0; y < height; y+=cellSize) {
      float distanceToMouse= dist(x, y, mouseX, mouseY);   
      pushMatrix();                                         
      translate(x, y, distanceToMouse*zDistance*1.2);           
      distanceToMouse+= count;  
      hue = map(sin(distanceToMouse/80), -1, 1, 0, 100); 
      rotation = map(tan(distanceToMouse/40), -1, 1, 0, TWO_PI); 
      if(rotateZ){
        rotateZ(rotation);
      }
      else{
        rotateX(rotation);
      }
      fill(hue, mouseX/16, mouseY/9+75);
      scale = map(sin(distanceToMouse/2), -1, 1, -2, 2);
      rect(0, 0, cellSize+scale, cellSize+scale);
      popMatrix();
    }
  }

  if (!paint) {
    fill(255, 0, 255, 10);
    rect(0, 0, width, height);
  }
}

void mouseClicked() {
  zDistance+=1;
  if (zDistance >=modeCount) {
    zDistance = -modeCount;
  }
  else if(zDistance <= -modeCount){
    zDistance = modeCount;
  }
}

void keyPressed() {
  if (key == 'p') {
    paint = !paint;
  }
  if(key == 'q'){
    mouseClicked();
  }
  if(key == 'a'){
    zDistance = zDistance-2;
    mouseClicked();
  }
  if(key == 'z'){
    rotateZ = !rotateZ;
  }
}
