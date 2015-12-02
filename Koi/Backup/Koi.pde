/* Benjamin Espey
 * Inspiration from:
 *     Daniel Shiffman
 */

float zoom;
// A vector to store the offset from the center
PVector offset;
// The previous offset
PVector poffset;
// A vector for the mouse position
PVector mouse;

void setup() {
  size(600, 400);
  zoom = 1.0;
  offset = new PVector(0, 0);
  poffset = new PVector(0, 0);

  smooth();
}

void draw() {
  background(255);
  pushMatrix();
  // Everything must be drawn relative to center
  translate(width/2, height/2);
  
  // Use scale for 2D "zoom"
  scale(zoom);
  // The offset (note how we scale according to the zoom)
  translate(offset.x/zoom, offset.y/zoom);
  
  // An arbitrary design so that we have something to see!
  randomSeed(1);
  for (int i = 0; i < 500; i++) {
    stroke(0);
    noFill();
    rectMode(CENTER);
    float h = 100;
    if (random(1) < 0.5) {
      rect(random(-h,h),random(-h,h),12,12);
    } else {
      ellipse(random(-h,h),random(-h,h),12,12);
    } 
  }
  popMatrix();
  
  // Draw some text (not panned or zoomed!)
  fill(0);
  text("a: zoom in\nz: zoom out\ndrag mouse to pan",10,32);
  
  
}

// Zoom in and out when the key is pressed
void keyPressed() {
  if (key == 'a') {
    zoom += 0.1;
  } 
  else if (key == 'z') {
    zoom -= 0.1;
  }
  zoom = constrain(zoom,0,100);
}

// Store the mouse and the previous offset
void mousePressed() {
  mouse = new PVector(mouseX, mouseY);
  poffset.set(offset);
}

// Calculate the new offset based on change in mouse vs. previous offsey
void mouseDragged() {
  offset.x = mouseX - mouse.x + poffset.x;
  offset.y = mouseY - mouse.y + poffset.y;
}
