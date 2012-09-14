/**
 * based on background subtraction example in video library
 * saving difference area into a PImage call diffImg.
*/

import processing.video.*;


Capture cam;

int w = 320;
int h = 240;
PImage diffImg = createImage(w, h, RGB);
int numPixels;
int[] lastFramePixels;

void setup(){
  frameRate(5);
  size(w*2+30, h+30+50, P2D); //P2D is faster default renderer JAVA2D, WHY?
  background(0);
  
  cam = new Capture(this, 320, 240, 15);//Capture(parent, requestWidth, requestHeight, frameRate)
  cam.start();
  numPixels = w * h;
  // Create array to store the background image
  lastFramePixels = new int[numPixels];
  // Make the pixels[] array available for direct manipulation
  diffImg.loadPixels();
}

void draw(){
  
  
  if (cam.available() == true) {  //SAME AS void captureEvent(capture c){ c.read(); }
    cam.read(); //Read new video frame
    cam.loadPixels(); //make the pixels of video available
  }
  
  // Difference between the current frame and the stored background
  int movementSum = 0;
  
  for(int i = 0 ; i < numPixels; i++ ){// For each pixel in the video frame...
      // Fetch the current color in that location, and also the color
      // of the background in that spot
      color currColor = cam.pixels[i];
      color lastColor = lastFramePixels[i];
      // Extract the red, green, and blue components of the current pixel�s color
      int currR = (currColor >> 16) & 0xFF;
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract the red, green, and blue components of the background pixel�s color
      int lastR = (lastColor >> 16) & 0xFF;
      int lastG = (lastColor >> 8) & 0xFF;
      int lastB = lastColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - lastR);
      int diffG = abs(currG - lastG);
      int diffB = abs(currB - lastB);
      // Add these differences to the running tally
      movementSum += diffR + diffG + diffB;
      // Render the difference image to the screen
      // pixels[i] = color(diffR, diffG, diffB);
      // The following line does the same thing much faster, but is more technical
      diffImg.pixels[i] = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
      lastFramePixels[i] = currColor;
    }
    diffImg.updatePixels();
    image(diffImg, 20,30);
    println(movementSum); // Print out the total amount of movement
  }
