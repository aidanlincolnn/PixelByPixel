//AIdan Fowler
//Pixel By Pixel
//Code from Danny Rozin

import processing.video.*;
float scale = .11;
int cell = 16;                                                   // this will be the size of our blocks
int count=0;
Capture video;
boolean autoRotate = false;

void setup() {
  size(1280, 720, P3D);                                         // must be P3D
  video= new Capture(this, width, height);
  video.start();
  noStroke();
  noCursor();
}

void draw() {
  background(0);
  lights();                                                       // need to call lights in the draw() to get the 3D shaded
  count++;  

  // increment our counter for some of the effects
  translate(width/2, height/2);                                   // translating to center of screen 
  if(autoRotate){
    //Auto Rotate Cube
    int angle = (count/3) % 360;
    float rotateX = (width/4)*sin(radians(angle));
    float rotateY = (width/4)*cos(radians(angle));
    scale(mouseY/200.0);
    rotateX(radians(rotateX));
    rotateY(radians(rotateY));
  }
  else{
    scale(scale);
    rotateX(radians(mouseY));
    rotateY(radians(mouseX));                                       
  }
  translate(-width/2, -height/2, 0);                             // translating back so our coordinates are synced between screen and video
  
  if (video.available ()) video.read();
  video.loadPixels();
  for (int x=350; x< 1070; x+= cell) {                      
    for (int y=0; y< 720; y+= cell) {
      PxPGetPixel(x, y, video.pixels, width);                    // get the RGB of the pixel
      float z = (255-R+255-G+255-B)/3;                           // calculate Z as the average inverse RGB which is inverse brightness
      //float z = sin(radians (count+x+y) )*50.0;                // this option applies a sine wave for the Z instead of brightness
      //float z = sin( radians(count+dist(x,y,width/2,height/2)))*50;// this option calculates the Z according to distance from center
      
      //Red side
      fill(R, 0, 0);                                            
      pushMatrix();                                              // push the matrix so we can pop it later and get a constant matrix fr all pixels
      translate(x, y,-z/2);                                      // translate to the position of our pixel minus half the z to get a flat back
      box(cell, cell, z);                                       // create a box the size of our cell with a Z as we calculated
      popMatrix();       // pop the matrix to return to the way it was before this pixel
      
      //Green side
      pushMatrix(); 
      fill(0, G, 0);
      rotateY(PI/2);
      translate(-1062,0,342);
      translate(x, y,-z/2);                                     
      box(cell, cell, -z);                                         
      popMatrix();
      
      //Blue Side
      pushMatrix(); 
      fill(0, 0, B);
      rotateY(-PI/2);
      translate(-342,0,-1062);
      translate(x, y,-z/2);                                     
      box(cell, cell, -z);                                         
      popMatrix();
      
      //Normal Side
      pushMatrix(); 
      fill(R, G, B);
      rotateY(-PI);
      translate(-1404,0,-720);
      translate(x, y,-z/2);                                      
      box(cell, cell, -z);                                         
      popMatrix();
      
      //Grayscale side
      pushMatrix();
      int gray = (R+G+B)/2;
      fill(gray, gray, gray);
      rotateX(-PI/2);
      translate(0,-708,8);
      translate(x, y,-z/2);                                      
      box(cell, cell, -z);                                         
      popMatrix();
      
      //inverse side
      pushMatrix();
      fill(255-R, 255-G, 255-B);
      rotateX(PI/2);
      translate(0,8,-708);
      translate(x, y,-z/2);                                      
      box(cell, cell, -z);                                         
      popMatrix();
    }
  }
}

void mousePressed(){
  rotateZ(mouseX);
}

void keyPressed(){
  scale += .05;
  if(scale>.5){
    scale = .05;
  }
}

int R, G, B, A;

void PxPGetPixel(int x, int y, int[] pixelArray, int pixelsWidth) {
  int thisPixel=pixelArray[x+y*pixelsWidth];     // getting the colors as an int from the pixels[]
  A = (thisPixel >> 24) & 0xFF;                  // we need to shift and mask to get each component alone
  R = (thisPixel >> 16) & 0xFF;                  // this is faster than calling red(), green() , blue()
  G = (thisPixel >> 8) & 0xFF;   
  B = thisPixel & 0xFF;
}


//our function for setting color components RGB into the pixels[] , we need to define the XY of where
// to set the pixel, the RGB values we want and the pixels[] array we want to use and it's width

void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);                       
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with te colors into the pixels[]
}
