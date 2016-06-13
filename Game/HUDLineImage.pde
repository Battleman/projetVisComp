class HUDLineImage extends HUDAsset {
  LineDetection lineDetec;
  
  HUDLineImage(LineDetection lineDetec) {
    this.lineDetec = lineDetec;
  }
  
  void dessine(float x, float y) {
    image(lineDetec.linesFinal, x, y);
  }
}