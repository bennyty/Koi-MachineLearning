class Predator {
  PVector location;
  PVector velocity;
  PVector acceleration;

  float r;
  int health;

  float maxspeed = 6.0;
  float maxforce = 1.0;

  Predator(PVector l) {
    location = l.copy();
    velocity = new PVector();
    acceleration = new PVector();
    r = 2;
    health = 1000;
  }

  void run(World w) {
    /*
     *double[] senses = new double[inputCount];
     *PVector probe = new PVector(0,2*r);
     *for (int i = 0; i < numFeelers; ++i) {
     *  senses[i] = 0;
     *  probe.rotate(0.785398);
     *  for (Predator o : w.getPredators()) {
     *    senses[i] = PVector.dist(location.add(probe), o.location) < 2*r)? senses[i]:1;
     *  }
     *  for (Food o : w.getFood()) {
     *    senses[i+numFeelers] = PVector.dist(location.add(probe), o.location) < 2*r)? senses[i+8]:1;
     *  }
     *}
     */

    update();
    // If I hit an edge or an obstacle
    if (borders()) {
      health -= 5;
    }
    // Draw me!
    display();
  }

  boolean borders() {
    if ((location.x < 0) || (location.y < 0) || (location.x > width) || (location.y > height)) {
      return true;
    } else {
      return false;
    }
  }

  void update() {
    // A little Reynolds steering here
    PVector desired = PVector.mult(velocity, 1);
    desired.normalize();
    desired.rotate((random(2)<1?false:true) ? -0.785398:0.785398);
    desired.mult(maxspeed);

    PVector steer = PVector.sub(desired,velocity);
    acceleration.add(steer);
    acceleration.limit(maxforce);

    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    //fill(0,150);
    //stroke(0);
    //ellipse(location.x,location.y,r,r);
    float theta = velocity.heading() + PI/2;
    fill(200,100);
    stroke(0);
    pushMatrix();
    translate(location.x,location.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  void highlight() {
    stroke(0);
    fill(255,0,0,100);
    ellipse(location.x,location.y,16,16);

  }
}
