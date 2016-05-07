class HScrollbar extends HUDAsset {
  float barWidth;  //Bar's width in pixels
  float barHeight; //Bar's height in pixels
  
  float sliderPosition, newSliderPosition;    //Position of slider
  float sliderPositionMin, sliderPositionMax; //Max and min values of slider
  float sliderW;
  float sliderH;
  float padding;
  
  boolean mouseOver;  //Is the mouse over the slider?
  boolean locked;     //Is the mouse clicking and dragging the slider now?
  
  PGraphics bar;

  /**
   * @brief Creates a new horizontal scrollbar
   * 
   * @param w The width of the bar in pixels
   * @param h The height of the bar in pixels
   */
  HScrollbar(float barWidth, float barHeight, float sliderW, float padding) {
    this.barWidth = barWidth;
    this.barHeight = barHeight;
    this.sliderW = sliderW;
    this.sliderH = barHeight - 2 * padding;
    this.padding = padding;
    
    bar = createGraphics((int) barWidth, (int) barHeight, P2D);
    bar.beginDraw();
    bar.noStroke();
    bar.endDraw();
    
    sliderPosition = barWidth / 2;
    newSliderPosition = sliderPosition;
    
    sliderPositionMin = padding + sliderW / 2;
    sliderPositionMax = barWidth - sliderPositionMin;
  }

  /**
   * @brief Updates the state of the scrollbar according to the mouse movement
   */
  void update(float x, float y) {
    if (isMouseOver(x, y)) {
      mouseOver = true;
    }
    else {
      mouseOver = false;
    }
    if (mousePressed && mouseOver) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newSliderPosition = constrain(mouseX - x, sliderPositionMin, sliderPositionMax);
    }
  }

  /**
   * @brief Clamps the value into the interval
   * 
   * @param val The value to be clamped
   * @param minVal Smallest value possible
   * @param maxVal Largest value possible
   * 
   * @return val clamped into the interval [minVal, maxVal]
   */
  float constrain(float val, float minVal, float maxVal) {
    return min(max(val, minVal), maxVal);
  }

  /**
   * @brief Gets whether the mouse is hovering the scrollbar
   *
   * @return Whether the mouse is hovering the scrollbar
   */
  boolean isMouseOver(float x, float y) {
    if (mouseX > x && mouseX < x + barWidth &&
      mouseY > y && mouseY < y + barHeight) {
      return true;
    }
    else {
      return false;
    }
  }

  /**
   * @brief Draws the scrollbar in its current state
   */ 
  void dessine(float x, float y) {
    update(x, y);
    bar.fill(204);
    bar.rect(0, 0, barWidth, barHeight);
    if (mouseOver) {
      bar.fill(0, 0, 0);
    }
    else {
      bar.fill(102, 102, 102);
    }
    bar.rect(sliderPosition - sliderW, padding, sliderW, sliderH);
  }

  /**
   * @brief Gets the slider position
   * 
   * @return The slider position in the interval [0,1] corresponding to [leftmost position, rightmost position]
   */
  float getPos() {
    return sliderPosition / (sliderPositionMax - sliderPositionMin);
  }
}