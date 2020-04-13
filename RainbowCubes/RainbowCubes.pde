// The world pixel by pixel 2020
// Aidan Fowler
// rotates 3d grid of rainbow boxes changing size and space between them with mouse
// Original code from Danny ROzin

int count = 0;
int xCord = 1;
int yCord = 1;
boolean reverseX = false;
boolean reverseY = false;
void setup() {
  size (700, 700, P3D);                      // must be P3D
  fill(255, 0, 255);
  smooth();
}

void draw() {
  //This code auto moves the rotation of the canvas which makes the cube move
  if(!reverseX){
    xCord += 2;
  }
  else{
    xCord -= 2;
  }
  if(xCord >= width){
    xCord -=2;
    reverseX = true;
  }
  if(xCord <=-100){
    xCord+=2;
    reverseX = false;
  }
  if(!reverseY){
    yCord +=2;
  }
  else{
    yCord -=2;
  }
  if(yCord >= height+200){
    yCord -=2;
    reverseY = true;
  }
  if(yCord <=-100){
    yCord+=2;
    reverseY = false;
  }
  
  count++;
  lights();                                 // must call lights() in draw() or it wont work
  //background(0);
  translate(width/2, height/2, -100);       // translating to the center of screen so we can rotate around center
  rotateX(xCord/100.0);                     // rotating on X, and Y with mouse
  rotateY(yCord/100.0);
  translate(-width/2, -height/2, 100);     // after establishing the rotation we reverse the translation for the rest of the drawing

  //distance between cubes determed by mouseX
  int spacing = mouseX/4;
  translate (10, 10);                                   // translating left and down a bit so we dont start at the corner
  for (int x= 0;x< 10;x++) {                               
    for (int y= 0;y< 10;y++) {
      for (int z= 0;z< 10;z++) {
        pushMatrix();                                   // for each box we will translate to where we want so we say pushMatrix, so we can revert to it
        translate(x*spacing, y*spacing, -z*spacing);    // translating by absolute amounts on the X,Y,Z
        rotateX(count/3);
        rotateY(count/5);
        rotateZ(count/7);
        int R = x*25;
        int G = y*25;
        int B = z*25;
        fill(R, G, B);                                  // setting a fill color based on X,Y,Z
        //size of boxes based on mouseY
        box(mouseY/10);                                 // the box is always drawn at 0,0,0 but since we did a transaltion it will be in the right place
        popMatrix();                                    // revertig our matrix so it will be ready for the next box
      }
    }
  }
  noStroke();
  //draw a giant white box with low alpha to create background fade
  fill(255,255,255,5);
  box(width*10);
  stroke(255);
}
