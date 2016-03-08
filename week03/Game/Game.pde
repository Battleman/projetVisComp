float depth = 500;
float rx = 0;
float rz = 0;
float minAngle = -PI / 3;
float maxAngle = PI / 3;

void settings() {
  size(500, 500, P3D);
}

void setup () {
  noStroke();
}

void draw() {
  
  camera(width / 2, height / 2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(200);
  translate(width / 2, height / 2, 0);
  rotateZ(rz);
  rotateX(-rx);
  box(200, 10, 200);
}

void mouseDragged() {
   int tempX = pmouseY - mouseY;
   int tempZ = pmouseX - mouseX;
   
   rx += addBit(tempX, 0.01);
   rz += addBit(tempZ, 0.01);
   
   rx = intervalTest(rx, minAngle, maxAngle);
   rz = intervalTest(rz, minAngle, maxAngle);
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