class WanderingState extends State {
  float wanderTheta;

  WanderingState(World w, Predator p) {
    super(w,p);
    wanderTheta = 0;
  }

  State update() {
    e.setFillColor(State.WANDER_COLOR);
    PVector steerForce = steer();
    move(steerForce);
    eat(w.getCreatures());
    if (e.health < 100 || w.getDayTime() < w.lengthOfDay/w.numSkyColors ) return new HibernatingState(w,e);
    return this;
  }

  PVector steer() {
    float wanderR = 10;         // Radius for our "wander circle"
    float wanderD = 80;         // Distance for our "wander circle"
    float change = 0.1;
    wanderTheta += random(-change,change);     // Randomly change wander theta

    // Now we have to calculate the new location to steer towards on the wander circle
    PVector circleloc = e.velocity.get();    // Start with velocity
    circleloc.normalize();            // Normalize to get heading
    circleloc.mult(wanderD);          // Multiply by distance
    circleloc.add(e.location);               // Make it relative to boid's location
    
    float h = e.velocity.heading2D();        // We need to know the heading to offset wanderTheta

    PVector circleOffSet = new PVector(wanderR*cos(wanderTheta+h),wanderR*sin(wanderTheta+h));
    PVector target = PVector.add(circleloc,circleOffSet);

    if(debug) drawWanderStuff(e.location, circleloc, target, wanderR);

    PVector desired = PVector.sub(target,e.location);
    desired.normalize();
    desired.mult(e.maxspeed);
    PVector steer = PVector.sub(desired,e.velocity);
    return steer;
  }

  void move(PVector steeringForce) {
    e.acceleration.add(steeringForce);
    e.acceleration.limit(e.maxforce);

    e.velocity.add(e.acceleration);
    e.velocity.limit(e.maxspeed);
    e.location.add(e.velocity);
    e.acceleration.mult(0);
  }

  boolean eat(ArrayList<EvolvedCreature> food) {
    //In this method, food refers to the Predators food (a creature) not a food object
    for (int i = food.size()-1; i >= 0; i--) {
      PVector foodLocation = food.get(i).location.copy();
      float d = PVector.dist(e.location, foodLocation);
      if (d < e.r) {
        food.remove(i);
        e.health += 100;
        return true;
      }
    }
    return false;
  }

  void drawWanderStuff(PVector location, PVector circle, PVector target, float rad) {
    stroke(0); 
    noFill();
    ellipseMode(CENTER);
    ellipse(circle.x,circle.y,rad*2,rad*2);
    ellipse(target.x,target.y,4,4);
    line(location.x,location.y,circle.x,circle.y);
    line(circle.x,circle.y,target.x,target.y);
  }

}
