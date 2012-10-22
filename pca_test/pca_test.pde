import Jama.Matrix;
import pca_transform.*;

Matrix originalData;
Matrix eigenVectors;
PCA pca;
Matrix rotated;

PVector axis1;
PVector axis2;
PVector mean;

void setup(){
  size(500, 500);
  originalData = new Matrix(50, 2);
    mean = new PVector();

  for(int r = 0; r < originalData.getRowDimension(); r++){
    double yValue = 50 + 5*r * random(0.8,1.2) + 5 + random(-5,5);
    double xValue = r*6 + 5 + random(-3, 3);
    originalData.set(r, 0, xValue);
    originalData.set(r,1,yValue);
    mean.x += xValue;
    mean.y += yValue;
  }
  originalData.print(10,2);
  
  mean.x /= originalData.getRowDimension();
  mean.y /= originalData.getRowDimension();
  
  pca = new PCA(originalData);
  eigenVectors = pca.getEigenvectorsMatrix();
 
 println("num eigen vectors: " + eigenVectors.getColumnDimension());
 
 for(int i = 0; i < eigenVectors.getColumnDimension(); i++) {
   println("eigenvalue for eigenVector " + i + ": " + pca.getEigenvalue(i) );   
 }
 
 eigenVectors.print(10,2);
 axis1 = new PVector();
 axis2 = new PVector();
  axis1.x = (float)eigenVectors.get(0,0);
  axis1.y = (float)eigenVectors.get(1,0);

  axis2.x = (float)eigenVectors.get(0,1);
  axis2.y = (float)eigenVectors.get(1,1);  
  
  

  axis1.mult((float)pca.getEigenvalue(0));
  axis2.mult((float)pca.getEigenvalue(1));
 
 
 rotated = pca.transform(originalData, PCA.TransformationType.ROTATION);
 

}

void draw(){
  background(255);
  fill(0);
  translate(0, height);
  scale(1,-1);
  
  stroke(125);
  line(-500,0, 500, 0);
  line(0, -500, 0, 500);
  
  noStroke();
  draw(originalData);
  
  translate(mean.x, mean.y);
  
  stroke(0,255,0);
  line(0,0, axis1.x, axis1.y);
  stroke(255,0,0);
  line(0,0, axis2.x, axis2.y);
  
  float a = PVector.angleBetween(axis1, new PVector(1,0));
  fill(125);
  noStroke();
  rotate(a);
  rect(0,0, 20, 20);
  
  stroke(0,255,0);
  scale(1,-1);
 // text("Magnitude of PCA1: " + nf(pca.getEigenvalue(0),2), 0,0);

}

void draw(Matrix m){
  double[][] a = m.getArray();
  for(int i = 0; i < m.getRowDimension(); i++){
    ellipse((float)a[i][0], (float)a[i][1], 3, 3);
  }
}
