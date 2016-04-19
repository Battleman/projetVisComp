class Axes {
  float gameH;
  float gameW;
  int axeSize;
  int axeDist;
  
  Axes(float gameW, float gameH, int axeSize, int axeDist) {
    this.gameW = gameW;
    this.gameH = gameH;
    this.axeSize = axeSize;
    this.axeDist = axeDist;
  }
  
  void dessine() {
    translate(-axeDist - gameW / sqrt(2), 0, 0);
    fill(0, 0, 255);
    box(axeSize, axeSize, gameH);
    translate(0, axeDist + gameH / sqrt(2), -axeDist - gameH / sqrt(2));
    fill(0, 255, 0);
    box(axeSize, gameW, axeSize);
    translate(axeDist + gameW / sqrt(2), -axeDist - gameH / sqrt(2), 0);
    fill(255, 0, 0);
    box(gameW, axeSize, axeSize);
    translate(0, 0, axeDist + gameH / sqrt(2));
  }
}