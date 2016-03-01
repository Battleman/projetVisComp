void settings() {
  size (400, 400, P2D);
}
void setup() {
size(400, 400, P2D);
}
void draw() {
My3DPoint eye = new My3DPoint(-100, -100, -5000);
My3DPoint origin = new My3DPoint(0, 0, 0); //The first vertex of your cuboid
My3DBox input3DBox = new My3DBox(origin, 100,150,300);
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
         
  My2DPoint point = doubleTo2DPoint(multiplyMatrix(proj, multiplyMatrix(trans, pFloat)));
  return new My2DPoint(point.x * (eye.z - p.z)/eye.z,point.y * (eye.z - p.z)/eye.z); 
  
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
    this.p = new My3DPoint[]{ new My3DPoint(x,y+dimY,z+dimZ),
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