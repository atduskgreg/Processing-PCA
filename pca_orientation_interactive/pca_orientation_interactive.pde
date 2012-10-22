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

PVector centroid;

void setup() {
  size(640, 480);
  opencv = new OpenCV(this);
  opencv.capture(imgWidth, imgHeight);

  centroid = new PVector();
}

Matrix toMatrix(PImage img) {
  ArrayList<PVector> points = new ArrayList<PVector>();
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      int i = y*img.width + x;
      if (brightness(img.pixels[i]) > 0) {
        points.add(new PVector(x, y));
      }
    }
  }

  Matrix result = new Matrix(points.size(), 2);

  float centerX = 0;
  float centerY = 0;

  for (int i = 0; i < points.size(); i++) {
    result.set(i, 0, points.get(i).x);
    result.set(i, 1, points.get(i).y);

    centerX += points.get(i).x;
    centerY += points.get(i).y;
  }
  centerX /= points.size();
  centerY /= points.size();
  centroid.x = centerX;
  centroid.y = centerY;

  return result;
}



void imageInGrid(PImage img, String message, int row, int col) {
  int currX = col*img.width;
  int currY = row*img.height;
  image(img, currX, currY);
  fill(255, 0, 0);
  text(message, currX + 5, currY + imgHeight - 5);
}

void draw() {
  background(125);

  opencv.read();
  opencv.convert(GRAY);
  imageInGrid(opencv.image(), "GRAY", 0, 0);

  opencv.absDiff();
  imageInGrid(opencv.image(), "DIFF", 0, 1);

  opencv.brightness(60);
  imageInGrid(opencv.image(), "BRIGHTNESS: 60", 0, 2);

  opencv.threshold(40);
  imageInGrid(opencv.image(), "THRESHOLD: 40", 0, 3);

  opencv.contrast(120);
  imageInGrid(opencv.image(), "CONTRAST: 120", 1, 3);

  Matrix m = toMatrix(opencv.image());

  if (m.getRowDimension() > 0) {
    pca = new PCA(m);
    Matrix eigenVectors = pca.getEigenvectorsMatrix();

    axis1 = new PVector();
    axis2 = new PVector();
    if (eigenVectors.getColumnDimension() > 1) {

      axis1.x = (float)eigenVectors.get(0, 0);
      axis1.y = (float)eigenVectors.get(1, 0);

      axis2.x = (float)eigenVectors.get(0, 1);
      axis2.y = (float)eigenVectors.get(1, 1);  

      axis1.mult((float)pca.getEigenvalue(0));
      axis2.mult((float)pca.getEigenvalue(1));
    }
    image(opencv.image(), 0, opencv.image().height, opencv.image().width*3, opencv.image().height*3);



    stroke(200);
    pushMatrix();
    translate(0, imgHeight);
    scale(3, 3);

    translate(centroid.x, centroid.y);

    stroke(0, 255, 0);
    line(0, 0, axis1.x, axis1.y);
    stroke(255, 0, 0);
    line(0, 0, axis2.x, axis2.y);

    popMatrix();
    fill(0, 255, 0);
    text("PCA Object Axes:\nFirst two principle components centered at blob centroid", 10, height - 20);
  }
}

void keyPressed() {
  opencv.remember();
}

