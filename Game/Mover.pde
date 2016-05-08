class Mover {
  
  PVector location;
  PVector velocity;
  PVector force;
  PVector friction;
  float gravityConstant;
  float normalForce;
  float mu;
  float frictionMagnitude;
  float width0;
  float height0;
  float ballRadius;
  float bounceCoeff;
  int score, lastScore;
  ArrayList<PVector> vec;
  boolean hit;

  Mover(float width0, float height0, float ballRadius) {
    location = new PVector(0, 0);
    velocity = new PVector(0, 0);
    force = new PVector(0, 0);
    friction = new PVector(0, 0);
    gravityConstant = 0.5;
    normalForce = 1;
    mu = 0.01;
    frictionMagnitude = normalForce * mu;
    bounceCoeff = 0.9;
    score = 0;
    hit = false;
    this.width0 = width0;
    this.height0 = height0;
    this.ballRadius = ballRadius;
  }
  
  PVector getPos() {
    return location;
  }
  
  int getVelocity() {
    return (int) velocity.mag();
  }
  
  int getScore() {
    return score;
  }
  
  int getLastScore() {
    return lastScore;
  }
  
  boolean hasHit() {
    return hit;
  }
  
  void resetHit() {
    hit = false; 
  }
  
  void update() {
    velocity.add(force);
    location.add(velocity);
  }
  
  void compute(float rX, float rZ) {
    force.x = sin(rZ) * gravityConstant;
    force.y = sin(rX) * gravityConstant;
    
    friction = velocity.copy();
    friction.normalize();
    friction.mult(-frictionMagnitude);
    
    force.add(friction);
  }
  
  void checkEdges() {
    if (location.x + ballRadius > width0 / 2) {
      location.x = width0 / 2 - ballRadius;
      bounce(true);
    }
    else if (location.x - ballRadius < - width0 / 2) {
      location.x = - width0 / 2 + ballRadius;
      bounce(true);
    }
    
    if (location.y + ballRadius > height0 / 2) {
      location.y = height0 / 2 - ballRadius;
      bounce(false);
    }
    else if (location.y - ballRadius < - height0 / 2) {
      location.y = - height0 / 2 + ballRadius;
      bounce(false);
    }
  }
  
  void bounce(boolean x) {
    if (x) {
      velocity.x = - bounceCoeff * velocity.x;
    }
    else {
      velocity.y = - bounceCoeff * velocity.y;
    }
    addScore(false);
  }
  
  void addScore(Boolean sign) {
    hit = true;
    int temp = -1;
    if (sign) {
      temp = 1;
    }
    lastScore = (int) (200 * Math.random()) - 100;//getVelocity() * temp;
    score += lastScore;
  }
  
  void dessine() {
    fill(255, 255, 255);
    translate(mover.location.x, -13, mover.location.y);
    mover.compute(rx, rz);
    mover.update();
    mover.checkEdges();
    sphere(ballRadius);
    translate(-mover.location.x, 13, -mover.location.y);
    noFill();
  }
  
  void checkCylinderCollision(ArrayList<PVector> vec, float radius) {
    for (int i = 0; i < vec.size(); i++) {
      PVector temp = vec.get(i);
      if (location.dist(temp) < radius + ballRadius) {
        PVector n = new PVector(location.x - temp.x, location.y - temp.y);
        PVector unit = n.copy().normalize();
        location = temp.copy().add(unit.copy().mult(n.mag() + ballRadius));
        velocity.sub(unit.mult(2 * (velocity.copy().dot(unit)))).mult(bounceCoeff);
        addScore(true);
      }
    }
  }
}
  