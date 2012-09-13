/*
Altered from openCV blob example. 
opencv library: http://ubaa.net/shared/processing/opencv/index.html

9/12: changing background reference every 5 seconds.
      printing out number of found blob.
      set threshold to 80.
      throshold not adjustable.
      hide original image and grayscale.
      big move detection by checking if the shange area more than 20% of whole frame. once it detects big move, ignore it for 4 seconds.

9/13: add big move notice
      delete 5 second timer, 4 second timer
      print out area difference in blob.
      rearrange layout (only showing last frame and difference)
      add sample rate = framerate = 5 fps.
      add graphic showing the blob total area change.
      
*/

import hypermedia.video.*;
import java.awt.Rectangle;
import java.awt.Point;


OpenCV opencv;

int w = 320;
int h = 240;
int threshold = 80;    
int blobTotalArea = 0;  //total pixel sum in blobs.
int[] blobTotalAreaRecords = new int[w*2+30];

boolean find=true;

PFont font;
PFont font2;

void setup() {

    size( w*2+30, h+30+50);
    frameRate(5); // excute 20 times draw function per seconds. also means 5 fps of reference background sampling rate.

    opencv = new OpenCV( this );
    opencv.capture(w,h);
    
    font = loadFont( "AndaleMono.vlw" );
//    font2 = loadFont( "AndaleMono-48.vlw" );

    textFont( font );

//  println( "Drag mouse inside sketch window to change threshold" );
    println( "Press space bar to record background image" );
    opencv.remember();  // first reference. 
}



void draw() {
  
    int areaSum = 0;  //local variable of blob area add up

    background(0);


    opencv.read();
    //opencv.flip( OpenCV.FLIP_HORIZONTAL );
    opencv.absDiff();
    opencv.threshold(threshold);
    image( opencv.image(OpenCV.MEMORY), 10, 20 ); // image in memory
    image( opencv.image(), 20+w, 20 ); // absolute difference image (substracted)
    opencv.remember();// for next time reference.


    // working with blobs
    Blob[] blobs = opencv.blobs( 100, w*h/3, 20, false );
    //blobs(minArea, maxArea, maxBlobs, findHoles);            

    noFill();

    pushMatrix();
    translate(20+w,20);
    
    for( int i=0; i<blobs.length; i++ ) {

        textFont( font );

        Rectangle bounding_rect	= blobs[i].rectangle;
        float area = blobs[i].area;
        float circumference = blobs[i].length;
        Point centroid = blobs[i].centroid;
        Point[] points = blobs[i].points;
        
        areaSum += area;

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
    
    blobTotalArea = int(float(areaSum)/(w*h)*100);
    println(hour()+":"+minute()+":"+second()+"  "+blobTotalArea);
//
    for(int i = 0; i < blobTotalAreaRecords.length-1; i++){ //shift blobtotalarea array by one item 
      blobTotalAreaRecords[i] = blobTotalAreaRecords[i+1];  //and push new blobTotalArea to the last one 
//      println(blobTotalAreaRecords[i]);
    }
     blobTotalAreaRecords[blobTotalAreaRecords.length-1] = blobTotalArea;

    for(int i = 0; i < blobTotalAreaRecords.length; i++){
         stroke(255);
      line(i, height,i, height-(blobTotalAreaRecords[i]));
    }
    
    if (blobTotalArea > 20) { //moved area is more than 20% of whole frame.
      println("===============big move===============");
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
