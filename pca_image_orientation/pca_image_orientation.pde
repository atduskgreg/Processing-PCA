import Jama.Matrix;
import pca_transform.*;
import hypermedia.video.*;

PCA pca;

PVector axis1;
PVector axis2;
PVector mean;

OpenCV opencv;

PImage img;

int imgWidth = 640/4;
int imgHeight = 480/4;

void setup() {
  size(640, 480);
  opencv = new OpenCV(this);
  opencv.loadImage("data/pen_orientation-0.png", imgWidth, imgHeight);
  noLoop();
}

Matrix toMatrix(PImage img) {
  ArrayList<PVector> points = new ArrayList<PVector>();
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      int i = y*img.width + x;
      if (brightness(img.pixels[i]) == 0) {
        points.add(new PVector(x, y));
      }
    }
  }

  println("nBlackPixels: " + points.size() + "/" + img.width*img.height);
  Matrix result = new Matrix(points.size(), 2);

  for (int i = 0; i < points.size(); i++) {
    result.set(i, 0, points.get(i).x);
    result.set(i, 1, points.get(i).y);
  }

  return result;
}


int currX = 0;
int currY = 0;
void imageInGrid(PImage img, String message) {
  image(img, currX, currY);
  fill(255, 0, 0);
  text(message, currX + 5, currY + imgHeight - 5);

  currX += img.width;
  if (currX > width - img.width) {
    currX = 0;
    currY += img.height;
  }
}

void draw() {
  //background(255);
  opencv.convert(GRAY);
  imageInGrid(opencv.image(), "GRAY");

  opencv.brightness(30);
  imageInGrid(opencv.image(), "BRIGHTNESS: 30");

  opencv.contrast(120);
  imageInGrid(opencv.image(), "CONTRAST: 120");

  opencv.threshold(128);
  imageInGrid(opencv.image(), "THRESHOLD: 128");

  Matrix m = toMatrix(opencv.image());
  pca = new PCA(m);
  Matrix eigenVectors = pca.getEigenvectorsMatrix();

  eigenVectors.print(10, 2);

  axis1 = new PVector();
  axis2 = new PVector();
  axis1.x = (float)eigenVectors.get(0, 0);
  axis1.y = (float)eigenVectors.get(1, 0);

  axis2.x = (float)eigenVectors.get(0, 1);
  axis2.y = (float)eigenVectors.get(1, 1);  

  axis1.mult((float)pca.getEigenvalue(0));
  axis2.mult((float)pca.getEigenvalue(1));



  image(opencv.image(), 0, opencv.image().height, opencv.image().width*3, opencv.image().height*3);

  Blob[] blobs = opencv.blobs(10, imgWidth*imgHeight/2, 100, true, OpenCV.MAX_VERTICES*4 ); 
  noFill();
    stroke(200);
    pushMatrix();
  translate(0, imgHeight);
  scale(3, 3);
  for ( int i=0; i<blobs.length; i++ ) {
    beginShape();
    for ( int j=0; j<blobs[i].points.length; j++ ) {
      vertex( blobs[i].points[j].x, blobs[i].points[j].y );
    }
    endShape(CLOSE);

  }


  PVector centroid = new PVector(blobs[0].centroid.x, blobs[0].centroid.y);
  translate(centroid.x, centroid.y);

  stroke(0, 255, 0);
  line(0, 0, axis1.x, axis1.y);
  stroke(255, 0, 0);
  line(0, 0, axis2.x, axis2.y);
  popMatrix();
  fill(255,0,0);
  text("PCA Object Axes:\nFirst two principle components centered at blob centroid", 10, height - 20);
}

void draw(Matrix m) {
  double[][] a = m.getArray();
  for (int i = 0; i < m.getRowDimension(); i++) {
    ellipse((float)a[i][0], (float)a[i][1], 3, 3);
  }
}
