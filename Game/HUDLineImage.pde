class HUDLineImage extends HUDAsset {
  PGraphics temp;
  PImage image, visuals, lines;
  LineDetection lineDetec;
  int imgWidth, imgHeight;
  
  HUDLineImage(LineDetection lineDetec, int imgWidth, int imgHeight) {
    this.lineDetec = lineDetec;
    this.imgWidth = imgWidth;
    this.imgHeight = imgHeight;
    temp = createGraphics(imgWidth, imgHeight, P2D);
    temp.beginDraw();
    temp.background(0);
    temp.endDraw();
    image = temp.get();
  }
  
  void dessine(float x, float y) {
    image(image, x, y);
    
    if (lineDetec.valid) {
      visuals = lineDetec.img;
      visuals.resize(imgWidth, imgHeight);
    
      lines = lineDetec.linesFinal;
      lines.resize(imgWidth, imgHeight);
      
      image(visuals, x, y);
      image(lines, x, y);
    }
  }
}