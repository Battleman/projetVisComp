class HUDScore extends HUDAsset {
  int chartW, chartH, zoneW, zoneH, border, padding, textPadding, textSize;
  String totalTitle, totalValue, velTitle, velValue, lastTitle, lastValue;
  int borderColor, backColor, textColor;
  PGraphics back, text;
  PFont font;
  Mover mover;
  
  HUDScore(int chartW, int chartH, Mover mover, int border, int padding, int textPadding, int borderColor, int backColor, int textColor) {
    this.chartW = chartW;
    this.chartH = chartH;
    this.mover = mover;
    this.border = border;
    this.padding = padding;
    this.textPadding = textPadding;
    this.borderColor = borderColor;
    this.backColor = backColor;
    this.textColor = textColor;
    
    zoneW = chartW - 2 * border;
    zoneH = chartH - 2 * border;
    
    back = createGraphics(chartW, chartH, P2D);
    text = createGraphics(zoneW, zoneH, P2D);
    
    back.beginDraw();
    back.background(borderColor);
    back.fill(backColor);
    back.noStroke();
    back.rect(border, border, zoneW, zoneH);
    back.noFill();
    back.endDraw();
    
    text.beginDraw();
    text.fill(textColor);
    text.endDraw();
    
    totalTitle = "Total Score :";
    velTitle = "Velocity :";
    lastTitle = "Last Score :";
  }
  
  void dessine(float x, float y) {
    int space = textSize + textPadding;
    int position = space;
    textSize = (zoneH - 4 * padding - 6 * textPadding) / 6;
    font = createFont("Courier", textSize, true);
    text.textFont(font);
    
    totalValue = correctScore(text, mover.getScore(), chartW - 2 * padding);
    velValue = correctScore(text, mover.getVelocity(), chartW - 2 * padding);
    lastValue = correctScore(text, mover.getLastScore(), chartW - 2 * padding);
    
    text.beginDraw();
    text.clear();
    text.text(totalTitle, textPadding, position);
    position += space;
    text.text(totalValue, textPadding, position);
    position += space + padding;
    text.text(velTitle, textPadding, position);
    position += space;
    text.text(velValue, textPadding, position);
    position += space + padding;
    text.text(lastTitle, textPadding, position);
    position += space;
    text.text(lastValue, textPadding, position);
    text.endDraw();
    
    image(back, x, y);
    image(text, x + border, y + border);
  }
}