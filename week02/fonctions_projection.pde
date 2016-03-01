
/**
*Some helper methods
*/

//Change a 3D point to it's homogenous equivalent (4D) 
private float[][] pointToDouble(My3DPoint p) {
  float[][] temp = {{p.x}, {p.y}, {p.z}, {1}};
  return temp;
}

/*Not useful for now
private My3DPoint doubleTo3DPoint(float[][] m) {
  if (m.length == 4 && m[0].length == 1) {
    return new My3DPoint(m[0][0], m[1][0], m[2][0]);
  } else throw new IllegalArgumentException();
}*/

//
private My2DPoint doubleTo2DPoint(float[][] m) {
  if (m.length == 4 && m[0].length == 1) {
    return new My2DPoint(m[0][0], m[1][0]);
  } else throw new IllegalArgumentException();
}

private float[][] produitMatrices(float[][] m1, float[][] m2) {
  float[][] m = new float[m1.length][m2[0].length];

  if (m1[0].length == m2.length) {
    for (int i = 0; i < m1.length; i++) {
      for (int j = 0; j < m2[0].length; j++) {
        m[i][j] = 0;
        for (int k = 0; k < m1[0].length; k++) {
          m[i][j] += m1[i][k] * m2[k][j];
        }
      }
    }
  }

  return m;
}  