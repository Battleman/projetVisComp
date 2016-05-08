class HUD {
  int hudW;
  int hudH;
  float x, y;
  int r, g, b;
  PGraphics myHud;
  ArrayList<HUDAsset> assets;
  ArrayList<Float> assetsX;
  ArrayList<Float> assetsY;
  
  HUD(int hudW, int hudH, float x, float y, int r, int g, int b) {
    this.hudW = hudW;
    this.hudH = hudH;
    this.x = x;
    this.y = y;
    this.r = r;
    this.g = g;
    this.b = b;
    
    myHud = createGraphics(hudW, hudH, P2D);
    
    myHud.beginDraw();
    myHud.background(r, g, b);
    myHud.endDraw();
    
    assets = new ArrayList<HUDAsset>();
    assetsX = new ArrayList<Float>();
    assetsY = new ArrayList<Float>();
  }
  
  boolean mouseOver() {
    return mouseY > y; 
  }
  
  void dessine() {
    image(myHud, x, y);
    
    for (int i = 0; i < assets.size(); i++) {
       assets.get(i).dessine(assetsX.get(i) + x, assetsY.get(i) + y);
    }
  }
  
  void addAsset(HUDAsset asset, float assetX, float assetY) {
    assets.add(asset);
    assetsX.add(assetX);
    assetsY.add(assetY);
  }
}