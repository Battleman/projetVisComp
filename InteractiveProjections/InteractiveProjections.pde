float scaleFactor = 1;
float rotX = 0;
float rotY = 0;


void settings() {
  size(1000, 1000, P3D);
}

void setup () {}

void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);

  float[][] transformMouse = scaleMatrix(scaleFactor, scaleFactor, scaleFactor);
  float[][] transformArrowX = rotateXMatrix(rotX);
  float[][] transformArrowY = rotateYMatrix(rotY);
  
  //rotated around x
  float[][] transform1 = rotateXMatrix(PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  input3DBox = transformBox(input3DBox, transformMouse);
  input3DBox = transformBox(input3DBox, transformArrowX);
  input3DBox = transformBox(input3DBox, transformArrowY);
  projectBox(eye, input3DBox).render();

  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  input3DBox = transformBox(input3DBox, transformMouse);
  input3DBox = transformBox(input3DBox, transformArrowX);
  input3DBox = transformBox(input3DBox, transformArrowY);
  projectBox(eye, input3DBox).render();

  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  input3DBox = transformBox(input3DBox, transformMouse);
  input3DBox = transformBox(input3DBox, transformArrowX);
  input3DBox = transformBox(input3DBox, transformArrowY);
  projectBox(eye, input3DBox).render();
  
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
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float [] pTP = {(p.x-eye.x)*(-eye.z)/(p.z-eye.z),
                  (p.y-eye.y)*(-eye.z)/(p.z-eye.z), 
                  (p.z-eye.z)*(-eye.z)/(p.z-eye.z), 
                   1};
  return new My2DPoint(pTP[0], pTP[1]);                
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render(){
    // Complete the code! use only line(x1, y1, x2, y2) built-in function.
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[2].x, s[2].y, s[1].x, s[1].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[4].x, s[4].y, s[7].x, s[7].y);
    line(s[4].x, s[4].y, s[5].x, s[5].y);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    line(s[7].x, s[7].y, s[6].x, s[6].y);
    line(s[5].x, s[5].y, s[1].x, s[1].y);
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x,y+dimY,z+dimZ),
                             new My3DPoint(x,y,z+dimZ),
                             new My3DPoint(x+dimX,y,z+dimZ),
                             new My3DPoint(x+dimX,y+dimY,z+dimZ),
                             new My3DPoint(x,y+dimY,z),
                             origin,
                             new My3DPoint(x+dimX,y,z),
                             new My3DPoint(x+dimX,y+dimY,z)
                            };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] pointsCollec = new My2DPoint[box.p.length];  
  for(int i = 0; i < box.p.length; i++) {
     pointsCollec[i] = projectPoint(eye, box.p[i]);   
  }
  
  return new My2DBox(pointsCollec);
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z , 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0 , 0 , 0},
                        {0, cos(angle), sin(angle) , 0},
                        {0, -sin(angle), cos(angle) , 0},
                        {0, 0 , 0 , 1}});
}
float[][] rotateYMatrix(float angle) {
  // Complete the code!
  return(new float[][] {{cos(angle), 0 , -sin(angle) , 0},
                        {0, 1, 0 , 0},
                        {sin(angle), 0, cos(angle), 0},
                        {0, 0 , 0 , 1}});
}
float[][] rotateZMatrix(float angle) {
  // Complete the code!
  return(new float[][] {{cos(angle), sin(angle), 0, 0},
                        {-sin(angle), cos(angle), 0, 0},
                        {0, 0, 1, 0},
                        {0, 0 , 0 , 1}});
}
float[][] scaleMatrix(float x, float y, float z) {
  // Complete the code!
  float[][] result = {{x, 0, 0, 0}, {0, y, 0, 0}, {0, 0, z, 0}, {0, 0, 0, 1}};
  return result;
}
float[][] translationMatrix(float x, float y, float z) {
  // Complete the code!
  float[][] result = {{1, 0, 0, x}, {0, 1, 0, y}, {0, 0, 1, z}, {0, 0, 0, 1}};
  return result;
}

float[] matrixProduct(float[][] a, float[] b) {
  //Complete the code!
  float[] m = new float[a.length];
  for(int i = 0; i < a.length; i++) {
    for(int j = 0; j < b.length; j++) {
      m[i] += a[i][j]*b[j];
    }
  }
  return m;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  //Complete the code! You need to use the euclidian3DPoint() function given below.
  My3DPoint[] pts = new My3DPoint[box.p.length];
  for(int i = 0; i < box.p.length; i++) {
    pts[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(pts);
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

void mouseDragged() {
  int temp = mouseY - pmouseY;
  if (temp < 0) {
    scaleFactor *= 0.9;
  }
  else if (temp > 0) {
    scaleFactor *= 1.1;
  }
}

void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case UP :
        rotX += 0.1;
      break;
      case DOWN :
        rotX -= 0.1;
      break;
      case LEFT :
        rotY += 0.1;
      break;
      case RIGHT :
        rotY -= 0.1;
      break;
      default :
    }
  }
}