/*
    Steering Behaviors
    
    This program is free software: you can redistribute it and/or modify it under
    the terms of the GNU General Public License as published by the Free Software
    Foundation, either version 3 of the License, or (at your option) any later 
    version. This program is distributed in the hope that it will be useful, but 
    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
    FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more 
    details. You should have received a copy of the GNU General Public License 
    along with this program. If not, see http://www.gnu.org/licenses/.
    
    Bill Williams - 2017
*/

// Hack to allow me to declare static variables that I can change
abstract static class BehaviorsBase {
  static protected boolean DO_UPDATES = true;
  static protected boolean SHOW_VECTORS = true;
  static public boolean drawAsPoint = false;
  
  public static void EnableUpdates ( boolean enable ) { DO_UPDATES = enable; }
  public static void EnableVectors ( boolean enable ) { SHOW_VECTORS = enable; } 
}

class Mover extends BehaviorsBase {
  // Common values for all behaviors.  These can be overriden by calling the 
  // particular behavior method with the parameters.
  final static float MAX_VELOCITY = 3;
  final static float MINIMUM_VELOCITY = 3;
  final static float MIN_RADIUS = 15, MAX_RADIUS = 30;
  final static float MAX_ALIGNMENT_DISTANCE = 50;
  final static float MAX_ALIGNMENT_VELOCITY = 3;
  final static float MAX_ALIGNMENT_FORCE = 0.15;
  final static float MAX_COHESION_DISTANCE = 35;
  final static float MAX_COHESION_VELOCITY = 4;
  final static float MAX_COHESION_FORCE = 0.20;
  final static float MAX_COLLISION_VELOCITY = 10;
  final static float COLLISION_CR = 1.0;         // perfectly elastic
  final static float MIN_FLEE_DISTANCE = 100;    // Look farther out for badGuys
  final static float MAX_FLEE_VELOCITY = 6;
  final static float MAX_FLEE_FORCE = 0.8;
  final static float FLOWFIELD_LOOKAHEAD = 1;    // No real lookahead
  final static float MAX_FLOWFIELD_VELOCITY = 6;
  final static float MAX_FLOWFIELD_FORCE = 0.4;
  final static float FOLLOW_PATH_LOOK_AHEAD = 15;
  final static float FOLLOW_PATH_RADIUS = 30;
  final static float MAX_FOLLOW_PATH_VELOCITY = 6;
  final static float MAX_FOLLOW_PATH_FORCE = 0.6;
  final static float MIN_SEPARATION_DISTANCE = 35;
  final static float MAX_SEPARATION_VELOCITY = 4;
  final static float MAX_SEPARATION_FORCE = 0.25; 
  final static float AVOID_LOOK_DISTANCE = 75;
  final static float AVOID_MISS_DISTANCE = 5;
  final static float MAX_AVOID_VELOCITY = 5;
  final static float MAX_AVOID_FORCE = 0.75; 
  final static float MAX_SEEK_VELOCITY = 3;
  final static float MAX_SEEK_FORCE = 0.2;
  final static float PURSUE_LOOK_DISTANCE = 200;
  final static float MAX_PURSUE_VELOCITY = 3;
  final static float MAX_PURSUE_FORCE = 0.2; 
  final static float MAX_ARRIVE_DISTANCE = 75;
  final static float MAX_ARRIVE_VELOCITY = 4;
  final static float MAX_ARRIVE_FORCE = 0.2; 
  final static float MAX_WANDER_VELOCITY = 6;
  final static float MAX_WANDER_FORCE = 0.4; 
  
  PVector pos;
  PVector vel;
  PVector acc;
  float   radius; 
  float   mass;
  boolean useMass = false, withinRadius = false, withinSeparation = false,
          collide = false;
  color   clr;        // What color is this object??
  float   noiseOff = 0.1, noiseInc = 0.005;    // Used by Perlin Noise in Wander
  Panel   controlPanel;
  
  Mover (color clr) {
    this(floor(random(MIN_RADIUS,MAX_RADIUS)),clr);
  }

  Mover ( float radius, color clr ) {
    this.clr = clr;
    this.radius = radius;
    pos = new PVector(floor(random(width)),floor(random(height)));
    vel = new PVector(random(-1.5,1.5),random(-1.5,1.5));
    acc = new PVector(0,0);  
    mass = radius;
  }

void Show () {
  fill(clr);  
  if ( drawAsPoint ) {
    strokeWeight(6);
    stroke(clr);
    point(pos.x,pos.y);
    strokeWeight(1);
  } else { 
    pushMatrix();
      // Drawing vehicle and collision graphics relative to its position
      translate(pos.x,pos.y);
      rotate(vel.heading());
      stroke(255);
      beginShape();
        vertex(-radius,-radius);
        vertex(-radius,radius); 
        vertex(radius*2,0);
      endShape(CLOSE); 
    popMatrix(); 
  }
}

  void AddForce ( PVector force ) {
    if ( ! DO_UPDATES ) return;
    if ( useMass ) acc.add(force.div(mass));
    else           acc.add(force);
  }

  color SetAlpha ( color clr, int alpha ) {
    alpha &= 0xFF;    // Force 0 to 255
    return (clr & 0x00FFFFFF) | (alpha << 24);
  }
  
  void SimpleArrow ( float len ) {
    // The Try Catch is added in case you give the wrong ID to the Panel control
    // It can screw up the values of the vectors
    if ( len == Float.NaN ) return;
    try {
      beginShape();
        vertex(0,0);
        vertex(len,0);
        vertex(len-5,-3);
        vertex(len-5,3);
        vertex(len,0);
      endShape(CLOSE);
    } catch ( AssertionError e ) {}
  }
  
  void DrawForceVector ( PVector p, PVector f, float maxF, color c ) {
    if ( SHOW_VECTORS ) {
      color noAlphaClr =  SetAlpha(c,255);
      pushMatrix();
        translate(p.x,p.y);
        rotate(f.heading());
        stroke(noAlphaClr);
        fill(noAlphaClr);
        f.limit(maxF);
        SimpleArrow(map(f.mag(),0,maxF,0,50));
      popMatrix();
    }
  }
  
  void Update () {
    if ( ! DO_UPDATES ) return;
    
    vel.add(acc);  
    pos.add(vel);
    acc.set(0,0);
    Edges();
  } 
  
  void Update ( float minimumVelocity ) {
    if ( ! DO_UPDATES ) return;
    
    vel.add(acc);
    if ( vel.mag() < minimumVelocity ) vel.setMag(minimumVelocity);   
    pos.add(vel);
    acc.set(0,0);
    Edges();
  }
  
  void Edges() {
    if ( pos.x > width ) pos.x = 0;
    if ( pos.x < 0 ) pos.x = width;
    if ( pos.y > height ) pos.y = 0;
    if ( pos.y < 0 ) pos.y = height;  
  }
  
  void Edges ( boolean bounce ) {
    if ( bounce ) {
      if ( pos.x < 0 || pos.x > width )  pos.x *= -1;
      if ( pos.y < 0 || pos.y > height ) pos.y *= -1;
    } else Edges(); 
  }

  /*****************************************************************************
                        Start of the steering behaviors
                             In alphabetical order
  ******************************************************************************/

  /*
      Attempt to align yourself with the average heading of others around you within
      a look distance.
  */
  void Alignment ( ArrayList<Mover> others ) {
    Alignment ( others, MAX_ALIGNMENT_DISTANCE, MAX_ALIGNMENT_VELOCITY, 
                 MAX_ALIGNMENT_FORCE );   
  }  
  
  void Alignment ( ArrayList<Mover> others, float maxDist, float maxVelocity, 
                  float maxForce ) {
    // Include my heading in the calculation?  YES!! NO??
    PVector averageAlignmentHeadingVector = new PVector(0,0); //vel.normalize(null);
    int count = 0;
    
    for ( Mover other : others ) {
      if ( this != other && PVector.dist(other.pos,this.pos) <= maxDist ) {
        // Add the normalized vector pointing FROM pos TO other. We're finding 
        // the average heading of all other vehicles in our 'look' range.
        averageAlignmentHeadingVector.add(other.vel.normalize(null));
        count++;
      }
    }
    if ( count > 0 ) {
      PVector averageAlignmentHeadingForce = averageAlignmentHeadingVector.copy();
      // Average heading established, set the magnitude of the vector, and find
      // the steering force to go from current velocity heading to the new vector
      // heading.  I LOVE chaining methods :)
      // NOTE: Is .normalize().mult(maxVelocity) faster than .setMag(maxVelocity) ?
      averageAlignmentHeadingForce.setMag(maxVelocity).sub(this.vel).limit(maxForce);
      DrawForceVector(pos, averageAlignmentHeadingForce, maxForce, clr);
      // Apply force to steer FROM velocity vector TO averageAlignmentHeadingForce vector. 
      AddForce(averageAlignmentHeadingForce);
    }                    
  }
  
  /*
      Arrive at a target. Here the vehicle 'Seek's the target until it gets within
      the arrival radius, at which time the velocity is gradually reduced until it
      is zero at the target's position.  Identical to Seek except when close to the
      target.
  */ 
  void Arrive ( Mover target ) {
    Arrive(target.pos,MAX_ARRIVE_VELOCITY,MAX_ARRIVE_FORCE);
  }
     
  void Arrive ( PVector target ) {
    Arrive(target,MAX_ARRIVE_VELOCITY,MAX_ARRIVE_FORCE);
  }
  
  void Arrive ( Mover target, float maxVelocity, float maxForce  ) {
    Arrive(target.pos,maxVelocity,maxForce);
  }
 
  void Arrive ( PVector target, float maxVelocity, float maxForce ) {
    float dist = target.dist(pos);
    // If we are close enough, then begin slowing down until final velocity is 0 at the
    // arrival position
    //if ( dist <= MAX_ARRIVE_DISTANCE ) {
      PVector toTargetForce = PVector.sub(target,pos)      
                                     .setMag(map(dist,0,MAX_ARRIVE_DISTANCE,0,maxVelocity))
                                     .sub(vel).limit(maxForce);
      DrawForceVector(pos, toTargetForce, maxForce, clr);
      AddForce(toTargetForce);  
    //}
  }

  /*
      Avoid Obstacles. This one is a bit more complex. Instead of using Separation
      or Flee when approaching an obstacle, compute how close the Mover is to the
      Obstacle and attempt to steer around the obstacle. The Mover will not change
      its velocity vector if it is going to miss the Obstacle.  Note, this algorithm
      assumes the Obstacle is surrounded by a sphere which is used in the miss
      calculations. Caution: Scalar Projections and DOT products ahead...
  */   
  void AvoidObstacles ( ArrayList<Mover> obstacles ) {
    AvoidObstacles(obstacles,AVOID_LOOK_DISTANCE,MAX_AVOID_VELOCITY,MAX_AVOID_FORCE);
  }

  void AvoidObstacles ( ArrayList<Mover> obstacles, float avoidDistance,
                        float maxVelocity, float maxForce ) { 
    PVector thisToObstaclePos, sp;
    PVector desiredVelocity = new PVector(0,0);
    color   c = color(255);
    
    for ( Mover o : obstacles ) {
      thisToObstaclePos = PVector.sub(o.pos,this.pos); 
      if ( thisToObstaclePos.mag() <= avoidDistance + o.radius ) {
        // Calculate the scalar projection between this heading and the obstacle
        sp = this.vel.copy();
        sp.setMag(this.vel.dot(thisToObstaclePos) / this.vel.mag());
        // Check if the SP is behind us, or if we're going to miss the obstacle
        if ( PVector.dot(sp,vel) < 0 ||   // behind us
             PVector.dist(sp,thisToObstaclePos) > o.radius + radius + AVOID_MISS_DISTANCE )
          continue;   // Yes... ignore this one
        // Now calculate new target heading. Points TOWARDS the scalar projection (i.e.,
        // towards the current velocity headingt)
        PVector targetPos = PVector.sub(sp,thisToObstaclePos);
        // And set its magnitude to miss the obstacle
        targetPos.setMag(o.radius+radius+AVOID_MISS_DISTANCE);
        // Seek the new targetPos.... this gives us the desired velocity
        desiredVelocity.add(PVector.sub(targetPos,thisToObstaclePos));

        DrawForceVector ( o.pos, targetPos, maxForce, o.clr ); 
        if ( SHOW_VECTORS ) {
          c = SetAlpha(o.clr,255);
          stroke(c);
          line(pos.x,pos.y,o.pos.x,o.pos.y);
        }
      }
    }
    if ( desiredVelocity.x != 0 && desiredVelocity.y != 0 ) { 
        // seek the desired Velocity.... this gives us the force
        PVector desiredForce =  PVector.sub(desiredVelocity.setMag(maxVelocity),vel)
                                       .limit(maxForce);
        DrawForceVector ( pos, desiredForce, MAX_AVOID_FORCE, c );
        AddForce(desiredForce);
    }
  }

  /*
      Cohesion. Attempt to cohere (approach and form a group) to other's within 
      its look radius.
  */ 
  void Cohesion ( ArrayList<Mover> others ) {
    Cohesion ( others, MAX_COHESION_DISTANCE, MAX_COHESION_VELOCITY, 
                 MAX_COHESION_FORCE );   
  }  
  
  void Cohesion ( ArrayList<Mover> others, float maxDist, float maxVelocity, 
                  float maxForce ) {
    PVector centerMassVector = new PVector(0,0);
    int count = 0;
    
    for ( Mover other : others ) {
      if ( this != other && PVector.dist(other.pos,this.pos) <= maxDist ) {
        // Average the other's position vectors. We're finding the average postion
        // of all other vehicles in our 'look' range.
        centerMassVector.add(other.pos);
        count++;
      }
    } 
    if ( count > 0 ) { // In case there's no other's in range
      PVector centerMassForce = centerMassVector.copy(); 
      // Get heading FROM pos TO center of other's positions
      centerMassForce = PVector.sub(centerMassForce.div(count),pos);
      // Center mass heading established, set the magnitude of the centerMassForce 
      // vector, and find the steering force to go from current velocity heading
      // to centerMassVector heading.
      // NOTE: Is .normalize().mult(maxVelocity) faster than .setMag(maxVelocity) ?
      centerMassForce.setMag(maxVelocity).sub(this.vel).limit(maxForce);
      DrawForceVector ( pos, centerMassForce, maxForce, color(255,255,0) );
      // Apply force to steer FROM velocity vector TO centerMassForce vector. 
      AddForce(centerMassForce);
    }
  }
  
  /*
      Simple collisions. 
      The Coeficient of Restitution determines how elastic the collision. A
      value of 1 is perfectly elastic (no energy loss). A value of 0 is a 
      perfectly inelastic collision.
      This algorithm assumes a circular radius of the objects for collision
      detection. Anything else is not calculated correctly.
  */
  void Collision ( ArrayList<Mover> others ) {
    Collision ( others, MAX_COLLISION_VELOCITY, COLLISION_CR );
  }
  
  void Collision ( ArrayList<Mover> others, float maxVelocity, float Cr ) {
    for ( Mover other : others ) {
      if ( this == other ) continue; 
      float len = PVector.dist(pos,other.pos);
      if ( len > radius + other.radius ) continue;   // no collision
      collide = true; other.collide = true;
      PVector collisionVector = PVector.sub(other.pos,pos).normalize();
      // We need to adjust the positions of this and other to make sure they
      // are NOT inside each other. Find how deep they are, then using the 
      // collisionVector create an offset position vector for the two objects.
      float offset = ceil((radius + other.radius - len) / 2.0);  
      if ( offset < 1 ) offset = 1;
      // Now move this and other AWAY from each other by offset.
      PVector posOffset = collisionVector.copy();    // normalized vector
      other.pos.add(posOffset.mult(offset));
      pos.add(posOffset.mult(-1));            // Offset in opposite direction

      // Now get the dot product with velocity.  This will give the velocity
      // amount that is normal to the collision vector.
      // TODO: Check the vector math here.
      float thisVelInitial = vel.dot(collisionVector);
      float otherVelInitial = other.vel.dot(collisionVector);
      
      // Collision - Cr is the Coefficient of Restitution.
      // Thanks https://en.wikipedia.org/wiki/Inelastic_collision
      // Cr = 1, perfectly elastic collision (no kinetic energy loss) to a 
      // Cr = 0, perfectly inelastic collision
      float thisVelFinal = ( Cr * other.mass * (otherVelInitial - thisVelInitial) +
                             mass * thisVelInitial + other.mass * otherVelInitial )
                             / (mass + other.mass);
      
      float otherVelFinal = ( Cr * mass * (thisVelInitial - otherVelInitial ) +
                             mass * thisVelInitial + other.mass * otherVelInitial )
                             / (mass + other.mass);
      // Already normalized - so we can just multiply
      vel.add(collisionVector.copy().mult(thisVelFinal-thisVelInitial))
         .limit(maxVelocity);
      other.vel.add(collisionVector.mult(otherVelFinal-otherVelInitial))
               .limit(maxVelocity);
    }
  }  
  
  /*
      Evade a pursuer.
  */  
  void Evade ( Mover target ) {
    Evade(target.pos,MAX_SEEK_VELOCITY,MAX_SEEK_FORCE,target.clr);
  } 
  
  void Evade ( PVector target, float maxVelocity, float maxForce, color c ) {
    // Calculate target's future position based on the Mover's and target's 
    // velocity vector. Note the future position should decrease the closer the 
    // Mover is to the target.
  }
 
  /*
      Flee.  This is identical to Seek except the force vector points AWAY from
      the badGuy. The force is generally higher too.
  */ 
  void Flee ( ArrayList<Mover> badGuys ) {
    Flee(badGuys,MIN_FLEE_DISTANCE,MAX_FLEE_VELOCITY, MAX_FLEE_FORCE );
  } 
  
  void Flee ( ArrayList<Mover> badGuys, float minDist, float maxVelocity, float maxForce ) {
    PVector fleeForce = FindSeparationOrFleeVector ( badGuys, minDist, maxVelocity, maxForce );
    if ( fleeForce.x != 0 && fleeForce.y != 0 ) {
      AddForce(fleeForce);
      DrawForceVector ( pos, fleeForce, maxForce, badGuys.get(0).clr );
    }
  } 
  
  /*
     The generic Flocking algorithm. Note, that to fully control each behavior, the
     programmer should call each of the three individual behaviors separately, each 
     with their own parameters - perhaps controlled by sliders.
  */
  void Flock ( ArrayList<Mover> others ) {
    Separation(others);
    Cohesion(others);
    Alignment(others);
  } 
  
  /*
     Follow a flow field. The field consists of an N x M array of heading vectors
     (normalized velocity vectors).
     The algorithm looks ahead some amount (based on its velocity heading) and 
     maps that future position into the field array to obtain the new heading
     fieldVelocity. The force is computed using PVector.sub(fieldVelocity,this.vel) 
     and applied to the Mover.
  */
  void FollowFlowField ( FlowFieldSim fieldSim ) {
    FollowFlowField ( fieldSim, FLOWFIELD_LOOKAHEAD, MAX_FLOWFIELD_VELOCITY, MAX_FLOWFIELD_FORCE );
  }   

  void FollowFlowField ( FlowFieldSim fieldSim, float lookDist, float maxVelocity, float maxForce ) {
    // Follow a flow field. First determine a lookAhead amount based on velocity
    // heading. Set its magnitude, then seek the heading. 
    PVector lookAhead = PVector.add(pos,vel.copy().setMag(lookDist));
    PVector flowHeading = fieldSim.MapPosToField(lookAhead);
    FollowFlowField ( flowHeading, lookAhead, maxVelocity, maxForce );
  } 
   
  void FollowFlowField ( PVector[][] field, int numCols, int numRows, 
                         int fieldCellSize ) {
    FollowFlowField ( field, numCols, numRows, fieldCellSize, FLOWFIELD_LOOKAHEAD, 
                      MAX_FLOWFIELD_VELOCITY, MAX_FLOWFIELD_FORCE );
  }  
  
  // Version where you pass an array row by col of field vectors
  void FollowFlowField ( PVector[][] field, int numCols, int numRows, 
                         int fieldCellSize, float lookDist, float maxVelocity, 
                         float maxForce ) {
    // TODO: Implement this
    PVector lookAhead = PVector.add(pos,vel.copy().setMag(lookDist));
    int col = constrain(floor(lookAhead.x/fieldCellSize),0,numCols-1);
    int row = constrain(floor(lookAhead.y/fieldCellSize),0,numRows-1);
    PVector flowHeading = field[col][row].copy();
    FollowFlowField ( flowHeading, lookAhead, maxVelocity, maxForce );
  } 
  
  void FollowFlowField ( PVector fieldHeading, PVector lookAhead, 
                         float maxVelocity, float maxForce ) {
    PVector flowHeading = fieldHeading.setMag(maxVelocity);
    flowHeading.sub(vel).limit(maxForce);    // Seek flowHeading from current vel
    AddForce(flowHeading);
    DrawForceVector(pos,flowHeading, maxForce, color(255));
    if ( SHOW_VECTORS ) {    // Is this needed ?????
      stroke(255);
      noFill();
      rect(lookAhead.x,lookAhead.y,5,5);
    }                          
  }
  
  /*
     Follow a path.
  */
  void FollowPath ( PathToFollow followPath ) {
    FollowPath ( followPath, FOLLOW_PATH_LOOK_AHEAD, FOLLOW_PATH_RADIUS,
                    MAX_FOLLOW_PATH_VELOCITY, MAX_FOLLOW_PATH_FORCE );
  }

  void FollowPath ( PathToFollow followPath, float lookAhead, float pathRadius,
                    float maxVelocity, float maxForce ) {
    PathLeg bestLeg = null;    // In case pathLegs is empty
    // Fix this up... we don't need all of these if we're going to display
    // the vectors in this method. 
    // TODO: Reorganize this. A method to calculate the SP should be common.
    //
    PVector path, vehiclePosRelativeToPath, lookAheadVector, lookAheadPos,
            scalarProjection, pathStart, seekPoint, desiredVelocity,
            requiredForce;
    float len;
    float minLength = 1000000.0;
    
    for ( PathLeg leg : followPath.pathLegs ) {
      path = leg.vector;
      // Create a vector pointing FROM leg.start TO pos 
      vehiclePosRelativeToPath = PVector.sub(pos,leg.start);
      
      lookAheadVector = PVector.mult(vel,lookAhead);
      lookAheadPos = PVector.add(vehiclePosRelativeToPath,lookAheadVector);
      
      scalarProjection = path.copy();
      scalarProjection.setMag(lookAheadPos.dot(path) / leg.len); 
      if ( scalarProjection.mag() > leg.len )       // ignore anything past end
        continue;
      if ( PVector.dot(scalarProjection,leg.vector) < 0 ) {  // Must be going the other way
        scalarProjection.mult(-1);                           // so reverse it
      }
      len = PVector.dist(scalarProjection,lookAheadPos);
      if ( len < minLength ) {
        minLength = len;
        bestLeg = leg;
      }   
    }
  
    // Should NEVER get a null unless paths is empty
    if ( bestLeg == null ) return;
 
    pathStart = bestLeg.start.copy();
    path = bestLeg.vector.copy();
    vehiclePosRelativeToPath = PVector.sub(pos,pathStart);
    lookAheadVector = PVector.mult(vel,lookAhead);         
    
    // create scalar projection
    lookAheadPos = PVector.add(vehiclePosRelativeToPath,lookAheadVector);
    scalarProjection = path.copy()
                           .setMag(lookAheadPos.dot(path) / bestLeg.len);
    if ( PVector.dot(scalarProjection,path) < 0 )
      scalarProjection.mult(-1);
    
    seekPoint = new PVector(0,0);
    if ( PVector.dist(scalarProjection,lookAheadPos) <= pathRadius ) {
      // Nothing to do. We are inside path, so no adjustment necessary
      withinRadius = true;
    } else {
      withinRadius = false;
      // to draw the target circle on the path
      seekPoint = scalarProjection.copy()
                                  .setMag(seekPoint.mag() + lookAhead);        
      // To change position requires a velocity
      desiredVelocity = PVector.sub(seekPoint,vehiclePosRelativeToPath)
                               .setMag(maxVelocity);
      // To change velocity requires an acceleration. 
      // Apply a force to change the acceleration. If F = ma, and m = 1 then F = a 
      requiredForce = PVector.sub(desiredVelocity,vel).limit(maxForce);
      DrawForceVector(pos,requiredForce, maxForce, color(255,255,0));
      AddForce(requiredForce);   // a mass of 1 is assumed. 
    }
  }

  /*
      Pursue a target.
  */  
  void Pursue ( Mover target ) {
    Pursue(target,PURSUE_LOOK_DISTANCE,MAX_PURSUE_VELOCITY,MAX_PURSUE_FORCE);
  } 
  
  void Pursue ( Mover target, float lookDist, float maxVelocity, float maxForce ) {
    // Calculate target's future position based on the Mover's and target's 
    // velocity vector. Note the future position should decrease the closer the 
    // Mover is to the target.
    PVector targetFuturePos = target.pos.copy();
    PVector currentVel = vel.copy();        // Use my velocity
    float len = PVector.dist(target.pos,pos);
    if ( len > lookDist ) len = lookDist;
    targetFuturePos.add(currentVel.normalize().setMag(len));
    PVector desiredForce = PVector.sub(targetFuturePos,pos).setMag(maxVelocity)
                                  .sub(vel).limit(maxForce);
    AddForce(desiredForce); 
    DrawForceVector(pos,desiredForce, maxForce, target.clr);

    if ( SHOW_VECTORS ) {
      //pushMatrix();
        stroke(target.clr);
        line(pos.x,pos.y,targetFuturePos.x,targetFuturePos.y);
      //popMatrix();
    }
  }

  /*
      Seek a target.  This is a direct path to the target at each update. A better
      approach is TBD. The calculated force vector points TOWARDS the target.
  */  
  void Seek ( Mover target ) {
    Seek(target.pos,MAX_SEEK_VELOCITY,MAX_SEEK_FORCE,target.clr);
  }
  
  void Seek ( PVector target ) {
    Seek(target,MAX_SEEK_VELOCITY,MAX_SEEK_FORCE, color(255,255,0,150));
  }
  
  void Seek ( Mover  target, float maxVelocity, float maxForce ) {
    Seek(target.pos,maxVelocity,maxForce,target.clr);
  }
  
  void Seek ( PVector target, float maxVelocity, float maxForce, color clr ) {
    PVector toTarget = PVector.sub(target,pos).setMag(maxVelocity).sub(vel).limit(maxForce);
    DrawForceVector ( pos, toTarget, maxForce, clr );    
    AddForce(toTarget);     
  }

  /*
      Separation.  Attempt to maintain a minimum distance from other Mover's within
      the Spearation distance radius.
  */ 
  void Separation ( ArrayList<Mover> othersToAvoid ) {
    Separation ( othersToAvoid, MIN_SEPARATION_DISTANCE, MAX_SEPARATION_VELOCITY, 
                 MAX_SEPARATION_FORCE );   
  }
  
  void Separation ( ArrayList<Mover> othersToAvoid, float minDist, float maxVelocity, 
                    float maxForce ) {
    PVector separationForce = FindSeparationOrFleeVector ( othersToAvoid, minDist, 
                                                   maxVelocity, maxForce );
    if ( separationForce.x != 0 && separationForce.y != 0 ) {
      DrawForceVector ( pos, separationForce, maxForce, othersToAvoid.get(0).clr );    
      AddForce(separationForce); 
    }
  }
  
  /*
      Wander. Randomly wander about the scene. Uses Perlin noise.
  */  
  void Wander ( ) {
    Wander(MAX_WANDER_VELOCITY,MAX_WANDER_FORCE);
  } 
  
  void Wander ( float maxVelocity, float maxForce ) {
    // Randomly wander about the scene. Uses Perlin noise.
    PVector newVel = PVector.fromAngle(map(noise(noiseOff),0,1,0,TWO_PI))
                            .setMag(maxVelocity);
    AddForce(PVector.sub(newVel,vel).limit(maxForce));
    vel.setMag(maxVelocity); //constrain(vel.mag(),maxVelocity,maxVelocity));
    noiseOff += noiseInc;
  }
  
  PVector FindSeparationOrFleeVector ( ArrayList<Mover> others, 
                                       float radius, float maxVelocity, float maxForce ) {
    PVector separationOrFleeHeading = new PVector(0,0);
    float   len;
    
    for ( Mover other : others ) {
      len = PVector.dist(other.pos,this.pos);
      if ( this != other && len <= radius ) {
        // Add the vector pointing FROM other TO pos. This will cause the vehicle
        // to move away from the other. Set the magnitude based on 1/distance. 
        // That way others that are closer affect the final heading more than more 
        // distance others.
        // Note, by first normalizing, we effectively divide by 1 / (len*r)
        if ( this.getClass() == other.getClass() )
          other.withinSeparation = true;
        else
          other.withinRadius = true;
        separationOrFleeHeading.add(PVector.sub(this.pos,other.pos).normalize().div(len));
      }
    }
    if ( separationOrFleeHeading.x == 0 && separationOrFleeHeading.y == 0 )
      return separationOrFleeHeading;    // 0 - no force added
    // Heading established, set the magnitude of the separationOrFleeHeading vector, 
    // subtract velocity and limit the resultant force.
    // This applies a force to steer FROM velocity vector TO separationOrFleeHeading vector. 
    return separationOrFleeHeading.setMag(maxVelocity).sub(this.vel).limit(maxForce);
  }
}