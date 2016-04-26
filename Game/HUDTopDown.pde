class HUDTopDown {
  int plateW;
  int plateH;
  float tempX, tempY;
  float ballRadius;
  float cylRadius;
  float ratio;
  Mover mover;
  ArrayList<PVector> cylinders;
  PGraphics plate;
  PGraphics assets;
  
  HUDTopDown(int plateW, int plateH, float origW, float origH, float ballRadius, float cylRadius, Mover mover, ArrayList<PVector> cylinders) {
    this.plateW = plateW;
    this.plateH = plateH;
    this.ratio = origW / plateW;
    this.ballRadius = ballRadius * ratio;
    this.cylRadius = cylRadius + ratio;
    this.mover = mover;
    this.cylinders = cylinders;
    
    plate = createGraphics(plateW, plateH, P2D);
    assets = createGraphics(plateW, plateH, P2D);
    plate.beginDraw();
    plate.background(0);
    plate.endDraw();
  }
  
  void dessine() {
    tempX = mover.getPos().x * ratio;
    tempY = mover.getPos().y * ratio;
    plate.beginDraw();
    fill(100, 100, 100);
    plate.ellipse(tempX, tempY, 2 * ballRadius, 2 * ballRadius);
    plate.endDraw();
    
    assets.beginDraw();
    background(plate);
    fill(#ff0000);
    assets.ellipse(tempX, tempY, 2 * ballRadius, 2 * ballRadius);
    fill(#ffffff);
    
    for (int i = 0; i < cylinders.size(); i++) {
      tempX = cylinders.get(i).x * ratio;
      tempY = cylinders.get(i).y * ratio;
      assets.ellipse(tempX, tempY, cylRadius, cylRadius);
    }
    
    assets.endDraw();
  }
  
  PGraphics getContext() {
    return assets;
  }
}