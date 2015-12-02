// EvolvedCreature class -- this is just like our Boid / Particle class
// the only difference is that it has DNA & fitness
class EvolvedCreature {
  //Neural Network stuff
  int numFeelers = 8;
  int inputCount = 2 + numFeelers*2; // 8 numFeelers * 2 types (food and danger) + 1 time + 1 health
  int hiddenCount = 20 // Lol idk
  int outputCount = 2 // Left/Right + Move/Stay
  double learnRate = .5: // Lol idk
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
    recordDist = width;
    lifetime = 0;
    birthday = millis();
    health = 1000;
    fitness = 0;
    brain = new Network(inputCount,hiddenCount,outputCount,learnRate,momentum);
  }

  EvolvedCreature(PVector l, double[] t, double[] m) {
    EvolvedCreature(l);
    brain.setThresholds(t);
    brain.setMatrix(m);
  }

  // FITNESS FUNCTION 
  void calcFitness() {
    fitness = lifetime;
  }

  // Run in relation to all the obstacles
  // If I'm stuck, don't bother updating or checking for intersection
  void run(World w) {
    if (!stopped) {
      double[] senses = new double[inputCount];
      PVector probe = new PVector(0,2*r);
      for (int i = 0; i < numFeelers; ++i) {
        senses[i] = 0;
        probe.rotate(0.785398);
        for (Predator o : w.getPredators()) {
          senses[i] = PVector.dist(location.add(probe), o.location) < 2*r)? senses[i]:1;
        }
        for (Food o : w.getFood()) {
          senses[i+numFeelers] = PVector.dist(location.add(probe), o.location) < 2*r)? senses[i+8]:1;
        }
      }
      senses[2*numFeelers + 1]= health;
      senses[2*numFeelers + 2] = w.getDayTime();

      lifetime = millis() - birthday;

      double[] directions = brain.computeOutputs(senses);
      update(directions[0],directions[1]);
      
      // If I hit an edge or an obstacle
      if ((borders()) || (obstacles(w.predators))) {
        health -= 5;
      }
    }
    // Draw me!
    display();
  }

   // Did I hit an edge?
   boolean borders() {
    if ((location.x < 0) || (location.y < 0) || (location.x > width) || (location.y > height)) {
      return true;
    } else {
      return false;
    }
  }


  void update(boolean move, boolean turnRight) {
    // A little Reynolds steering here
    PVector desired = PVector.mult(velocity, 1);
    desired.normalize();
    desired.rotate(0.785398);
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired,velocity);
    acceleration.add(steer);
    acceleration.limit(maxforce);
    
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
  }
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelerationelertion to 0 each cycle
    acceleration.mult(0);

    location.x = constrain(location.x,0,width);
    location.y = constrain(location.y,0,height);
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // Here is where the brain processes everything
  void steer(ArrayList<PVector> targets) {
    // Make an array of forces
    PVector[] forces = new PVector[targets.size()];

    // Steer towards all targets
    for (int i = 0; i < forces.length; i++) {
      forces[i] = seek(targets.get(i));
    }

    // That array of forces is the input to the brain
    PVector result = brain.feedforward(forces);

    // Use the result to steer the vehicle
    applyForce(result);

    // Train the brain according to the error
    PVector error = PVector.sub(desired, location);
    brain.train(forces,error);

  }

  // A method that calculates a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target,location);  // A vector pointing from the location to the target

    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  // Limit to maximum steering force

    return steer;
  }
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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
    line(location.x,location.y,target.r.x,target.r.y);
    fill(255,0,0,100);
    ellipse(location.x,location.y,16,16);
 
  }

  float getFitness() {
    return fitness;
  }

}
