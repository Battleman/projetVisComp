class HUDLineImage extends HUDAsset {
  PGraphics temp;
  PImage blackImage, visuals, lines;
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
    blackImage = temp.get();
  }
  
  void dessine(float x, float y) {
    image(blackImage, x, y);
    
    if (lineDetec.valid) {
      visuals = lineDetec.sobel;
      visuals.resize(imgWidth, imgHeight);
    
      lines = lineDetec.linesFinal;
      lines.resize(imgWidth, imgHeight);
      
      image(visuals, x, y);
      image(lines, x, y);
    }
  }
}