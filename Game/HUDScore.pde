class HUDScore extends HUDAsset {
  int chartW, chartH;
  Mover mover;
  int score, lastScore;
  PGraphics back, text;
  String totalTitle, totalValue, velTitle, velValue, lastTitle, lastValue, finalText;
  PFont f;
  
  HUDScore(int chartW, int chartH, Mover mover) {
    this.chartW = chartW;
    this.chartH = chartH;
    this.mover = mover;
    
    back = createGraphics(chartW, chartH, P2D);
    
    back.beginDraw();
    back.background(0);
    back.noFill();
    back.stroke(255);
    back.strokeWeight(3);
    back.rect(1, 1, chartW - 2, chartH - 1);
    back.endDraw();
    
    totalTitle = "Total Score :\n";
    velTitle = "Velocity :\n";
    lastTitle = "Last Score :\n";
  }
  
  void dessine(float x, float y) {
    image(back, x, y);
    totalValue = Integer.toString(mover.getScore());
    velValue = Integer.toString(mover.getVelocity());
    lastValue = Integer.toString(mover.getLastScore());
    finalText = totalTitle + totalValue + "\n\n"
                + velTitle + velValue + "\n\n"
                + lastTitle + lastValue;
    f = createFont("Courier", 16, true);
    text(finalText, x + 10, y + 20);
  }
}