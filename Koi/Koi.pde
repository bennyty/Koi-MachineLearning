// Evolution EcoSystem
// Daniel Shiffman <http://www.shiffman.net>
// The Nature of Code

// A World of creatures that eat food
// The more they eat, the longer they survive
// The longer they survive, the more likely they are to reproduce
// The bigger they are, the easier it is to land on food
// The bigger they are, the slower they are to find food
// When the creatures die, food is left behind
import java.io.StringWriter;
import java.util.*;

World world;
Network nn;
boolean doDraw;
boolean debug;

void setup() {
  size(1280, 720);

  world = new World(100);
  world.food = new Food(75);
  doDraw = true;
  debug = true;
  //smooth();
}

void draw() {
  background(world.getSkyColor());
  try {
    world.run();
  } catch (Exception e){
    System.out.println(e.getMessage());
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    e.printStackTrace(pw);
    pw.flush();
    String stackTrace = sw.toString();
    System.out.println(stackTrace);
  }
}

// We can add a creature manually if we so desire
void mousePressed() {
  world.birth(mouseX,mouseY); 
}

void mouseDragged() {
  world.birth(mouseX,mouseY); 
}

void keyReleased() {
  if (key == ' ') {
    doDraw = !doDraw;
  } else if (key == 'd') {
    debug = !debug;
  }
}
