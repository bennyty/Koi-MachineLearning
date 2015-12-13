class Predator {
    PVector location;
    PVector velocity;
    PVector acceleration;

    float r;
    color fillColor;
    color edgeColor;

    int health;

    float maxspeed = 2.0;
    float maxforce = 0.5;

    State state;

    World w;

    Predator(PVector l, World w) {
        this.w = w;
        this.state = new HuntingState(w,this);
        location = l.copy();
        velocity = new PVector( random(width), random(height) ).normalize().mult(maxspeed);
        acceleration = new PVector();
        r = 7;
        health = 1000;
    }

    void run() {
        // Move / steer / change state
        this.state = state.update();
        this.health -= 2;
        // If I hit an edge, stop
        borders();
        // Draw me!
        display();
    }

    // If I hit an edge, stop
    void borders() {
        float padding = 5;
        if (location.x < 0-padding) {
            location.x = 0-padding;
        } else if (location.y < 0-padding) {
            location.y = 0-padding;
        } else if (location.x > width+padding) {
            location.x = width+padding;
        } else if (location.y > height+padding) {
            location.y = height+padding;
        }
    }

    void setFillColor(color c) {
        fillColor = c;
    }

    void setEdgeColor(color c) {
        edgeColor = c;
    }

    void display() {
        float theta = velocity.heading() + PI/2;
        fill(fillColor);
        stroke(edgeColor);
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
}
