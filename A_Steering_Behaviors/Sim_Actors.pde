/*
    A Vehicle subclass that only moves if the mouse moves.
*/
class MouseVehicle extends Mover {
  PVector lastMousePos = new PVector(mouseX,mouseY);
  
  MouseVehicle () {
    super(mouseX-10,mouseY-10);
    vel.set(MAX_FOLLOW_PATH_VELOCITY,0);
  }
  
  void Update () {
    // No velocity or acceleration updates - only moves when mouse moves
    pos.x = mouseX - 10; pos.y = mouseY - 10;
    // Calculate heading based on previous mouse position to this position
    PVector currentMousePos = new PVector(mouseX,mouseY);
    if ( currentMousePos.equals(lastMousePos) ) return;    // No movement in mouse
    
    vel = PVector.sub(currentMousePos,lastMousePos).setMag(MAX_FOLLOW_PATH_VELOCITY);
    lastMousePos = currentMousePos.copy();
  }
  
  void Show () {
  }
}

class Follower extends Mover {
  Follower ( int radius, color clr ) {
    super(radius,clr); 
  }
    
  void Update () {
    if ( ! DO_UPDATES ) return;
    vel.add(acc);
    if ( vel.mag() < 5 ) vel.setMag(5);
    pos.add(vel);
    acc.set(0,0);
  }

  void Show () {
    pushMatrix();
      // Drawing vehicle and collision graphics relative to its position
      translate(pos.x,pos.y);
      rotate(vel.heading());
      
      stroke(255);
      strokeWeight(1);
      fill(clr);   
      beginShape();
        vertex(-radius,-radius);
        vertex(-radius,radius); 
        vertex(radius*2,0);
      endShape(CLOSE);      
    popMatrix();  
  }
  
}

class Target extends Mover {
  final static int TARGET_FOLLOW_NONE = 0, 
                   TARGET_FOLLOW_RANDOM_PT = 1, 
                   TARGET_FOLLOW_MOUSE = 2;
  PVector moveTo;
  int     follow;  // 0 = nothing (hide), 1 = random cursor, 2 = mouse
  
  Target(color clr) {
    super(clr);
    moveTo = new PVector(random(width),random(height));
    follow = TARGET_FOLLOW_RANDOM_PT;
  }
  
  void SetWhatToFollow ( int follow ) {
    this.follow = follow;
  }
  
  void Update() {
    if ( ! DO_UPDATES ) return;   
    if ( follow != TARGET_FOLLOW_NONE ) { 
      if ( follow == TARGET_FOLLOW_RANDOM_PT ) {
        if ( moveTo.dist(pos) < 5 )
          moveTo.set(random(width),random(height));
        Seek(moveTo);
      } else    // Follow the mouse.  When close, slow and stop at the point
        Arrive(new PVector(mouseX,mouseY));
    super.Update();
    }
  }
  
  void Show() {
    if ( follow == TARGET_FOLLOW_NONE )     // Show nothing....
      return;
    if ( follow == TARGET_FOLLOW_RANDOM_PT ) {
      if ( millis() % 500 > 250 ) {
        pushMatrix();
          translate(moveTo.x,moveTo.y);
          stroke(255);
          strokeWeight(2);
          fill(255,255,255,100);
          line(-10,0,10,0);
          line(0,10,0,-10);
          strokeWeight(1);
        popMatrix();
      }
    }
    pushMatrix();
      translate(pos.x,pos.y);
      // Color should change based on Mouse or Random movement
      stroke(255);
      if ( follow == TARGET_FOLLOW_RANDOM_PT )
        clr = color(0,255,0,150);
      else
        clr = color(0,255,255,150);
      fill(clr);
      beginShape();
        vertex(-10,0);
        vertex(0,-10);
        vertex(10,0);
        vertex(0,10);
      endShape(CLOSE);
    popMatrix();
  }
}

class Obstacle extends Mover {
  ArrayList<PVector> pts;
  boolean moves = true;
  float x, y;
  float angle = random(TWO_PI); 
  float rotationRate = random(-0.02, 0.02);
  
  Obstacle ( float x, float y, int radius, color clr ) {
    this(radius,clr);
    pos.x = this.x = x; pos.y = this.y = y;
    moves = false;
  }
  
  Obstacle ( int radius_, color clr ) {
    super(radius_,clr); 
    mass = radius * 0.1;
    pts = new ArrayList<PVector>();
    // Create a series of points around the radius of a circle
    int numPts = floor(random(10,20));
    if ( numPts % 2 != 0 ) numPts++;    // an even number of points
    float inc = TWO_PI / numPts;
    float off = 0.1;
    for ( float rads = 0; rads < TWO_PI; rads += inc ) {
      // Add Perlin noise
      float val = radius + random(-10,10) * noise(off);
      off += 0.5;
      PVector v = new PVector(val * cos(rads),val * sin(rads));
      pts.add(v);
    }
  }
  
  void Separation ( ArrayList<Mover> othersToAvoid ) {
    Separation ( othersToAvoid, radius*2, 3, 0.25 );   
  }
  
  void Update() {
    if ( ! DO_UPDATES ) return;
    if ( moves )
      super.Update();
    else 
      pos.set(x,y); 
  }
  
  void Show () {
    stroke(255);
    fill(clr);
    pushMatrix();
      angle += rotationRate;
      translate(pos.x,pos.y);
      rotate(angle);
      beginShape();
        for ( int i=0; i < pts.size(); i++ ) {
          PVector v = pts.get(i);
          vertex(v.x,v.y);
        }
      endShape(CLOSE);
    popMatrix();
  }
}

class Avoider extends Mover { 
  boolean seeAnObstacle = false,
          goingToHit = false;
  PanelControl control;
  
  Avoider ( int radius, color clr, PanelControl p ) {
    super(radius,clr); 
    control = p;
    vel = PVector.fromAngle(radians(random(PI))).setMag(MAX_AVOID_VELOCITY);
  }
  
  void Update() {
    if ( ! DO_UPDATES ) return;    
    vel.add(acc);
    // Need to ensure there is always some velocity ??
    //if ( vel.mag() < MAX_VELOCITY ) vel.setMag(MAX_VELOCITY);
    pos.add(vel);
    acc.set(0,0);    
    Edges(); 
  }

  void Show () {
    pushMatrix();
      // Drawing vehicle and collision graphics relative to its position
      translate(pos.x,pos.y);
      rotate(vel.heading());

      if ( SHOW_VECTORS ) {
        noStroke();
        fill(255,255,255,25);
        rect(-radius,-radius,control.GetValue(),2*radius);
      }
      
      stroke(255);
      strokeWeight(1);
      fill(clr);   
      beginShape();
        vertex(-radius,-radius);
        vertex(-radius,radius); 
        vertex(radius*2,0);
      endShape(CLOSE);      
    popMatrix();  
  }
}

class Wanderer extends Mover {
  final static float MAX_VELOCITY = 6;
  final static float MAX_FORCE = 1;
  float noiseInc = 0.05, noiseOff = 0.5;
  
  Wanderer(float radius, color clr) { 
    super(radius,clr); 
    noiseInc = random(0.01,0.1);
    noiseOff = random(0.01,1.0);
  }
  
  void Update () {
    if ( ! DO_UPDATES ) return;  
    super.Update();
    //MoverBase.DrawForceVector ( pos, vel, 6.0, color(0,255,0) );
  }
  
  void Show() {    
    pushMatrix();
      translate(pos.x,pos.y);
      rotate(vel.heading());
      stroke(255);
      strokeWeight(1);
      fill(clr);   
      beginShape();
        vertex(-radius,-radius);
        vertex(-radius,radius); 
        vertex(radius*2,0);
      endShape(CLOSE);      
    popMatrix(); 
  }
  
  void Wander ( ) {
    // Randomly wander about the scene. Uses Perlin noise.
    PVector newVel = PVector.fromAngle(map(noise(noiseOff),0,1,0,TWO_PI)).setMag(6);
    AddForce(PVector.sub(newVel,vel).limit(0.2));
    vel.setMag(constrain(vel.mag(),4,4));
    noiseOff += noiseInc;
  }
}

class BadGuy extends Mover {

  final static float MIN_BADGUY_SEPARATION_DIST = 45;
  final static float MIN_BADGUY_AVOID_DIST = 75;
  final static float MAX_BADGUY_VELOCITY = 3;
  final static float MAX_BADGUY_FORCE = 0.2;  
  final static float MOUTH_START = QUARTER_PI;
  final static float MOUTH_STOP  = 7 * QUARTER_PI;
  final static float MOUTH_INCREMENT = 0.05;
  
  float mouthSize = random(QUARTER_PI),   // mouth opened at a random amount
        mouthIncrement = MOUTH_INCREMENT;
  
  BadGuy ( int radius, color clr ) {
    super(radius,clr);
  }
  
  BadGuy () {
    super(15,color(128,0,128,150));
  }
  
  void Update () {
    if ( ! DO_UPDATES ) return;
    
    vel.add(acc);
    vel.setMag(constrain(vel.mag(),2,4));    // Always keep it moving...
    pos.add(vel);
    acc.set(0,0);
    Edges();
  }  

  // Should be based on the size of the badguy??
  void Separation ( ArrayList<Mover> othersToAvoid ) {
    Separation ( othersToAvoid, MIN_BADGUY_SEPARATION_DIST, MAX_BADGUY_VELOCITY, 
                 MAX_BADGUY_FORCE );   
  }
  
  void AvoidObstacles ( ArrayList<Mover> othersToAvoid ) {
    AvoidObstacles(othersToAvoid,MIN_BADGUY_AVOID_DIST,MAX_BADGUY_VELOCITY,MAX_BADGUY_FORCE);
  }

  void Show () {
    pushMatrix();
      translate(pos.x,pos.y);
      stroke(255);
      fill(clr);
      rotate(vel.heading());
      arc(0,0,radius,radius,MOUTH_START-mouthSize,MOUTH_STOP+mouthSize,PIE); 
      mouthSize += mouthIncrement;
      if ( mouthSize >= MOUTH_START || mouthSize <= 0 )
        mouthIncrement *= -1;
      if ( SHOW_VECTORS ) {
        stroke(clr);
        noFill();
        if ( withinRadius ) {
          ellipse(0,0,MIN_FLEE_DISTANCE*2,MIN_FLEE_DISTANCE*2);
          withinRadius = false;
        }
        if ( withinSeparation ) {
          ellipse(0,0,MIN_BADGUY_SEPARATION_DIST*2,MIN_BADGUY_SEPARATION_DIST*2);
          withinSeparation = false;
        }
      }
    popMatrix();
  }
}