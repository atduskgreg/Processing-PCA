// get this from here: http://www.gicentre.org/utils/index.php
import org.gicentre.utils.stat.*; 
XYChart lineChart;

void setup() {

  size(500,500);
  
  double[][] matrix = new double[][] {
    {
      2.5, 2.4
    }
    , {
      0.5, 0.7
    }
    , {
      2.2, 2.9
    }
    , {
      1.9, 2.2
    }
    , {
      3.1, 3.0
    }
    , {
      2.3, 2.7
    }
    , {
      2, 1.6
    }
    , {
      1, 1.1
    }
    , {
      1.5, 1.6
    }
    , {
      1.1, 0.9
    }
  };

  lineChart = new XYChart(this);
  Matrix originalData = new Matrix(matrix);


  double[] all = originalData.getColumnPackedCopy();
  double[] column1 = Arrays.copyOfRange(all,0,9);
  double[] column2 = Arrays.copyOfRange(all,10,19);


  lineChart.setData(dToF(column1), dToF(column2));
  lineChart.showXAxis(true); 
  lineChart.showYAxis(true); 
  lineChart.setMinY(0);
  lineChart.setPointColour(color(180,50,50));
  lineChart.setPointSize(5);

  originalData.print(8, 4);
  PCA pca = new PCA(matrix);
  int numComponents = pca.getNumComponents();
  println("There are " + numComponents + " components.");

  int k = 2;
  List<PrincipleComponent> mainComponents = pca.getDominantComponents(k);
  int counter = 1;
  println("Showing top " + k + " principle components.");
  for (PrincipleComponent pc : mainComponents) {
    println("Component " + (counter++) + ": " + pc);
  }

  Matrix features = pca.getDominantComponentsMatrix(mainComponents);
  println("Feature matrix (k=" + k + ") :");
  features.print(8, 2);

  Matrix featuresXpose = features.transpose();
  println("Transposed feature matrix (k=" + k + ") :");
  featuresXpose.print(8, 4);

  double[][] matrixAdjusted = pca.getMeanAdjusted(matrix, pca.getMeans());
  Matrix adjustedInput = new Matrix(matrixAdjusted);
  println("Original input adjusted by dimension means (k=" + k + ") :");
  adjustedInput.print(8, 4);
  Matrix xformedData = featuresXpose.times(adjustedInput.transpose());
  println("Transformed data into PCA-space (k=" + k + ") :");
  xformedData.transpose().print(8, 4);

  k = 1;
  mainComponents = pca.getDominantComponents(k);
  counter = 1;
  println("Showing top " + k + " principle components.");
  for (PrincipleComponent pc : mainComponents) {
    println("Component " + (counter++) + ": " + pc);
  }

  features = pca.getDominantComponentsMatrix(mainComponents);
  println("Feature matrix (k=" + k + ") :");
  features.print(8, 4);

  featuresXpose = features.transpose();
  println("Xposed feature matrix (k=" + k + ") :");
  featuresXpose.print(8, 4);

  matrixAdjusted = pca.getMeanAdjusted(matrix, pca.getMeans());
  adjustedInput = new Matrix(matrixAdjusted);
  println("Original input adjusted by dimension means (k=" + k + ") :");
  adjustedInput.print(8, 4);
  xformedData = featuresXpose.times(adjustedInput.transpose());
  println("Transformed data into PCA-space (k=" + k + ") :");
  xformedData.transpose().print(8, 4);

  noLoop();
}

void draw() {
  background(255);
  lineChart.draw(15, 15, width-30, height-30);
}

float[] dToF(double[] doubleArray) {
  float[] floatArray = new float[doubleArray.length];
  for (int i = 0 ; i < doubleArray.length; i++)
  {
    floatArray[i] = (float) doubleArray[i];
  }
  return floatArray;
  
}

