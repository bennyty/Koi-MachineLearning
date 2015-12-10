// EvolvedCreature class -- this is just like our Boid / Particle class
// the only difference is that it has DNA & fitness
import java.text.DecimalFormat;
import java.math.RoundingMode;

class EvolvedCreature {
  //Neural Network stuff
  //int numFeelers = 8;
  int numFeelers = 5;
  //int inputCount = 2 + (numFeelers*2); // 8 numFeelers * 2 types (food and danger) + 1 time + 1 health
  int inputCount = 1 + (2*numFeelers) +2; // 8 numFeelers * 2 types (food and danger) + 1 time + 1 health
  int hiddenCount = 3; // Lol idk
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
  int foodsEaten;

  Network brain;

  // Could make this part of DNA??)
  float maxspeed = 6.0;
  float maxforce = 1.0;

  int predatorPenalty = 50;
  int agingPenalty = 4;

  PVector previousLocation;
  PVector birthPlace;
  float totalDistanceCovered;
  double[] directions;

  //constructor
  EvolvedCreature(PVector l) {
    acceleration = new PVector();
    velocity = new PVector(random(-1,1), random(-1,1));
    location = l.get();
    birthPlace = location.get();
    r = 5;
    lifetime = 0;
    foodsEaten = 0;
    birthday = millis();
    health = 1000;
    fitness = 0;
    totalDistanceCovered = 0;
    directions = new double[outputCount];
    directions[0] = 1;
    directions[1] = 1;
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
  void calcFitness(Food f) {
    //float distanceToNearestFood = Float.MAX_VALUE;
    //float distanceFromBirthplace = PVector.dist(location, birthPlace);
    //totalDistanceCovered += PVector.dist(location, previousLocation);
    //for(PVector p : f.getFood()) {
      //float d = PVector.dist(location, p);
      //if (d < distanceToNearestFood) distanceToNearestFood = d;
    //}
    //fitness = (50/distanceToNearestFood) + .1*totalDistanceCovered + distanceFromBirthplace + 300*foodsEaten;
    fitness = foodsEaten;
  }

  // Run in relation to all the obstacles
  // If I'm stuck, don't bother updating or checking for intersection
  void run(World w) {
    //if (!stopped) {
    if(doDraw) {
      display();
    }
    double[] senses = new double[inputCount];
    //PVector probe = PVector.mult(velocity, 1);
    PVector probe = velocity.copy();
    probe.normalize();
    probe.mult(5*r);
    probe.rotate(-1*0.785398*3);
    for (int i = 0; i < numFeelers; ++i) {
      senses[i] = 0;
      probe.rotate(0.785398);
      PVector shiftedProbe = PVector.add(probe, location);
      PVector shiftedProbe2 = PVector.add(PVector.mult(probe, 2),location);
      for (PVector f : w.getFood().getFood()) {
        senses[i] = (PVector.dist(shiftedProbe, f) < 4*r) ? 1:senses[i];
        senses[i+numFeelers] = (PVector.dist(shiftedProbe2, f) < 6*r) ? 1:senses[i];
      }
      //for (Predator o : w.getPredators()) {
        //senses[i+numFeelers] = (PVector.dist(shiftedProbe, o.location) < 4*r)? 1:senses[i+numFeelers];
      //}
      if (debug && (senses[i] == 1)) {
        ellipse(shiftedProbe.x, shiftedProbe.y, 4*r,4*r);
      }
      if (debug && (senses[i+numFeelers] == 1)) {
        ellipse(shiftedProbe2.x, shiftedProbe2.y, 6*r,6*r);
      }
    }
    /*
     *String sensesString = "";
     *for (int i = 0; i < numFeelers; ++i) {
     *  sensesString += senses[i];
     *}
     *if (sensesString == "0.00.00.00.00.00.00.00.0") {
     *  System.out.println(sensesString);
     *}
     */
    senses[2*numFeelers] = totalDistanceCovered;
    senses[2*numFeelers+1] = directions[0];
    senses[2*numFeelers+2] = directions[1];
    //senses[2*numFeelers] = health;
    //senses[2*numFeelers + 1] = w.getDayTime();

    lifetime = millis() - birthday;

    directions = brain.computeOutputs(senses);
    //System.out.println(directions[0] + ", " + directions[1]);
    update(directions[0]<0.5?true:false,directions[1]<0.5?true:false);
    calcFitness(w.getFood());

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
      //PVector desired = PVector.mult(velocity, 1);
      PVector desired = velocity.copy();
      desired.setMag(1);
      desired.rotate(turnRight ? -0.785398 : 0.785398);
      desired.mult(maxspeed);

      if(debug) {
        line(location.x, location.y, location.x + velocity.x, location.y + velocity.y);
        line(location.x, location.y, location.x + desired.x, location.y + desired.y);
      }

      PVector steer = PVector.sub(desired,velocity);
      acceleration.add(steer);
      acceleration.limit(maxforce);
    }
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    //previousLocation = PVector.mult(location, 1);
    previousLocation = location.copy();
    location.add(velocity);
    acceleration.mult(0);
    velocity.mult(0.9);
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
        //r++;
        foodsEaten++;
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

  // At any moment there is a teeny, tiny chance a creature will reproduce
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
    DecimalFormat df = new DecimalFormat("#.##");
    df.setRoundingMode(RoundingMode.CEILING);

/*
 *    System.out.println("---------------------------");
 *    System.out.print("m: ");
 *    for (int i = 0; i < m.length; i++) {
 *      System.out.print(df.format(m[i]) + ", ");
 *    }
 *    System.out.println();
 *
 *    System.out.print("t: ");
 *    for (int i = 0; i < t.length; i++) {
 *      System.out.print(df.format(t[i]) + ", ");
 *    }
 *    System.out.println();
 *    System.out.println();
 */

    // Child DNA can mutate
    m = brain.mutate(0.10, m);
    t = brain.mutate(0.10, t);
/*
 *    System.out.print("mm: ");
 *    for (int i = 0; i < m.length; i++) {
 *      System.out.print(df.format(m[i]) + ", ");
 *    }
 *    System.out.println();
 *
 *    System.out.print("tm: ");
 *    for (int i = 0; i < t.length; i++) {
 *      System.out.print(df.format(t[i]) + ", ");
 *    }
 *    System.out.println();
 */
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
    fill(255,0,0,50);
    ellipse(location.x,location.y,32,32);

  }

  float getFitness() {
    return fitness;
  }

}
