abstract class State {
  //final static State HUNTING_STATE = new HuntingState();

  final static color HUNTING_COLOR = #DFDA75;
  final static color WANDER_COLOR = #00FFFF;
  final static color CHARGING_COLOR = #FF0000;

  World w;
  Predator e;

  State (World w, Predator p) {
    this.w = w;
    this.e = p;
  }


  abstract State update();
  abstract PVector steer();
  abstract void move(PVector v);
}
