class HUD {
  int hudW, hudH;
  float x, y;
  int hudColor;
  PGraphics myHud;
  List<HUDAsset> assets;
  List<Float> assetsX, assetsY;
  
  HUD(int hudW, int hudH, float x, float y, int hudColor) {
    this.hudW = hudW;
    this.hudH = hudH;
    this.x = x;
    this.y = y;
    this.hudColor = hudColor;
    
    myHud = createGraphics(hudW, hudH, P2D);
    
    myHud.beginDraw();
    myHud.background(hudColor);
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