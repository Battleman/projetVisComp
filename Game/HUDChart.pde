class HUDChart extends HUDAsset {
  int chartW, chartH, padding, start, count, min, max, oldMin, oldMax, threshold, amount, split, barHeight, distance;
  int[] scores;
  double visible;
  Mover mover;
  PGraphics back, grid, data, text;
  HScrollbar bar;

  HUDChart(int chartW, int chartH, int barHeight, int distance, int padding, int amount, int threshold, Mover mover) {
    this.chartW = chartW;
    this.chartH = chartH - barHeight - distance;
    this.padding = padding;
    this.threshold = Math.max(10, Math.abs(threshold));
    this.mover = mover;
    this.scores = new int[amount];
    this.start = 0;
    this.count = 0;
    this.barHeight = barHeight;
    this.distance = distance;
    this.amount = amount;
    this.max = threshold;
    this.min = -threshold;
    this.visible = 0.55;
    
    back = createGraphics(chartW, this.chartH, P2D);
    grid = createGraphics(chartW, this.chartH, P2D);
    data = createGraphics(chartW, this.chartH, P2D);
    text = createGraphics(chartW, this.chartH, P2D);
    
    back.beginDraw();
    back.background(255);
    back.endDraw();
    
    bar = new HScrollbar(chartW, barHeight, 50, 1);
    
    //drawGrid();
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

  void dessine(float x, float y) {
    if (mover.hasHit() || bar.mouseOver || bar.locked) {
      if (mover.hasHit()) compute();
      
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
      
      //drawGrid();
      
      mover.resetHit();
    }
    
    image(back, x, y);
    image(grid, x, y);
    image(data, x, y);
    image(text, x, y);
    
    bar.dessine(x, y + chartH + distance);
  }
  
  int getPos(int score) {
    double factor = 0.95;
    
    return (int) (((max - score) * factor * chartH / (double) (max - min)) + chartH * (1 - factor) / 2);
  }
    
  void drawGrid() {
    int temp = 0;
    int space = (int) Math.pow(10, Math.floor(Math.log10(max - min)) - 1);
    
    grid.beginDraw();
    text.beginDraw();
    grid.clear();
    text.clear();
    for (int i = max / space; i >= min / space; i--) {
      temp = (max - i * space) * chartH / (max - min);
      grid.line(0, temp, chartW, temp);
      text.text(i * space, 10, temp);
    }
    grid.endDraw();
    text.endDraw();
  }
  
  void compute() {
    int temp = mover.getScore();
    
    if (temp > max) {
      max = temp;
    }
    else if (scores[firstVisibleIndex()] == max || scores[index()] == max) {
      max = threshold;
      int i = nextIndex(firstVisibleIndex());
      while (i != index()) {
        if (scores[i] > max) {
          max = scores[i];
        }
        i = nextIndex(i);
      }
    }
    
    if (temp < min) {
      min = temp;
    }
    else if (scores[firstVisibleIndex()] == min || scores[index()] == min) {
      min = -threshold;
      int i = nextIndex(firstVisibleIndex());
      while (i != index()) {
        if (scores[i] < min) {
          min = scores[i];
        }
        i = nextIndex(i);
      }
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