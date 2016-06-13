//Board tilt properties
final float minAngle = -PI / 3;
final float maxAngle = PI / 3;

//Board properties
final float gameW = 300;
final float gameH = 300;
final float gameT = 6;
final int border = 2;

//Ball properties
final float ballRadius = 10;

//Cylinder properties
final float radius = 25;

//Window Properties
final int winW = 1200;
final int winH = 720;

//Game state variables
boolean placeMode = false;
boolean debugMode = false;
float rx = 0;
float rz = 0;
float boardFactor = 1;
List<PVector> vec = new ArrayList<PVector>();
PVector position;

//Debug axes properties
final int axeDist = 15;
final int axeSize = 10;

//Camera start position
int camX = 0;
int camY = -400;
int camZ = 500;

//Directional light direction
final int dLightR = 200; 
final int dLightG = 200;
final int dLightB = 200;

//Ambient light color
final int aLightR = 102;
final int aLightG = 102;
final int aLightB = 102;

//Height of HUD panel
final int hudH = winH / 5;

//Padding between HUD elements
final int hudPadding = 10;

//Height of HUD elements
final int hudElemH = hudH - 2 * hudPadding;

//Position of minimap
final int tdX = hudPadding;

//Width of minimap
final int tdW = hudElemH;

//Position of score table
final int scoreX = tdX + hudElemH + hudPadding;

//Width of score table
final int scoreW = 100;

//Position of score chart
final int chartX = scoreX + scoreW + hudPadding;

//Width of score chart
final int chartW = winW - chartX - hudPadding;

//Properties of the score table
final int scoreBorder = 2;
final int scorePadding = 5;
final int scoretextPadding = 2;

//Colors for the 3D assets
final int backgroundColor = #FFFFFF;
final int boardColor = #A0FF80;
final int ballColor = #F0F0F0;
final int cylColor = #804000;

//Colors for the 2D assets
final int hudColor = #C06000;

final int mapBackColor = #A0FF80;
final int mapBallColor = #F0F0F0;
final int mapTraceColor = #FFFFFF;
final int mapCylColor = #804000;

final int scoreBorderColor = #FFFFFF;
final int scoreBackColor = #000000;
final int scoreTextColor = #FFFFFF;

final int chartBackColor = #FFFFFF;
final int chartSideColor = #C0C0C0;
final int chartTextColor = #202020;

//Object declarations
Mover mover;
Cylinder cylinder;
Axes axes;
Plate plate;
HUD hud;
HUDTopDown hudTD;
HUDScore hudScore;
HUDChart hudChart;
Capture cam;
LineDetection lineDetec;

void settings() {
  size(winW, winH, P3D);
}

void setup () {
  noStroke();
  
  //Setup mover
  mover = new Mover(gameW, gameH, ballRadius, ballColor);
  
  //Setup debug axes
  axes = new Axes(gameW, gameH, axeSize, axeDist);
  
  //Setup plate
  plate = new Plate(gameW, gameH, gameT, 2 * ballRadius + gameT / 2, border, boardColor);
  
  //Setup hud panel
  hud = new HUD((int) winW, hudH, 0, winH - hudH, hudColor);
  
  //Setup top-down minimap
  hudTD = new HUDTopDown(tdW, hudElemH, gameW, gameH, ballRadius, radius, mover, vec, mapBackColor, mapBallColor, mapTraceColor, mapCylColor);
  hud.addAsset(hudTD, tdX, hudPadding);
  
  //Setup score table
  hudScore = new HUDScore(scoreW, hudElemH, mover, scoreBorder, scorePadding, scoretextPadding, scoreBorderColor, scoreBackColor, scoreTextColor);
  hud.addAsset(hudScore, scoreX, hudPadding);
  
  //Setup score chart
  hudChart = new HUDChart(chartW, hudElemH, 20, hudPadding, 2, 200, 20, mover, chartBackColor, chartSideColor, chartTextColor);
  hud.addAsset(hudChart, chartX, hudPadding);
  
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  }
  else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  lineDetec = new LineDetection();
}

void draw() {
  pushMatrix();
  perspective();
  camera(camX, camY, camZ, 0, 0, 0, 0, 1, 0);
  directionalLight(dLightR, dLightG, dLightB, 0, 1, 0);
  ambientLight(aLightR, aLightG, aLightB);
  background(255, 255, 255);
  axes.dessine();
  cam.read();
  if (cam.available() && lineDetec.drawLineDetec(cam.get(), position)) {
    rotateX(position.x);
    rotateZ(position.z);
  }
  rotateX(-rx);
  rotateZ(rz);
  plate.dessine();

  for (int i = 0; i < vec.size(); i++) {
    cylinder = new Cylinder(vec.get(i).x, vec.get(i).y, radius, 50, 40, cylColor);
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
  if (!placeMode && !hud.mouseOver()) {
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
    fill(boardColor);
    box(1, gameH, gameW);
    noFill();
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

String correctScore(PGraphics graph, int i, int maxWidth) {
  if (i == 0) {
    return "0";
  }
  else if (graph.textWidth("-" + Integer.toString((int) Math.abs(i))) > maxWidth) {
    int temp = (int) Math.log10(Math.abs(i));
    double power = i / Math.pow(10, temp);
    return Double.toString(power) + 'e' + Integer.toString(temp);
  }
  else return Integer.toString(i);
}

class CWComparator implements Comparator<PVector> {
  
  PVector center;
  
  public CWComparator(PVector center) {
    this.center = center;
  }
  
  @Override
  public int compare(PVector b, PVector d) {
    if (Math.atan2(b.y - center.y, b.x - center.x) < Math.atan2(d.y - center.y, d.x - center.x)) return -1;
    else return 1;
  }
}

public static List<PVector> sortCorners(List<PVector> quad) {
    
  // Sort corners so that they are ordered clockwise
  PVector a = quad.get(0);
  PVector b = quad.get(2);
  PVector center = new PVector((a.x + b.x) / 2, (a.y + b.y) / 2);
  
  Collections.sort(quad, new Game().new  CWComparator(center));
  
  // Re-order the corners so that the first one is the closest to the
  // origin (0,0) of the image.
  //
  // You can use Collections.rotate to shift the corners inside the quad.
  
  return quad;
}