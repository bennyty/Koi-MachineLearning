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

  int predatorPenalty = 50;
  int agingPenalty = 5;

  //constructor
  EvolvedCreature(PVector l) {
    acceleration = new PVector();
    velocity = new PVector(random(-10,10), random(-10,10));
    location = l.get();
    r = 5;
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

  EvolvedCreature(PVector loc, PVector vel) {
    this(loc);
    velocity = vel;
  }

  // FITNESS FUNCTION 
  void calcFitness() {
    fitness = lifetime;
  }

  // Run in relation to all the obstacles
  // If I'm stuck, don't bother updating or checking for intersection
  void run(World w) {
    //if (!stopped) {
    if(doDraw) {
      display();
    }
    double[] senses = new double[inputCount]; //<>//
    PVector probe = new PVector(0,3*r);
    for (int i = 0; i < numFeelers; ++i) {
      senses[i] = 0;
      probe.rotate(0.785398);
      if (debug) {
        PVector elli = PVector.add(probe, location);
        ellipse(elli.x, elli.y, 2*r,2*r);
      }
      for (Predator o : w.getPredators()) {
        senses[i] = (PVector.dist(PVector.add(probe, location), o.location) < 2*r)? senses[i]:1;
      }
      for (Object o : w.getFood().getFood()) {
        PVector f = (PVector) o;
        senses[i+numFeelers] = (PVector.dist(PVector.add(probe, location), f) < 2*r)? senses[i+8]:1;
      }
    }
    senses[2*numFeelers]= health;
    senses[2*numFeelers + 1] = w.getDayTime();

    lifetime = millis() - birthday;

    double[] directions = brain.computeOutputs(senses);
    //System.out.println(directions[0] + ", " + directions[1]);
    update(directions[0]<0.5?true:false,directions[1]<0.5?true:false);

    // If I hit an edge or an obstacle
    borders();
    if (obstacles(w.predators)) {
      health -= predatorPenalty;
    } else {
      health -= agingPenalty;
    }
    //}
    // Draw me!
    //display();
  }

  void update(boolean move, boolean turnRight) {
    //System.out.println(move + " " + turnRight);
    // A little Reynolds steering here
    if (move) {
      PVector desired = PVector.mult(velocity, 1);
      desired.setMag(1);
      desired.rotate(turnRight ? -0.785398 : 0.785398);
      desired.mult(maxspeed);

      line(location.x, location.y, location.x + velocity.x, location.y + velocity.y);
      line(location.x, location.y, location.x + desired.x, location.y + desired.y);

      PVector steer = PVector.sub(desired,velocity);
      acceleration.add(steer);
      acceleration.limit(maxforce);
    }
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
    velocity.mult(.99);
  }

  void eat(Food f) {
    ArrayList<PVector> food = f.getFood();
    // Are we touching any food objects?
    for (int i = food.size()-1; i >= 0; i--) {
      PVector foodLocation = food.get(i);
      float d = PVector.dist(location, foodLocation);
      // If we are, juice up our strength!
      if (d < r) {
        health += 100; 
        food.remove(i);
      }
    }
  }

  // Did I hit an edge?
  void borders() {
    float padding = 5;
    if (location.x < 0-padding) {
      location.x = width+padding;
    } else if (location.y < 0-padding) {
      location.y = height+padding;
    } else if (location.x > width+padding) {
      location.x = 0-padding;
    } else if (location.y > height+padding) {
      location.y = 0-padding;
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

  // At any moment there is a teeny, tiny chance a bloop will reproduce
  EvolvedCreature forceBreed() {
    // Child is exact copy of single parent
    double[] m = brain.getMatrix();
    double[] t = brain.getThresholds();
    // Child DNA can mutate
    m = brain.mutate(0.10, m);
    t = brain.mutate(0.10, t);
    return new EvolvedCreature(new PVector(random(width),random(height)),m,t);
  }

  void display() {
    //fill(0,150);
    //stroke(0);
    //ellipse(location.x,location.y,r,r);
    float theta = velocity.heading() + PI/2;
    fill(200,map(health,0,1200,0,255));
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
