class HUDLineImage extends HUDAsset {
  PGraphics temp;
  PImage image;
  LineDetection lineDetec;
  
  HUDLineImage(LineDetection lineDetec, int imgWidth, int imgHeight) {
    this.lineDetec = lineDetec;
    temp = createGraphics(imgWidth, imgHeight, P2D);
    temp.beginDraw();
    temp.background(0);
    temp.endDraw();
    image = temp.get();
  }
  
  void dessine(float x, float y) {
    image(image, x, y);
    
    if (lineDetec.valid) {
      image(lineDetec.sobel, x, y);
      image(lineDetec.linesFinal, x, y);
    }
  }
}