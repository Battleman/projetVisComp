float depth = 500;
float rx = 0;
float rz = 0;
float minAngle = -PI / 3;
float maxAngle = PI / 3;
float gameW = 300;
float gameH = 300;
float gameT = 6;
float ballRadius = 10;
float boardFactor = 1;
ArrayList<PVector> vec = new ArrayList<PVector>();
float radius = 25;
int winW = 1200;
int winH = 720;
boolean placeMode = false;
boolean debugMode = true;
int axeDist = 15;
int axeSize = 10;
int border = 2;
int camX = 0;
int camY = -400;
int camZ = 500;
int hudH = 150;
int hudR = 255;
int hudG = 114;
int hudB = 0;


Mover mover;
Cylinder cylinder;
Axes axes;
Plate plate;
HUD hud;
HUDTopDown hudTD;

void settings() {
  size(winW, winH, P3D);
}

void setup () {
  noStroke();
  mover = new Mover(gameW, gameH, ballRadius);
  axes = new Axes(gameW, gameH, axeSize, axeDist);
  plate = new Plate(gameW, gameH, gameT, 2 * ballRadius + gameT / 2, border);
  hud = new HUD((int) winW, hudH, 0, winH - hudH, hudR, hudG, hudB);
  hudTD = new HUDTopDown(hudH - 20, hudH - 20, gameW, gameH, ballRadius, radius, mover, vec);
  hud.addAsset(hudTD.getContext(), 10, 10);
}

void draw() {
  pushMatrix();
  perspective();
  camera(camX, camY, camZ, 0, 0, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(200);
  axes.dessine();
  rotateZ(rz);
  rotateX(-rx);
  plate.dessine();
  
  if (keyCode != 0) println(keyCode);

  for (int i = 0; i < vec.size(); i++) {
    cylinder = new Cylinder(vec.get(i).x, vec.get(i).y, radius, 50, 40);
    cylinder.param();
    cylinder.dessine();
  }
  
  mover.checkCylinderCollision(vec, radius);
  mover.dessine();
  
  placeMode();
  popMatrix();
  
  hud.dessine();
}

void mouseDragged() {
  if (!placeMode) {
    int tempX = pmouseY - mouseY;
    int tempZ = pmouseX - mouseX;
   
    rx += addBit(tempX, 0.05 * boardFactor);
    rz += addBit(tempZ, 0.05 * boardFactor);
   
    rx = intervalTest(rx, minAngle, maxAngle);
    rz = intervalTest(rz, minAngle, maxAngle);
  }
}

void mouseWheel(MouseEvent event) {
  if (!placeMode) {
    float e = event.getCount();
    boardFactor = boardFactor * (float) Math.pow(1.05, -e);
  }
}

void keyPressed() {
  if (key == CODED && keyCode == SHIFT) {
    placeMode = true;
  }
  
  if (debugMode && key == CODED) {
    switch (keyCode) {
      case 17: camY+=100;
        println("Up" + camY);
      break;
      case 18: camY-=100;
      println("Down" + camY);
      break;
      case 37: camX-=100;
      println("Left" + camX);
      break;
      case 38: camZ-=100;
      println("Front" + camZ);
      break;
      case 39: camX+=100;
      println("Right" + camX);
      break;
      case 40: camZ+=100;
      println("Back" + camZ);
      break;
      default:
    }
  }
}

void keyReleased() {
  if (key == CODED && keyCode == SHIFT) {
    placeMode = false;
    loop(); 
  }
}

void mouseClicked() {
  if (placeMode) {
    float mX = map(mouseX, 0, winW, (gameW - winW) / 2, (gameW + winW) / 2);
    float mY = map(mouseY, 0, winH, (gameH - winH) / 2, (gameH + winH) / 2);
    if (mX >= radius && mX <= gameW - radius && mY >= radius && mY <= gameH - radius) {
      println(mX + ", " + mY);
      vec.add(new PVector(mX - gameW / 2, mY - gameH / 2));
    }
  }
}

void placeMode() {
  if (placeMode) {
    noLoop();
    camera(0, 0, 0, 1, 0, 0, 0, 1, 0);
    ortho();
    background(200);
    translate(1, 0, 0);
    box(1, gameH, gameW);
  }
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