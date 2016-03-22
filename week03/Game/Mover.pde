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
    this.width0 = width0;
    this.height0 = height0;
    this.ballRadius = ballRadius;
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
  }
  
  void dessine() {
    
    translate(mover.location.x, -13, mover.location.y);
        mover.compute(rx, rz);
    mover.update();
    mover.checkEdges();
    //translate(-mover.location.x, 13, -mover.location.y);
  }
}