void settings() {
  size (400, 400, P2D);
}
void setup(){
}
void draw(){
  line(200, 200, 400, 400);
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
     this.x = x;
     this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  
  float[][] pFloat = pointToDouble(p);
  
  float[][] trans = {{1, 0, 0, -eye.x},
                   {0, 1, 0, -eye.y},
                   {0, 0, 1, -eye.z},
                   {0, 0, 0, 1}};
    
   
  float[][] proj = {{1, 0, 0, 0},
                   {0, 1, 0, 0},
                   {0, 0, 1, 0},
                   {0, 0, -1/eye.x, 0}};
                   
  return doubleTo2DPoint(multiplyMatrix(proj, multiplyMatrix(trans, pFloat)));
  
}

private float[][] pointToDouble(My3DPoint p) {
  float[][] temp = {{p.x}, {p.y}, {p.z}, {1}};
  return temp;
}

private My3DPoint doubleTo3DPoint(float[][] m) {
  if (m.length == 4 && m[0].length == 1) {
    return new My3DPoint(m[0][0], m[1][0], m[2][0]);
  }
  else throw new IllegalArgumentException();
}

private My2DPoint doubleTo2DPoint(float[][] m) {
  if (m.length == 4 && m[0].length == 1) {
    return new My2DPoint(m[0][0], m[1][0]);
  }
  else throw new IllegalArgumentException();
}
  
private float[][] multiplyMatrix(float[][] m1, float[][] m2) {
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