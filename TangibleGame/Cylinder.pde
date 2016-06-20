class Cylinder {
  float x, y, radius, cylinderHeight;
  int res;
  PShape cylinder = new PShape();
  PShape cylinderHat = new PShape();
  int cylColor;
  
  Cylinder(float x, float y, float radius, float cylinderHeight, int res, int cylColor) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.cylinderHeight = cylinderHeight;
    this.res = res;
    this.cylColor = cylColor;
  }
  
  float getX() {
    return x;
  }
  
  float getY() {
    return y;
  }
  
  float getRadius() {
    return radius; 
  }
  
  void param() {
    float angle;
    float[] x = new float[res + 1];
    float[] z = new float[res + 1];
    fill(cylColor);
    
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / res) * i;
      x[i] = sin(angle) * radius;
      z[i] = cos(angle) * radius;
    }
    cylinder = createShape();
    
    cylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      cylinder.vertex(x[i], 0, z[i]);
      cylinder.vertex(x[i], -cylinderHeight, z[i]);
    }
    cylinder.endShape();
    
    cylinderHat = createShape();
    
    cylinderHat.beginShape(TRIANGLE_FAN);
    cylinderHat.vertex(0, -cylinderHeight, 0);
    for (int i = 0; i < x.length; i++) {
      cylinderHat.vertex(x[i], -cylinderHeight, z[i]);
    }
    cylinderHat.endShape();
    noFill();
  }
  
  void dessine() {
    translate(x, 0, y);
    shape(cylinderHat);
    shape(cylinder);
    translate(-x, 0, -y);
  }
}