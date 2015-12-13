class HuntingState extends State {

  int numEaten;

  HuntingState(World w, Predator p) {
    super(w,p);
    numEaten = 0;
  }

  State update() {
    e.setFillColor(State.HUNTING_COLOR);
    PVector steerForce = steer();
    move(steerForce);
    if (eat(w.getCreatures())) {
      numEaten++;
    }
    if (numEaten > 10) {
      return new WanderingState(w,e);
    }
    return this;
  }

  PVector steer() {
    if (!w.getCreatures().isEmpty()) {
        //Seed with first food
        PVector target = w.getCreatures().get(0).location.copy();
        //Find closest food
        for (EvolvedCreature closestCreature : w.getCreatures()) {
          PVector closestCreatureLocation = closestCreature.location;
            if (PVector.dist(target, e.location) > PVector.dist(closestCreatureLocation, e.location)) {
                target = closestCreatureLocation;
            }
        }

        PVector desired = PVector.sub(target,e.location);
        desired.normalize();
        desired.mult(e.maxspeed);
        PVector steer = PVector.sub(desired,e.velocity);
        return steer;
    } else {
      return new PVector(width/2, height/2);
    }
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
        e.health += 200;
        return true;
      }
    }
    return false;
  }
}
