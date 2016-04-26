class HUD {
  int hudW;
  int hudH;
  float x, y;
  int r, g, b;
  PGraphics myHud;
  ArrayList<PGraphics> assets;
  ArrayList<Integer> assetsX;
  ArrayList<Integer> assetsY;
  
  HUD(int hudW, int hudH, float x, float y, int r, int g, int b) {
    this.hudW = hudW;
    this.hudH = hudH;
    this.x = x;
    this.y = y;
    this.r = r;
    this.g = g;
    this.b = b;
    
    myHud = createGraphics(hudW, hudH, P2D);
  }
  
  void dessine() {
    myHud.beginDraw();
    myHud.background(r, g, b);
    myHud.endDraw();
    image(myHud, x, y);
    
    for (int i = 0; i < assets.size(); i++) {
       image(assets.get(i), assetsX.get(i), assetsY.get(i));
    }
  }
  
  void addAsset(PGraphics asset, int assetX, int assetY) {
    assets.add(asset);
    assetsX.add(assetX);
    assetsY.add(assetY);
  }
}