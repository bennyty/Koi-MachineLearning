class HibernatingState extends State {
  float wanderTheta;

  HibernatingState(World w, Predator p) {
    super(w,p);
    wanderTheta = 0;
  }

  State update() {
    e.setFillColor(State.HIBERNATING_COLOR);
    e.health += 1;
    if (w.getDayTime() > 2*w.lengthOfDay/w.numSkyColors) return new HuntingState(w,e);
    return this;
  }

  PVector steer() {
    return new PVector(0,0);
  }

  void move(PVector steeringForce) {
    e.velocity.mult(0.99);
  }
}
