class HUDChart extends HUDAsset {
  int scoreW, chartW, chartH, totalW, totalH, padding, start, count, min, max, threshold, amount, barHeight, distance;
  PGraphics back, grid, data, text;
  int backColor, sideColor, textColor;
  double visible, oldVisible;
  int[] scores;
  Mover mover;
  HScrollbar bar;

  HUDChart(int totalW, int totalH, int barHeight, int distance, int padding, int amount, int threshold, Mover mover, int backColor, int sideColor, int textColor) {
    this.totalW = totalW;
    this.totalH = totalH;
    this.padding = padding;
    this.threshold = Math.max(10, Math.abs(threshold));
    this.mover = mover;
    this.barHeight = barHeight;
    this.distance = distance;
    this.amount = amount;
    this.backColor = backColor;
    this.sideColor = sideColor;
    this.textColor = textColor;
    
    scoreW = 60;
    chartW = totalW - scoreW;
    chartH = totalH - barHeight - distance;
    scores = new int[amount];
    start = 0;
    count = 0;
    max = threshold;
    min = -threshold;
    visible = 0.55;
    oldVisible = visible;
    
    back = createGraphics(chartW, chartH, P2D);
    grid = createGraphics(chartW, chartH, P2D);
    data = createGraphics(chartW, chartH, P2D);
    text = createGraphics(scoreW, chartH, P2D);
    
    back.beginDraw();
    back.background(backColor);
    back.endDraw();
    
    text.beginDraw();
    text.fill(textColor);
    text.endDraw();
    
    bar = new HScrollbar(totalW, barHeight, 50, 1);
    
    drawGrid();
  }
  
  int index() {
    return (start + count) % amount;
  }
  
  int nextIndex(int i) {
    return (i + 1) % amount;
  }
  
  int firstVisibleIndex() {
    if (count < visible * amount) return start;
    else return ((int) (index() - visible * amount) % amount + amount) % amount;
  }
  
  boolean changedSize() {
    return oldVisible != visible;
  }

  void dessine(float x, float y) {
    if (mover.hasHit() || bar.mouseOver || bar.locked) {
      computeNoHit();
      if (mover.hasHit()) compute();
      
      oldVisible = visible;
      visible = .1 + .9 * bar.getPos();
      
      int temp = 0;
      int mid = 0;
      int edge = 0;
      double position = 0;
      double shift = (chartW - 3) / Math.floor(visible * amount);
    
      data.beginDraw();
      data.clear();
      mid = getPos(0);
      for (int i = 0; i < Math.min(count, Math.floor(visible * amount)); i++) {
        temp = scores[(firstVisibleIndex() + i) % amount];
        if (temp == 0) {
          data.fill(100);
        }
        else if (temp > 0) {
          data.fill(0, 200, 0);
        }
        else {
          data.fill(200, 0, 0);
        }
        edge = getPos(temp) - getPos(0);
        data.rect((int) position + padding, mid, (int) (position + shift) - (int) position - padding, edge);
        position += shift;
      }
      data.endDraw();
      
      drawGrid();
      
      mover.resetHit();
    }
    
    image(back, x + scoreW, y);
    image(grid, x + scoreW, y);
    image(data, x + scoreW, y);
    image(text, x, y);
    
    bar.dessine(x, y + chartH + distance);
  }
  
  int getPos(int score) {
    double factor = 0.95;
    
    return (int) (((max - score) * factor * chartH / (double) (max - min)) + chartH * (1 - factor) / 2);
  }
  
  int getClosest(int n) {
    double n5 = (int) Math.log10(n / 5d);
    double n10 = (int) Math.log10(n / 10d);
    double n25 = (int) Math.log10(n / 25d);
    
    n5 = 5 * Math.pow(10, n5);
    n10 = 10 * Math.pow(10, n10);
    n25 = 25 * Math.pow(10, n25);
    
    return (int) Math.max(n5, Math.max(n10, n25));
  }
    
  void drawGrid() {
    int temp = 0;
    int policeSize = 12;
    int scorePadding = 10;
    int minSize = (int) (policeSize * 2.5);
    double factor = 0.95;
    int n = (int) (factor * chartH / (double) minSize);
    int space = getClosest((max - min) / n);
    
    grid.beginDraw();
    grid.clear();
    grid.endDraw();
    
    text.beginDraw();
    text.clear();
    text.background(sideColor);
    text.textSize(policeSize);
    text.endDraw();
    
    for (int i = max / space; i >= min / space; i--) {
      temp = getPos(space * i);
      
      grid.beginDraw();
      grid.line(0, temp, chartW, temp);
      grid.endDraw();
      
      text.beginDraw();
      text.text(correctScore(text, i * space, scoreW - 2 * scorePadding), scorePadding, Math.max(policeSize + 3, Math.min(chartH - 3, temp + policeSize / 2)));
      text.endDraw();
    }
  }
  
  boolean full() {
    return count >= (visible * amount);
  }
  
  void computeNoHit() {
    if (full() && (changedSize() || scores[firstVisibleIndex()] == max || scores[index()] == max)) {
      max = threshold;
      int i = nextIndex(firstVisibleIndex());
      while (i != index()) {
        if (scores[i] > max) {
          max = scores[i];
        }
        i = nextIndex(i);
      }
    }
    
    if (full() && (changedSize() || scores[firstVisibleIndex()] == min || scores[index()] == min)) {
      min = -threshold;
      int i = nextIndex(firstVisibleIndex());
      while (i != index()) {
        if (scores[i] < min) {
          min = scores[i];
        }
        i = nextIndex(i);
      }
    }
  }
  
  void compute() {
    int temp = mover.getScore();
    
    if (temp > max) {
      max = temp;
    }
    
    if (temp < min) {
      min = temp;
    }
    
    scores[index()] = temp;
    if (count == amount) {
      start = (start + 1) % amount;
    }
    else {
      count++;
    }
  }
}