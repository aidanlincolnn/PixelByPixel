/* Aidan Fowler
 * Pixel By Pixel
 * Code for halftone based on Generative Design in P5.js
 * Pixel get / set code from Danny Rozin
 * 
 * Press "1" Key For circles
 * Press "2" Key For lines - in this mode "l" key increases line length, "l" key decreases line length, the "m" key changes the direction
 * Press "i" Key to select an image instead of webcam
 * Press "s" key to save a pdf of the current view
 */

import processing.pdf.*;
import processing.video.*;
import java.io.File;

Capture video;
int drawMode = 1;
int lineLength = 17;
float mouseXScale = 1;
float mouseYScale = 1;
PImage squareFrame;
boolean record; 
boolean useVideo = true;
String fileName = "";
boolean fileLoaded = false;
boolean prompt = false;
float changeX = 1;
float changeY = 1;
int xStart = 0;
int yStart = 0;

void setup() {
  size(1440, 720);      
  String videoList[] = Capture.list();
  video = new Capture(this, 1440, 720, videoList[0]);
  video.start();
  squareFrame = new PImage();
}

void draw() {
  if (record) {
    beginRecord(PDF, "halftone-####.pdf");
  }
  background(255);
  if(drawMode ==1){
    mouseXScale = map(mouseX, 0, width, 0.01, 2.5);
  }
  else if (drawMode == 2){
    mouseXScale = map(mouseX,0,width,0.01,1.5);
  }
  mouseYScale = map(mouseY, 0, width, 3, 30);
  if (useVideo) {
    if (video.available())     video.read();
    int webCamToFramRatio = video.width / width;
    squareFrame = video.get(int((webCamToFramRatio-1)*video.width/(2*webCamToFramRatio)), 0, width, height);
} 
  else {
    if(prompt){
      selectInput("Select a file to process", "fileSelected");
      prompt = false;  
    }
    if(fileLoaded){
      squareFrame = loadImage(fileName);
      //resize image to take up entire canvas width or height
      float xRatio = float(squareFrame.width) / float(width);
      float yRatio = float(squareFrame.height)/float(height);
      if(squareFrame.height/xRatio > height){
        xRatio = float(squareFrame.height) / float(height);
      }
      if(squareFrame.width/yRatio > width){
        yRatio = float(squareFrame.width)/float(width);
      }
      if(squareFrame.width>=squareFrame.height){
        squareFrame.resize(int(float(squareFrame.width)/xRatio), int(float(squareFrame.height)/xRatio));
      }
      else if(squareFrame.height>=squareFrame.width){
        squareFrame.resize(int(float(squareFrame.width)/yRatio), int(float(squareFrame.height)/yRatio));
      }
      fileLoaded = false;
    }
  }

  squareFrame.loadPixels();
  
  //set up starting points to draw based on image dimensions so we always center on x and y
  float xRatio = float(squareFrame.width) /float(width);
  float yRatio = float(squareFrame.height)/float(height);
  xStart = int(float(width)*(1.0-xRatio)/2.0);
  yStart = int(float(height)*(1.0-yRatio)/2.0);
  constrain(xStart,0,width);
  constrain(yStart,0,height);
  for (int x=0; x<squareFrame.width; x+=mouseYScale) {
    for (int y=0; y<squareFrame.height; y+=mouseYScale) {
      makeHalftone(squareFrame, x, y);
    }
  }

  if (record) {
    record = false;
    endRecord();
  }
}

void makeHalftone(PImage frame, int x, int y) {
  PxPGetPixel(x, y, frame.pixels, frame.width);
  float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);

  switch (drawMode) {
  case 1:
    // greyscale to ellipse area
    fill(0);
    noStroke();
    float r1 = map(greyscale, 0,255,mouseYScale,.01)*mouseXScale;
    ellipse(x+xStart, y+yStart, r1, r1);
    break;
    
  case 2:
    // greyscale to stroke weight
    float w1 = map(greyscale, 0, 255, mouseYScale, 0.1);
    stroke(0);
    strokeWeight((w1 * mouseXScale));
    line(x+xStart, y+yStart, x + xStart+lineLength*changeX, y +yStart+ lineLength*changeY);
    break;
  }
}


void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName = selection.getAbsolutePath();
    fileLoaded = true;
  }
}

// our function for getting color components , it requires that you have global variables
// R,G,B   (not elegant but the simples way to go, see the example PxP methods in object for 
// a more elegant solution
int R, G, B, A;          // you must have these global varables to use the PxPGetPixel()
void PxPGetPixel(int x, int y, int[] pixelArray, int pixelsWidth) {
  int thisPixel=pixelArray[x+y*pixelsWidth];     // getting the colors as an int from the pixels[]
  A = (thisPixel >> 24) & 0xFF;                  // we need to shift and mask to get each component alone
  R = (thisPixel >> 16) & 0xFF;                  // this is faster than calling red(), green() , blue()
  G = (thisPixel >> 8) & 0xFF;   
  B = thisPixel & 0xFF;
}


//our function for setting color components RGB into the pixels[] , we need to efine the XY of where
// to set the pixel, the RGB values we want and the pixels[] array we want to use and it's width

void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);                       
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with te colors into the pixels[]
}

void keyPressed() {
  if (key == '1') drawMode = 1;
  if (key == '2') drawMode = 2;
  if (key == 'p') lineLength++;
  if (key == 'l') lineLength--;
  if (key == 's') record = true;
  if (key == 'i') {
    useVideo = !useVideo;
    prompt = true;  
  }
  if(key == 'm'){
    if(changeX == 0 && changeY >= 1){
      changeX = 1;
      changeY = 1;
    }
    else if(changeX == 1 && changeY == 1){
      changeX = sqrt(2);
      changeY = 0;
    }
    else if(changeX >= 1 && changeY == 0){
      changeY = -1;
      changeX = 1;
    }
    else if(changeX >= 1 && changeY <= -1){
      changeX = 0;
      changeY = -sqrt(2);
    }
    else if(changeX == 0 && changeY <= -1){
      changeX = -1;
      changeY = -1;
    }
    else if(changeX <= -1 && changeY <= -1){
      changeY = 0;
      changeX = -sqrt(2);
    }
    else if(changeX <= -1 && changeY == 0){
      changeY = 1;
      changeX = -1;
    }
    else if(changeX <= -1 && changeY >= 1){
      changeX = 0;
      changeY = sqrt(2);
    }
  }
}
