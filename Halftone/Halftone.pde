/* Aidan Fowler
 * Pixel By Pixel
 * Pixel get / set code from Danny Rozin
 * 
 * Press "1" Key For circles
 * Press "2" Key For circles - polar (mouse click changes center point)
 * Press "3" Key For horizontal lines
 * Press "4" Key For vertical lines
 * Press "5" Key For diagonal lines
 * Press "6" Key For physics based stipple Light Spots To Dense Big Light Dots
 * Press "7" Key For physics based stipple Dark Spots To Big Dark Dots
 * Press "8" Key For physics based stipple Light Spots To Sparse Big Light Dots (negative / inverse)
 * Press "UP" Key For Bigger Particles (in modes 5-7)
 * Press "DOWN" Key For Smaller Particles (in modes 5-7)
 * Press "LEFT" Key For Fewer Particles (in modes 5-7)
 * Press "RIGHT" Key For More Particels (in modes 5-7)
 * Press "i" Key to select an image instead of webcam
 * Press "s" Key to save a pdf of the current view
 */

import processing.pdf.*;
import processing.video.*;
import java.io.File;
import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

Capture video;
float mouseXScale;
float mouseYScale;
PImage theImage;
boolean record; 
String fileName = "";
boolean fileLoaded = false;
boolean prompt = false;
int xStart = 0;
int yStart = 0;
boolean electricStippleLoaded = false;
//electric stipple particle  variables
float radiusRange = 10;
ArrayList<Particle> particles;
VerletPhysics2D physics;
float forceRadius = 10;
float forceStrength;
float drag = 1;
float minRadius = 0;
float maxRadius = 0;
int centerX;
int centerY;

int[] radiusSet = {1,3,5,7,9,13};

/****************************************************************************
* ***************************************************************************
* CHANGE THESE VARIBLES TO START IN DIFFERENT MODE / CHANGE PARTICLE SETTINGS
* ***************************************************************************
*****************************************************************************/
//see modes above
int drawMode = 1;
//start using the webcam, cant go back if this starts as true
boolean useVideo = false;
//more particles, more resolution, slower runtime
int totalParticles = 5000;
// this removes small dots to make machining easier
boolean drawSmallCircles = true;
// this uses radius set instead of radius range for particle sizes
boolean useRadiusSet = false;


void setup() {
  size(1440, 720);      
  String videoList[] = Capture.list();
  if(useVideo){
    for (int i = 0; i<videoList.length; i++) {
      if (String.valueOf(videoList[i]).equals("FaceTime HD Camera (Built-in)")) {
        println("camera:", String.valueOf(videoList[i]));
        println("opening camera");
        video = new Capture(this, 1440, 720, videoList[i]);
      }
    }
    centerX = video.width/2;
    centerY = video.height/2;
    video.start();
  }
  else{
    prompt = true;
  }
  
  theImage = new PImage();
  fill(0);
  smooth();
  noStroke();
  frameRate(10);
 
}

void draw() {
  if (record) {
    beginRecord(PDF, "halftone-####.pdf");
  }
  
  if (useVideo) {
    getImageFromVideo();
  } else {
    getImageFromPrompt(); 
  } 
  
  
  //draw the halftone image
  if (drawMode == 1) {
     mouseXScale = map(mouseX, 0, width, 0.01, 2);
     mouseYScale = map(mouseY, 0, height, 3, 25);
    makeCircleHalftone();
  } else if (drawMode == 2) {
     mouseXScale = map(mouseX, 0, width, 1.5, 2);
     mouseYScale = map(mouseY, 0, height, 2, 25);
    makeCircleHalftonePolar();
  }
  else if (drawMode == 3){
    mouseXScale = map(mouseX, 0, width, 0.01, 1.5);
     mouseYScale = map(mouseY, 0, height, 3, 35);
    makeHorizontalHalftone();
  } else if (drawMode == 4) {
    mouseXScale = map(mouseX, 0, width, 0.01, 1.5);
     mouseYScale = map(mouseY, 0, height, 3, 35);
    makeVerticalHalftone();
  } else if (drawMode == 5) {
    mouseXScale = map(mouseX, 0, width, 0.01, 1.5);
     mouseYScale = map(mouseY, 0, height, 3, 35);
    makeDiagnoalHalftone();
  } else if (drawMode >= 6){
    electricStipple();
  }
  
  //save frame if you click 's'
  if (record) {
    record = false;
    endRecord();
  }
}

//load resized webcam
void getImageFromVideo(){
  if (video.available())     video.read();
  int webCamToFramRatio = video.width / width;
  theImage = video.get(int((webCamToFramRatio-1)*video.width/(2*webCamToFramRatio)), 0, width, height);
  theImage.loadPixels();
  setDrawingCoordinates();
}

//get image from prompt, resize
void getImageFromPrompt(){
  if (prompt) {
      selectInput("Select a file to process", "fileSelected");
      prompt = false;
    }
    if (fileLoaded) {
      theImage = loadImage(fileName);
      //resize image to take up entire canvas width or height
      float xRatio = float(theImage.width) / float(width);
      float yRatio = float(theImage.height)/float(height);
      if (theImage.height/xRatio > height) {
        xRatio = float(theImage.height) / float(height);
      }
      if (theImage.width/yRatio > width) {
        yRatio = float(theImage.width)/float(width);
      }
      if (theImage.width>=theImage.height) {
        theImage.resize(int(float(theImage.width)/xRatio), int(float(theImage.height)/xRatio));
      } else if (theImage.height>=theImage.width) {
        theImage.resize(int(float(theImage.width)/yRatio), int(float(theImage.height)/yRatio));
      }
      fileLoaded = false;
      electricStippleLoaded = false;
      theImage.loadPixels();
      centerX = theImage.width/2;
      centerY = theImage.height/2;
      setDrawingCoordinates();
    }
}

//we center and resize images so we need to draw the halftone at a non 0,0 location
void setDrawingCoordinates(){
  //set up starting points to draw based on image dimensions so we always center on x and y
  float xRatio = float(theImage.width) /float(width);
  float yRatio = float(theImage.height)/float(height);
  xStart = int(float(width)*(1.0-xRatio)/2.0);
  yStart = int(float(height)*(1.0-yRatio)/2.0);
  constrain(xStart, 0, width);
  constrain(yStart, 0, height);
}

void makeCircleHalftone() {
  background(255);
  fill(0);
  noStroke();
  boolean offSet = true;
  for (int x=0; x<theImage.width; x+=mouseYScale) {
    for (int y=0; y<theImage.height-int(mouseYScale/2); y+=mouseYScale) {
      if (offSet) {
        drawHalftoneCircle(theImage, x, y+int(mouseYScale/2));
      } else {
        drawHalftoneCircle(theImage, x, y);
      }
    }
    offSet = !offSet;
  }
}

void drawHalftoneCircle(PImage frame, int x, int y) {
  PxPGetPixel(x, y, frame.pixels, frame.width);
  float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
  // greyscale to ellipse area
  float r1 = map(greyscale, 0, 255, mouseYScale, .01)*mouseXScale;
  ellipse(x+xStart, y+yStart, r1, r1);
}

void makeCircleHalftonePolar(){
  background(255);
  fill(0);
  noStroke();
  float maxRadius = theImage.width/2.0;
  if(theImage.height/2>maxRadius){
    maxRadius = theImage.height/2.0;
  }
  float move = dist(theImage.width/2,theImage.height/2,centerX,centerY);
  maxRadius += move;
  maxRadius *= sqrt(2);
  
  boolean offSet = false;
  for(float r = mouseYScale; r < maxRadius; r+= mouseYScale*2){
    float rotation = PI/(r)*mouseYScale/mouseXScale;
    float percentOfCircle = rotation/(2.0*PI);
    if(offSet){
      for(float percent = percentOfCircle/2.0; percent < 1.0; percent += percentOfCircle){
        int x = int(r*cos(percent*2.0*PI));
        int y = int(r*sin(percent*2.0*PI));
        if(x+centerX< theImage.width &&  x+centerX>0&& y+centerY <theImage.height && y+centerY >0){
          drawHalftoneCirclePolar(theImage,x+centerX,y+centerY);
        }
      }
    }
    else{
      for(float percent = 0; percent < 1.0-percentOfCircle/2.0; percent += percentOfCircle){
        int x = int(r*cos(percent*2.0*PI));
        int y = int(r*sin(percent*2.0*PI));
        if(x+centerX< theImage.width &&  x+centerX>0&& y+centerY <theImage.height && y+centerY >0){
          drawHalftoneCirclePolar(theImage,x+centerX,y+centerY);
        }
      }
    }
    offSet = !offSet;
  }
}

void drawHalftoneCirclePolar(PImage frame, int x, int y) {
  PxPGetPixel(x, y, frame.pixels, frame.width);
  float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
  // greyscale to ellipse area
  float r1 = map(greyscale, 0, 255, mouseYScale, .01)*mouseXScale;
  ellipse(x+xStart, y+yStart, r1, r1);
}

void makeVerticalHalftone() {
  background(255);
  noStroke();
  fill(0);
  for (int x=0; x<theImage.width; x+= mouseYScale) {
    beginShape(); 
    for (int y=0; y<theImage.height; y+=mouseYScale) {
      PxPGetPixel(x, y, theImage.pixels, theImage.width);
      float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
      float channelWidth = constrain(map(greyscale, 0, 255, mouseYScale, 0.1)*mouseXScale, 0, mouseYScale/2.1);
      curveVertex(x-channelWidth+xStart, y+yStart);
    }
    for (int y = theImage.height-1; y>0; y-= mouseYScale) {
      PxPGetPixel(x, y, theImage.pixels, theImage.width);
      float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
      float channelWidth = constrain(map(greyscale, 0, 255, mouseYScale, 0.1)*mouseXScale, 0, mouseYScale/2.1);
      curveVertex(x+channelWidth+xStart, y+yStart);
    }
    endShape();
  }
}

void makeHorizontalHalftone() {
  background(255);
  noStroke();
  fill(0);
  for (int y=0; y<theImage.height; y+=mouseYScale) {
    beginShape(); 
    for (int x=0; x<theImage.width; x += mouseYScale) {
      PxPGetPixel(x, y, theImage.pixels, theImage.width);
      float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
      float channelWidth = constrain(map(greyscale, 0, 255, mouseYScale, 0.1)*mouseXScale, 0, mouseYScale/2.1);
      curveVertex(x+xStart, y-channelWidth+yStart);
    }
    for (int x = theImage.width-1; x>0; x-= mouseYScale) {
      PxPGetPixel(x, y, theImage.pixels, theImage.width);
      float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
      float channelWidth = constrain(map(greyscale, 0, 255, mouseYScale, 0.1)*mouseXScale, 0, mouseYScale/2.1);
      curveVertex(x+xStart, y+channelWidth+yStart);
    }
    endShape();
  }
}

void makeDiagnoalHalftone() {
  background(255);
  noStroke();
  fill(0);
  for (int start = 0; start<theImage.width; start +=mouseYScale) {
    beginShape();
    for (int x = 0; x<theImage.width-start; x+=mouseYScale) {
      if (x<theImage.height-1) {
        PxPGetPixel(x+start, x, theImage.pixels, theImage.width);
        float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
        float channelWidth = constrain(map(greyscale, 0, 255, mouseYScale, 0.1)*mouseXScale, 0, mouseYScale/2.1);
        curveVertex(x+start+channelWidth/2+xStart, x-channelWidth/2+yStart);
      }
    }
    for (int x = theImage.width-start; x>0; x-=mouseYScale) {
      if (x<theImage.height-1) {
        PxPGetPixel(x+start, x, theImage.pixels, theImage.width);
        float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
        float channelWidth = constrain(map(greyscale, 0, 255, mouseYScale, 0.1)*mouseXScale, 0, mouseYScale/2.1);
        curveVertex(x+start-channelWidth/2+xStart, x+channelWidth/2+yStart);
      }
    }
    endShape();
  }

  for (int start = int(mouseYScale); start<theImage.height; start += mouseYScale) {
    beginShape();
    for (int y = 0; y<theImage.height-start; y+= mouseYScale) {
      if (y+start<theImage.height-1) {
        PxPGetPixel(y, start+y, theImage.pixels, theImage.width);
        float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
        float channelWidth = constrain(map(greyscale, 0, 255, mouseYScale, 0.1)*mouseXScale, 0, mouseYScale/2.1);
        curveVertex(y+channelWidth/2+xStart, y+start-channelWidth/2+yStart);
      }
    }
    for (int y = theImage.height-start; y>0; y-= mouseYScale) {
      if (y+start<theImage.height-1) {
        PxPGetPixel(y, start+y, theImage.pixels, theImage.width);
        float greyscale = (0.3 * R) + (0.59 * G) + (0.11 * B);
        float channelWidth = constrain(map(greyscale, 0, 255, mouseYScale, 0.1)*mouseXScale, 0, mouseYScale/2.1);
        curveVertex(y-channelWidth/2+xStart, y+start+channelWidth/2+yStart);
      }
    }
    endShape();
  }
}

void electricStipple(){
  if(!electricStippleLoaded){
    resetParticles();
    electricStippleLoaded = true;
  }
  background (0); 
  noStroke();
  setPhyiscsAndRadiusForMode();
  for (Particle p: particles) {
    if(int(p.x)<theImage.width && int(p.y)<theImage.height && int(p.x)>0 && int(p.y)>0){
      //get pixel from main image at particle location
      PxPGetPixel(int(p.x), int(p.y), theImage.pixels, theImage.width);
      //map greyscale of pixel to radius size of particle
      float particleRadius;
      if(useRadiusSet){
        float particleRadius0 = map((0.3 * R) + (0.59 * G) + (0.11 * B), 0,255,0,radiusSet.length-1);
        particleRadius = radiusSet[int(particleRadius0)];
      }
      else{
        particleRadius = map((0.3 * R) + (0.59 * G) + (0.11 * B), 0,255,minRadius,maxRadius); 
      }
      
      //update the particle size and physics
      p.updateParticle(particleRadius,forceStrength,forceRadius,drawMode,drawSmallCircles, xStart, yStart);
    }
  }
  physics.update();
}

void setPhyiscsAndRadiusForMode(){
  if(drawMode ==6) {
    println("White Mode, Light = More Dense White Dots");
    fill(255);
    background(0);
    forceStrength = map(mouseX,xStart,xStart+theImage.width,0,25);
    forceRadius = map(mouseY,yStart,yStart+theImage.width,0,45);
    minRadius = 1;
    maxRadius = radiusRange;
  }
  else if(drawMode == 7){
    println("Black Mode, Dark = More Dense Black Dots");
    fill(0);
    background(255);
    forceStrength = map(mouseX,xStart,xStart+theImage.width,0,25);
    forceRadius = map(mouseY,yStart,yStart+theImage.height,0,45);
    minRadius = radiusRange;
    maxRadius = 1;
  }
  else if(drawMode == 8){
    println("Inverse Mode, Light = Less Dense But Bigger White Dots");
    fill(255);
    background(0);
    forceStrength = map(mouseX,xStart,xStart+theImage.width,0,2);
    forceRadius = map(mouseY,yStart,yStart+theImage.height,0,10);
    minRadius = 1;
    maxRadius = radiusRange;
  }
  
  println("force strength:",forceStrength);
  println("force radius:",forceRadius);
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
  //fill(R,G,B);
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

void resetParticles(){
  println("reset particles");
  physics = new VerletPhysics2D ();
  physics.setDrag(drag);
  particles = new ArrayList<Particle>();
  for (int i = 0; i < totalParticles; i++) {
    particles.add(new Particle(new Vec2D(random(theImage.width),random(theImage.height))));
  }
  physics.setWorldBounds(new Rect(-25,-25,theImage.width+20,theImage.height+25));
}

void keyPressed() {
  if (key == '1') drawMode = 1;
  else if (key == '2') drawMode = 2;
  else if (key == '3') drawMode = 3;
  else if (key == '4') drawMode = 4;
  else if (key == '5') drawMode = 5;
  else if (key == '6') {
    drawMode = 6;
  }
  else if (key == '7') {
    drawMode = 7;
  }
  else if (key == '8') {
    drawMode = 8;
  }
  else if (key == 's') record = true;
  else if (key == 'i') {
    useVideo = false;
    prompt = true;
  }
  else if(key == CODED){
    if(keyCode == UP){
      radiusRange ++;
    }
    else if(keyCode == DOWN){
       radiusRange --;
    }
    else if(keyCode == RIGHT){
      totalParticles += 1000;
      resetParticles();
    }
    else if(keyCode == LEFT){
      totalParticles -= 1000;
      resetParticles();
    }
  }
  else if (key == 'r'){
    resetParticles();
  }
}

void mouseClicked(){
  if(drawMode == 2){
    centerX = mouseX;
    centerY = mouseY;
  }
}
