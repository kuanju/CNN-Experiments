/*
Altered from openCV blob example. 

9/12: changing background reference every 5 seconds.
      printing out number of found blob.
      set threshold to 80.
      throshold not adjustable.
      hide original image and grayscale.
      big move detection by checking if the shange area more than 20% of whole frame. once it detects big move, ignore it for 4 seconds.

9/13: add big move notice
      delete 5 second timer, 4 second timer
      print out area difference in blob.
      
*/

import hypermedia.video.*;
import java.awt.Rectangle;
import java.awt.Point;



OpenCV opencv;

int w = 320;
int h = 240;
int threshold = 80;

//long lastBackgroundSavedTime = millis();
//long lastBigMoveTime = millis();
//boolean bigMove = false;

boolean find=true;

PFont font;
PFont font2;

void setup() {

    size( w*2+30, h*2+30);

    opencv = new OpenCV( this );
    opencv.capture(w,h);
    
    font = loadFont( "AndaleMono.vlw" );
    font2 = loadFont( "AndaleMono-48.vlw" );

    textFont( font );

//    println( "Drag mouse inside sketch window to change threshold" );
    println( "Press space bar to record background image" );

}



void draw() {
  
    int blobAreaTotal = 0;


    background(0);
    opencv.read();
    //opencv.flip( OpenCV.FLIP_HORIZONTAL );

//    image( opencv.image(), 10, 10 );	             // RGB image
//    image( opencv.image(OpenCV.GRAY), 20+w, 10 );   // GRAY image
    image( opencv.image(OpenCV.MEMORY), 10, 20+h ); // image in memory

    opencv.absDiff();
    opencv.threshold(threshold);
    image( opencv.image(OpenCV.GRAY), 20+w, 20+h ); // absolute difference image


    // working with blobs
    Blob[] blobs = opencv.blobs( 100, w*h/3, 20, false );
    //blobs(minArea, maxArea, maxBlobs, findHoles);
//    println("detected "+ blobs.length + " blobs");
    
    
    if(millis()-lastBackgroundSavedTime > 5000){
       opencv.remember();  
       lastBackgroundSavedTime = millis();
    }
        


    noFill();

    pushMatrix();
    translate(20+w,20+h);
    
    for( int i=0; i<blobs.length; i++ ) {

        textFont( font );

        Rectangle bounding_rect	= blobs[i].rectangle;
        float area = blobs[i].area;
        float circumference = blobs[i].length;
        Point centroid = blobs[i].centroid;
        Point[] points = blobs[i].points;
        
        blobAreaTotal += area;

        // rectangle
        noFill();
        stroke( blobs[i].isHole ? 128 : 64 );
        rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );


        // centroid
        stroke(0,0,255);
        line( centroid.x-5, centroid.y, centroid.x+5, centroid.y );
        line( centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
        noStroke();
        fill(0,0,255);
        text( area,centroid.x+5, centroid.y+5 );


        fill(255,0,255,64);
        stroke(255,0,255);
        if ( points.length>0 ) {
            beginShape();
            for( int j=0; j<points.length; j++ ) {
                vertex( points[j].x, points[j].y );
            }
            endShape(CLOSE);
        }

        noStroke();
        fill(255,0,255);
        text( circumference, centroid.x+5, centroid.y+15 );

    }
    popMatrix();
    
    if (blobAreaTotal > w*h*0.2 && millis()-lastBigMoveTime > 4000) { //moved area is more than 20% of whole frame. once it happened, ignore it for 4 sec.
      println("big move");
      lastBigMoveTime = millis();
      bigMove = true;
    }else{
      println(" ");
      bigMove = false;
    } 
    
    
    if(bigMove){
        font2 = loadFont("AndaleMono-48.vlw");
        textFont(font2);
        fill(255);
        text( blobAreaTotal,50, 50);
    }
    
}

void keyPressed() {
    if ( key==' ' ) opencv.remember();
}

void mouseDragged() {
//    threshold = int( map(mouseX,0,width,0,255) );
}

public void stop() {
    opencv.stop();
    super.stop();
}
