import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.SortedSet;
import java.util.StringTokenizer;
import java.util.TreeSet;

import Jama.EigenvalueDecomposition;
import Jama.Matrix;


class PrincipleComponent implements Comparable<PrincipleComponent> {
  double eigenValue;
  double[] eigenVector;

  PrincipleComponent(double eigenValue, double[] eigenVector) {
    this.eigenValue = eigenValue;
    this.eigenVector = eigenVector;
  }
  
  int compareTo(PrincipleComponent o) {
      int ret = 0;
      if (eigenValue > o.eigenValue) {
        ret = -1;
      } else if (eigenValue < o.eigenValue) {
        ret = 1;
      }
      return ret;
    }

    // FIXME: make eigenvectors print out nicer
    String toString() {
      return "Principle Component, eigenvalue: " + eigenValue + ", eigenvector: ["
          + eigenVector + "]";
    }
}


class PCA {
  Matrix covMatrix;
  EigenvalueDecomposition eigenstuff;
  double[] eigenvalues;
  Matrix eigenvectors;
  SortedSet<PrincipleComponent> principleComponents;
  double[] means;

  PCA(double[][] input) {
    means = new double[input[0].length];
    double[][] cov = getCovariance(input, means);
    covMatrix = new Matrix(cov);
    eigenstuff = covMatrix.eig();
    eigenvalues = eigenstuff.getRealEigenvalues();
    eigenvectors = eigenstuff.getV();
    double[][] vecs = eigenvectors.getArray();
    int numComponents = eigenvectors.getColumnDimension(); // same as num rows.
    principleComponents = new TreeSet<PrincipleComponent>();
    for (int i = 0; i < numComponents; i++) {
      double[] eigenvector = new double[numComponents];
      for (int j = 0; j < numComponents; j++) {
        eigenvector[j] = vecs[i][j];
      }
      principleComponents.add(new PrincipleComponent(eigenvalues[i], eigenvector));
    }
  }
  
  /**
   * Subtracts the mean value from each column. The means must be precomputed, which you get for
   * free when you make a PCA instance (just call getMeans()).
   * 
   * @param input
   *          Some data, where each row is a sample point, and each column is a dimension.
   * @param mean
   *          The means of each dimension. This could be computed from 'input' directly, but for
   *          efficiency's sake, it should only be done once and the result saved.
   * @return Returns a translated matrix where each cell has been translated by the mean value of
   *         its dimension.
   */
  double[][] getMeanAdjusted(double[][] input, double[] mean) {
    int nRows = input.length;
    int nCols = input[0].length;
    double[][] ret = new double[nRows][nCols];
    for (int row = 0; row < nRows; row++) {
      for (int col = 0; col < nCols; col++) {
        ret[row][col] = input[row][col] - mean[col];
      }
    }
    return ret;
  }
  
  /**
   * Returns the top n principle components in descending order of relevance.
   */
  List<PrincipleComponent> getDominantComponents(int n) {
    List<PrincipleComponent> ret = new ArrayList<PrincipleComponent>();
    int count = 0;
    for (PrincipleComponent pc : principleComponents) {
      ret.add(pc);
      count++;
      if (count >= n) {
        break;
      }
    }
    return ret;
  }


  Matrix getDominantComponentsMatrix(List<PrincipleComponent> dom) {
    int nRows = dom.get(0).eigenVector.length;
    int nCols = dom.size();
    Matrix matrix = new Matrix(nRows, nCols);
    for (int col = 0; col < nCols; col++) {
      for (int row = 0; row < nRows; row++) {
        matrix.set(row, col, dom.get(col).eigenVector[row]);
      }
    }
    return matrix;
  }
  
  int getNumComponents() {
    return eigenvalues.length;
  }

  double[][] getCovariance(double[][] input, double[] meanValues) {
    int numDataVectors = input.length;
    int n = input[0].length;

    double[] sum = new double[n];
    double[] mean = new double[n];
    for (int i = 0; i < numDataVectors; i++) {
      double[] vec = input[i];
      for (int j = 0; j < n; j++) {
        sum[j] = sum[j] + vec[j];
      }
    }
    for (int i = 0; i < sum.length; i++) {
      mean[i] = sum[i] / numDataVectors;
    }

    double[][] ret = new double[n][n];
    for (int i = 0; i < n; i++) {
      for (int j = i; j < n; j++) {
        double v = getCovariance(input, i, j, mean);
        ret[i][j] = v;
        ret[j][i] = v;
      }
    }
    if (meanValues != null) {
      System.arraycopy(mean, 0, meanValues, 0, mean.length);
    }
    return ret;
  }
  
  double getCovariance(double[][] matrix, int colA, int colB, double[] mean) {
    double sum = 0;
    for (int i = 0; i < matrix.length; i++) {
      double v1 = matrix[i][colA] - mean[colA];
      double v2 = matrix[i][colB] - mean[colB];
      sum = sum + (v1 * v2);
    }
    int n = matrix.length;
    double ret = (sum / (n - 1));
    return ret;
  }
  
  double[] getMeans() {
    return means;
  }
}

