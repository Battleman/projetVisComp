class HUDTopDown extends HUDAsset {
  int plateW;
  int plateH;
  float tempX, tempY;
  float ballRadius;
  float cylRadius;
  float ratio;
  Mover mover;
  ArrayList<PVector> cylinders;
  PGraphics obstacles;
  PGraphics ball;
  PGraphics trace;
  PGraphics back;
  
  HUDTopDown(int plateW, int plateH, float origW, float origH, float ballRadius, float cylRadius, Mover mover, ArrayList<PVector> cylinders) {
    this.plateW = plateW;
    this.plateH = plateH;
    this.ratio = plateW / origW;
    this.ballRadius = ballRadius * ratio;
    this.cylRadius = cylRadius * ratio;
    this.mover = mover;
    this.cylinders = cylinders;
    
    obstacles = createGraphics(plateW, plateH, P2D);
    ball = createGraphics(plateW, plateH, P2D);
    trace = createGraphics(plateW, plateH, P2D);
    back = createGraphics(plateW, plateH, P2D);
    
    trace.beginDraw();
    trace.fill(255, 0, 0);
    trace.noStroke();
    trace.endDraw();
    
    ball.beginDraw();
    ball.fill(255, 255, 255);
    ball.endDraw();
    
    //Set background color
    back.beginDraw();
    back.background(0);
    back.endDraw();
  }
  
  void dessine(float x, float y) {
    tempX = plateW / 2 + mover.getPos().x * ratio;
    tempY = plateH / 2 + mover.getPos().y * ratio;
    
    trace.beginDraw();
    trace.ellipse(tempX, tempY, 2 * ballRadius, 2 * ballRadius);
    trace.endDraw();
    
    ball.beginDraw();
    ball.clear();
    ball.ellipse(tempX, tempY, 2 * ballRadius, 2 * ballRadius);
    ball.endDraw();
    
    obstacles.beginDraw();
    obstacles.fill(#ffff00);
    for (int i = 0; i < cylinders.size(); i++) {
      tempX = plateW / 2 + cylinders.get(i).x * ratio;
      tempY = plateH / 2 + cylinders.get(i).y * ratio;
      obstacles.ellipse(tempX, tempY, 2 * cylRadius, 2 * cylRadius);
    }
    obstacles.endDraw();
    
    image(back, x, y);
    image(trace, x, y);
    image(ball, x, y);
    image(obstacles, x, y);
  }
}