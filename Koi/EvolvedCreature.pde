// EvolvedCreature class -- this is just like our Boid / Particle class
// the only difference is that it has DNA & fitness
class EvolvedCreature {
  //Neural Network stuff
  int numFeelers = 8;
  int inputCount = 2 + (numFeelers*2); // 8 numFeelers * 2 types (food and danger) + 1 time + 1 health
  int hiddenCount = 20; // Lol idk
  int outputCount = 2; // Left/Right + Move/Stay
  double learnRate = .5; // Lol idk
  double momentum = .5; // Lol idk

  // All of our physics stuff
  PVector location;
  PVector velocity;
  PVector acceleration;

  float r;
  float lifetime;
  float birthday;
  int health;

  float fitness;

  Network brain;

  // Could make this part of DNA??)
  float maxspeed = 6.0;
  float maxforce = 1.0;

  //constructor
  EvolvedCreature(PVector l) {
    acceleration = new PVector();
    velocity = new PVector();
    location = l.get();
    r = 2;
    lifetime = 0;
    birthday = millis();
    health = 1000;
    fitness = 0;
    brain = new Network(inputCount,hiddenCount,outputCount,learnRate,momentum);
  }

  EvolvedCreature(PVector l, double[] m, double[] t) {
    this(l);
    brain.setThresholds(t);
    brain.setMatrix(m);
  }

  EvolvedCreature() {
    this(new PVector(0,0));
  }

  // FITNESS FUNCTION 
  void calcFitness() {
    fitness = lifetime;
  }

  // Run in relation to all the obstacles
  // If I'm stuck, don't bother updating or checking for intersection
  void run(World w) {
    //if (!stopped) {
      double[] senses = new double[inputCount]; //<>//
      PVector probe = new PVector(0,2*r);
      for (int i = 0; i < numFeelers; ++i) {
        senses[i] = 0;
        probe.rotate(0.785398);
        for (Predator o : w.getPredators()) {
          senses[i] = (PVector.dist(location.add(probe), o.location) < 2*r)? senses[i]:1;
        }
        for (Object o : w.getFood().getFood()) {
          PVector f = (PVector) o;
          senses[i+numFeelers] = (PVector.dist(location.add(probe), f) < 2*r)? senses[i+8]:1;
        }
      }
      senses[2*numFeelers]= health;
      senses[2*numFeelers + 1] = w.getDayTime();

      lifetime = millis() - birthday;

      double[] directions = brain.computeOutputs(senses);
      //System.out.println(directions[0] + ", " + directions[1]);
      update(directions[0]<0.5?false:true,directions[1]<0.5?false:true);

      // If I hit an edge or an obstacle
      if ((borders()) || (obstacles(w.predators))) {
        health -= 5;
      }
    //}
    // Draw me!
    display();
  }

  void update(boolean move, boolean turnRight) {
    // A little Reynolds steering here
    PVector desired = PVector.mult(velocity, 1);
    desired.normalize();
    desired.rotate(turnRight ? -0.785398:0.785398);
    desired.mult(maxspeed);

    PVector steer = PVector.sub(desired,velocity);
    acceleration.add(steer);
    acceleration.limit(maxforce);

    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
  }

  void eat(Food f) {
    ArrayList<PVector> food = f.getFood();
    // Are we touching any food objects?
    for (int i = food.size()-1; i >= 0; i--) {
      PVector foodLocation = food.get(i);
      float d = PVector.dist(location, foodLocation);
      // If we are, juice up our strength!
      if (d < r/2) {
        health += 100; 
        food.remove(i);
      }
    }
  }

  // Did I hit an edge?
  boolean borders() {
    if ((location.x < 0) || (location.y < 0) || (location.x > width) || (location.y > height)) {
      return true;
    } else {
      return false;
    }
  }

  boolean obstacles(ArrayList<Predator> predators) {
    for (Predator p : predators) {
      if (PVector.dist(p.location,location) < r) {
        return true;
      }
    }
    return false;
  }

  boolean dead() {
    return health <= 0 ? true : false;
  }

  // At any moment there is a teeny, tiny chance a bloop will reproduce
  EvolvedCreature reproduce() {
    // asexual reproduction
    if (random(1) < 0.0005) {
      // Child is exact copy of single parent
      double[] m = brain.getMatrix();
      double[] t = brain.getThresholds();
      // Child DNA can mutate
      m = brain.mutate(0.01, m);
      t = brain.mutate(0.01, t);
      return new EvolvedCreature(location,m,t);
    } 
    else {
      return null;
    }
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

  float getFitness() {
    return fitness;
  }

}