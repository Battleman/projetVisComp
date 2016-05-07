class HUDChart extends HUDAsset {
  int chartW, chartH, padding, start, count, min, max, oldMin, oldMax, threshold, amount, barHeight, distance;
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
    
    back = createGraphics(chartW, chartH, P2D);
    grid = createGraphics(chartW, chartH, P2D);
    data = createGraphics(chartW, chartH, P2D);
    text = createGraphics(chartW, chartH, P2D);
    
    back.beginDraw();
    back.background(255);
    back.endDraw();
    
    bar = new HScrollbar(chartW, barHeight, 50, 1);
  }
  
  int index() {
    return (start + count) % amount;
  }

  void dessine(float x, float y) {
    compute();
    int temp = 0, mid = 0, edge = 0, position = 0, shift = (int) (chartW / (visible * amount));
    int space = (int) Math.pow(10, Math.floor(Math.log10(max - min)) - 1);
    
    data.beginDraw();
    data.clear();
    mid = chartH * max / (max - min);
    for (int i = 0; i < (int) (visible * amount); i++) {
      temp = scores[(index() + i) % amount];
      if (temp == 0) {
        data.fill(100);
      }
      else if (temp > 0) {
        data.fill(green(200));
      }
      else {
        data.fill(red(200));
      }
      edge = chartH * (max - temp) / (max - min);
      data.rect(position + padding, mid, position + shift - padding, edge);
      position += shift;
    }
    data.endDraw();
    
    grid.beginDraw();
    text.beginDraw();
    for (int i = max / space; i >= min / space; i--) {
      temp = (max - i * space) * chartH / (max - min);
      grid.line(0, temp, chartW, temp);
      text.text(i * space, 10, temp);
    }
    grid.endDraw();
    text.endDraw();
    
    image(back, x, y);
    image(grid, x, y);
    image(data, x, y);
    image(text, x, y);
  }
  
  void compute() {
    int temp = mover.getScore();
    
    if (temp > max) {
      max = temp;
    }
    else if (scores[index()] == max) {
      max = threshold;
      for (int i = 0; i < count; i++) {
        if (scores[i] > max) {
          max = scores[i];
        }
      }
    }
    
    if (temp < min) {
      min = temp;
    }
    else if (scores[index()] == min) {
      min = -threshold;
      for (int i = 0; i < count; i++) {
        if (scores[i] < min) {
          min = scores[i];
        }
      }
    }
    
    scores[index()] = temp;
    if (count == amount) {
      start = (start + 1) % amount;
    }
    else {
      count++;
    }
    
    visible = .1 + .9 * bar.getPos();
  }
}