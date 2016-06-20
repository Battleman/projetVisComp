class Plate {
  float gameH, gameW, gameT, borderH, borderT;
  int boardColor;
  
  Plate(float gameW, float gameH, float gameT, float borderH, float borderT, int boardColor) {
    this.gameW = gameW;
    this.gameH = gameH;
    this.gameT = gameT;
    this.borderH = borderH;
    this.borderT = borderT;
    this.boardColor = boardColor;
  }
  
  void dessine() {
    fill(boardColor);
    translate(-(gameW + border) / 2, 0, 0);
    box(borderT, borderH, gameH);
    translate(gameW + border, 0, 0);
    box(borderT, borderH, gameH);
    translate(-(gameW + border) / 2, 0, (gameH + border) / 2);
    box(gameW, borderH, borderT);
    translate(0, 0, -gameH - border);
    box(gameW, borderH, borderT);
    translate(0, 0, (gameH + border) / 2);
    box(gameW, gameT, gameH);
    noFill();
  }
}