float depth = 500;
float rx = 0;
float rz = 0;
float minAngle = -PI / 3;
float maxAngle = PI / 3;
float gameWidth = 300;
float gameHeight = 300;
float ballRadius = 10;
float boardFactor = 1;
ArrayList<PVector> vec = new ArrayList<PVector>();
float radius = 25;

Mover mover;
Cylinder cylinder;

void settings() {
  size(500, 500, P3D);
}

void setup () {
  noStroke();
  mover = new Mover(gameWidth, gameHeight, ballRadius);
  vec.add(new PVector(100, 100));
  //cylinder = new Cylinder(100, 100, 50, 50, 40);
  //cylinder.param();
}

void draw() {
  camera(width / 2, height / 2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(200);
  translate(width / 2, height / 2, 0);
  rotateZ(rz);
  rotateX(-rx);
  box(gameWidth, 6, gameHeight);

  for(int i = 0; i < vec.size(); i++) {
    cylinder = new Cylinder(vec.get(i).x, vec.get(i).y, radius, 50, 40);
    cylinder.param();
    cylinder.dessine();
  }
  mover.checkCylinderCollision(vec, radius);
  mover.dessine();
  //mover.checkCylinderCollision(vec, radius);
  sphere(ballRadius);
  
}

void mouseDragged() {
   int tempX = pmouseY - mouseY;
   int tempZ = pmouseX - mouseX;
   
   rx += addBit(tempX, 0.05 * boardFactor);
   rz += addBit(tempZ, 0.05 * boardFactor);
   
   rx = intervalTest(rx, minAngle, maxAngle);
   rz = intervalTest(rz, minAngle, maxAngle);
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  boardFactor = boardFactor * (float) Math.pow(1.05, -e);
}

void keyPressed() {
  if(key == CODED) {
    if(keyCode == SHIFT) {
      noLoop();
      camera(width / 2, height / 2, depth, 250, 250, 0, 0, 1, 0);
      background(200);
      rect(100, 100, gameWidth, gameHeight);
      float mX = map(mouseX, 100, gameWidth+100, -PI, PI);
      float mY = map(mouseY, 100, gameHeight+100, -PI, PI);
      if(mousePressed == true) {
        println("shit");
        vec.add(new PVector(mX, mY));
      }
    }
  }
}

void keyReleased(){
  loop();
}

float addBit(float test, float bit) {
  if (test < 0) return bit;
  if (test > 0) return -bit;
  return 0;
}

float intervalTest(float value, float min, float max) {
  float tmpMin = min;
  float tmpMax = max;
  
  if (min > max) {
    tmpMin = max;
    tmpMax = min;
  }
  
  if (value < tmpMin) return tmpMin;
  if (value > tmpMax) return tmpMax;
  return value;
}