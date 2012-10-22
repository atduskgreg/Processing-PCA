import processing.opengl.*;
import SimpleOpenNI.*;
import Jama.Matrix;
import pca_transform.*;

SimpleOpenNI kinect;

boolean headFound = false;
int boxSize = 250;
PVector head;
ArrayList<PVector> headPoints;

PCA pca;

void setup() {
  size(1024, 768, OPENGL);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
}

void draw() {
  background(0);

  kinect.update();

  // prepare to draw centered in x-y
  // pull it 500 pixels closer on z
  translate(width/2, height/2, 500);
  rotateX(radians(180)); // flip y-axis from "realWorld"

  // make a vector of ints to store the list of users
  IntVector userList = new IntVector();
  // write the list of detected users
  // into our vector
  kinect.getUsers(userList);

  // if we found any users
  if (userList.size() > 0) {
    // get the first user
    int userId = userList.get(0);

    // if we're successfully calibrated
    if ( kinect.isTrackingSkeleton(userId)) {
      // make a vector to store the left hand
      head = new PVector();
      // put the position of the left hand into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, head);
      headFound = true;

      // Draw a box around the head joint
      // we'll look for depth points insde this box
      pushMatrix();
      pushStyle();
      stroke(255, 0, 0);
      noFill();
      rectMode(CENTER);
      translate(head.x, head.y, head.z);
      box(boxSize);
      popStyle();
      popMatrix();

      // draw a large point at the head joint
      pushStyle();
      stroke(255, 0, 0);      
      strokeWeight(30);
      point(head.x, head.y, head.z);
      popStyle();
    }
  }
  headPoints = new ArrayList<PVector>();

  // get the depth data as 3D points
  // loop through the points and save the ones
  // inside the box around our head joint
  // into an ArrayList, headPoints
  // while we're at it, draw all the depth points in the scene
  PVector[] depthPoints = kinect.depthMapRealWorld();
  for (int i = 0; i < depthPoints.length; i+=5) {
    PVector currentPoint = depthPoints[i];
    stroke(255);
    point(currentPoint.x, currentPoint.y, currentPoint.z);

    if (headFound) { // don't look for head points unless we've calibrated
      // draw the head points in red
      // to distinguish them from the rest of the scene
      pushStyle();
      stroke(255, 0, 0);
      strokeWeight(5);

      if (currentPoint.x > head.x - boxSize/2 && currentPoint.x < head.x + boxSize/2) {
        if (currentPoint.y > head.y - boxSize/2 && currentPoint.y < head.y + boxSize/2) {
          if (currentPoint.z > head.z - boxSize/2 && currentPoint.z < head.z + boxSize/2) {
            headPoints.add(currentPoint);
            point(currentPoint.x, currentPoint.y, currentPoint.z);
          }
        }
      }
      popStyle();
    }
  }

  if (headFound) {
    // turn the head points into a matrix 
    // so we can do PCA on it
    Matrix m = toMatrix(headPoints);

    if (m.getRowDimension() > 0) {
      pca = new PCA(m);
      // the eigenvectors from PCA will be the 
      // main axes of the head points
      Matrix eigenVectors = pca.getEigenvectorsMatrix();

      PVector axis1 = new PVector();
      PVector axis2 = new PVector();
      PVector axis3 = new PVector();
      if (eigenVectors.getColumnDimension() > 2) {
        // populate the head axes with each eigenvector
        axis1.x = (float)eigenVectors.get(0, 0);
        axis1.y = (float)eigenVectors.get(1, 0);

        axis2.x = (float)eigenVectors.get(0, 1);
        axis2.y = (float)eigenVectors.get(1, 1);

        axis3.x = (float)eigenVectors.get(0, 2);
        axis3.y = (float)eigenVectors.get(1, 2);  

        // scale them based on the eigenvalues
        axis1.mult((float)pca.getEigenvalue(0));
        axis2.mult((float)pca.getEigenvalue(1));
        axis3.mult((float)pca.getEigenvalue(2));

        // draw the head axes in RGB
        pushMatrix();
        pushStyle();
        strokeWeight(15);
        translate(head.x, head.y, head.z);
        stroke(0, 255, 0);
        line(0, 0, axis1.x, axis1.y);
        stroke(255, 0, 0);
        line(0, 0, axis2.x, axis2.y);
        stroke(0, 0, 255);
        line(0, 0, axis3.x, axis3.y);
        popStyle();
        popMatrix();
      }
    }
  }
}

// helper function for converting X-Y-Z
// points into a matrix
Matrix toMatrix(ArrayList<PVector> points) {
  Matrix result = new Matrix(points.size(), 3);

  for (int i = 0; i < points.size(); i++) {
    result.set(i, 0, points.get(i).x);
    result.set(i, 1, points.get(i).y);
    result.set(i, 2, points.get(i).z);
  }

  return result;
}

// user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.startPoseDetection("Psi", userId);
}

void onEndCalibration(int userId, boolean successful) {
  if (successful) { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  } 
  else { 
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
}

