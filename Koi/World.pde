// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Evolution Ecosystem

// The World we live in Has bloops and food


class World {

  ArrayList<EvolvedCreature> creatures;
  ArrayList<Predator> predators;
  Queue<EvolvedCreature> hallOfFame;
  Food food;
  int initialNumberOfCreatures;
  public Comparator<EvolvedCreature> EVCComparator = new Comparator<EvolvedCreature>() {
			@Override
			public int compare(EvolvedCreature l1, EvolvedCreature l2) {
				float w1 = l1.getFitness();
				float w2 = l2.getFitness();
				if (w1 - w2 > 0)
					return 1;
				if (w1 - w2 < 0)
					return -1;
				return 0;
			}
		};

  int generation;
  float generationAverageLifeTime;
  int generationDeaths;

  float bigBangTime;
  float startOfTheDay;
  float lengthOfDay = (24f * 1000 * 4);

  int numSkyColors = 3;
  color skyBlue = color(163, 220, 239);
  color sunsetRed = color(255, 137, 102);
  color midnightBlue = color(40, 13, 55);

  PrintWriter outputFile;

  // Constructor
  World(int num) {
    initialNumberOfCreatures = num;
    // Start with initial food and creatures
    creatures = new ArrayList<EvolvedCreature>();
    predators = new ArrayList<Predator>();
    hallOfFame = new PriorityQueue<EvolvedCreature>(EVCComparator);
    for (int i = 0; i < num; i++) {
      PVector l = new PVector(random(width),random(height));
      PVector v = new PVector(random(width),random(height));
      creatures.add(new EvolvedCreature(l,v));
    }
    bigBangTime = millis();
    startOfTheDay = 0;
    generation = 0;
    generationDeaths = 0;
    outputFile = createWriter(month() + "-" + day() + "-"  + year() + ":"  + hour() + "-"  + minute() + "-"  + second());
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
    return getSimulationTime() % lengthOfDay;
  }

  int getSkyColor() {
    float time = getDayTime();
    if (time < lengthOfDay/numSkyColors) {
      return lerpColor(skyBlue, sunsetRed, map(time, 0, lengthOfDay/numSkyColors, 0.0, 1.0));
    } else if (time < 2*lengthOfDay/numSkyColors) {
      return lerpColor(sunsetRed, midnightBlue, map(time, 0, 2*lengthOfDay/numSkyColors, 0.0, 1.0));
    } else {
      return lerpColor(midnightBlue, skyBlue, map(time, 0, lengthOfDay, 0.0, 1.0));
    }
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
    EvolvedCreature baby = new EvolvedCreature(l);
    baby.velocity = new PVector(random(-1,1),random(-1,1));
    creatures.add(baby);
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
      //b.eat(food);
      b.eat(this);
      // If it's dead, kill it and make food
      if (b.dead()) {
        generationAverageLifeTime += b.lifetime;
        generationDeaths++;
        hallOfFame.add(b);
        creatures.remove(i);
        //food.add(b.location);
      }
      // Perhaps this bloop would like to make a baby?
      EvolvedCreature child = b.reproduce();
      if (child != null) creatures.add(child);
    }

    //Repopulate from the survivors if population gets low
    if (creatures.size()<=initialNumberOfCreatures*.5) {
      outputFile.println(generation + ":" + generationAverageLifeTime/generationDeaths);
      outputFile.flush();
      //outputFile.close();
      generationDeaths = 0;
      generationAverageLifeTime = 0;
      generation++;
      while (creatures.size() <= initialNumberOfCreatures) {
        //for (int i = creatures.size() - 1; i >= 0; i--) {
          //EvolvedCreature child = creatures.get(i).forceBreed();
          //if (child != null) creatures.add(child);
        //}
        int QSize = hallOfFame.size() < 5 ? hallOfFame.size() : 5;
        for (int i = 0; i < QSize; i++) {
          EvolvedCreature child = hallOfFame.poll().forceBreed();
          if (child != null) creatures.add(child);
        }
        PVector l = new PVector(random(width),random(height));
        creatures.add(new EvolvedCreature(l));
      }
      food = new Food(initialNumberOfCreatures);
    }

    displayData();
  }

  void displayData() {
    fill(0);
    text("Generation: " + generation,0,10);
    text("Time of Day: " + getDayTime(),0,20);
    text("Number of Creatures: " + creatures.size(),0,30);
  }
}
