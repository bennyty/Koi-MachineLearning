// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Evolution EcoSystem

// The World we live in Has bloops and food
class World {

  ArrayList<EvolvedCreature> creatures;
  ArrayList<Predator> predators;
  Food food;

  float bigBangTime;
  float startOfTheDay;

  // Constructor
  World(int num) {
    // Start with initial food and creatures
    food = new Food(num);
    creatures = new ArrayList<EvolvedCreature>();
    predators = new ArrayList<Predator>();
    for (int i = 0; i < num; i++) {
      PVector l = new PVector(random(width),random(height));
      creatures.add(new EvolvedCreature(l));
    }
    bigBangTime = millis();
    startOfTheDay = 0;
  }

  float getDayTime() {
    /*
     *float dayTime = getSimulationTime() - startOfTheDay;
     *float lengthOfDay = 24f * 1000 * 4;
     *if dayTime >= lengthOfDay {
     *  startOfTheDay = getSimulationTime();
     *  return dayTime;
     *} else {
     *  return dayTime;
     *}
     */
    return getSimulationTime() % (24f * 1000 * 4);
  }

  float getSimulationTime() {
    return millis() - bigBangTime;
  }

  ArrayList<EvolvedCreature> getCreatures() {
    return creatures;
  }

  ArrayList<Predator> getPredators() {
    return predators;
  }

  Food getFood() {
    return food;
  }

  // Make a new creature
  void birth(float x, float y) {
    PVector l = new PVector(x,y);
    creatures.add(new EvolvedCreature(l));
  }

  // Run the world
  void run() {
    // Deal with food
    food.run();

    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = creatures.size() - 1; i >= 0; i--) {
      // All bloops run and eat
      EvolvedCreature b = creatures.get(i);
      b.run(this);
      b.eat(food);
      // If it's dead, kill it and make food
      if (b.dead()) {
        creatures.remove(i);
        food.add(b.location);
      }
      // Perhaps this bloop would like to make a baby?
      EvolvedCreature child = b.reproduce();
      if (child != null) creatures.add(child);
    }
  }
}