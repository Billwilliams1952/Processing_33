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

public class PathFollowerSim extends Simulation {
  static final int MAX_VEHICLES = 500;
  
  MouseVehicle        mouseVehicle;
  PathToFollow        pathToFollow;
  boolean followPathEnabled = true;
  boolean showMouseVehicle = false;
  boolean enableBadGuys = false;
  PImage background;
  ArrayList<Mover>  pathFollowers;
  
  PathFollowerSim ( PApplet p ) {
    this.p = p;
    CreatePanel();
    Resize();
    mouseVehicle = new MouseVehicle();
    pathToFollow  = new PathToFollow();
    pathFollowers = new ArrayList<Mover>();
    CreatePathFollowers();
    
    if ( ! pathToFollow.LoadJSONFile() ) {
      // If there is no file... create a path
      pathToFollow.AddPoint(new PVector(100,100));
      pathToFollow.AddPoint(new PVector(width-100,100));
      pathToFollow.AddPoint(new PVector(width-100,height-300));
      pathToFollow.AddPoint(new PVector(300,height-100));
      pathToFollow.AddPoint(new PVector(500,height-500)); 
      pathToFollow.AddPoint(new PVector(200,200)); 
    }
    
    //color c = color(255,0,0,150);
    //for ( int i=1; i < 6; i++ ) {
    //  PVector pt = pathToFollow.pathPoints.get(i*10);
    //  if ( i == 3 ) {
    //    obstacles.add(new Obstacle(pt.x,pt.y-40,50,c)); 
    //    obstacles.add(new Obstacle(pt.x,pt.y+40,50,c)); 
    //  } else
    //    obstacles.add(new Obstacle(pt.x,pt.y,50,c)); 
    //} 
  }
  
  void Activate ( boolean activate ) {
    super.Activate(activate);
    if ( pathToFollow != null ) {
      if ( activate ) {    // Determine whether the panel "draw" method should be invoked
        p.registerMethod("mouseEvent",pathToFollow);
      } else {
        p.unregisterMethod("mouseEvent",pathToFollow);
      }
    }    
  }
  
  public void keyEvent ( KeyEvent event ) { }
  
  void CreatePanel() {
    thisControlPanel = new Panel("Path Follower", new PVector(250,0), 230, 375, 
            color(0,0,255,100)); //color(255,130,190,150)); 
    float size = thisControlPanel.AddScrollbar ( 1, "Number of Path Followers", 1, 
                                                 MAX_VEHICLES, 5, 0);
    thisControlPanel.SetValue(1,200,0);
    thisControlPanel.SetHint(1,increaseSizeHint); 

    thisControlPanel.AddScrollbar ( 2, "Velocity", 1, 
                                                 10, 5, size);
    thisControlPanel.SetValue(2,Mover.MAX_FOLLOW_PATH_VELOCITY,2);
    thisControlPanel.SetHint(2,"Adjust path follow maximum velocity"); 
    thisControlPanel.AddScrollbar ( 3, "Max Force", 0.1, 
                                                 5, 5, 2*size);
    thisControlPanel.SetValue(3,Mover.MAX_FOLLOW_PATH_FORCE,2);
    thisControlPanel.SetHint(3,"Adjust path follow maximum force"); 
    thisControlPanel.AddScrollbar ( 4, "Lookahead Distance", 10, 
                                                 100, 5, 3*size);
    thisControlPanel.SetValue(4,Mover.FOLLOW_PATH_LOOK_AHEAD,0);
    thisControlPanel.SetHint(4,"Adjust path follow lookahead distance"); 
    thisControlPanel.AddScrollbar ( 5, "Path Radius", 10, 
                                                 100, 5, 4*size);
    thisControlPanel.SetValue(5,Mover.FOLLOW_PATH_RADIUS,0);
    thisControlPanel.SetHint(5,"Adjust path size. While within the path, do not calculate new heading"); 
    
    thisControlPanel.AddButton(10,"Save Path/Save Path",0,200,color(0,255,255),color(255,255,150));
    thisControlPanel.SetBooleanValue(10,false);
    thisControlPanel.SetHint(10,"Save the path points to an external file");
    thisControlPanel.AddButton(20,"Load Path/Load Path",120,200,color(0,255,255),color(255,255,150));
    thisControlPanel.SetBooleanValue(20,false);
    thisControlPanel.SetHint(20,"Load the path points from an external file");
  }
  
  void Resize() {
  }
  
  void CreatePathFollowers () {
    int vehicleCount = pathFollowers.size(),
        scrollbarCount = thisControlPanel.GetIntegerValue(1);
    if (  vehicleCount != scrollbarCount ) {
      if ( vehicleCount < scrollbarCount ) {
        for ( int i = 0; i < scrollbarCount - vehicleCount; i++ )
          pathFollowers.add(new Follower(5,color(0,255,0,150))); 
      } else {
        for ( int i = 0; i < vehicleCount - scrollbarCount; i++ )
          pathFollowers.remove(0);    // .removeRange NOT visible !
      }
    }
  }
  
  // Registered method
  public void mouseEvent ( MouseEvent event ) {    
    switch (event.getAction()) {
      case MouseEvent.PRESS:
        break;
      case MouseEvent.RELEASE:
        break;
      case MouseEvent.CLICK:
        break;
      case MouseEvent.DRAG:
        break;
      case MouseEvent.MOVE:
        break;
      case MouseEvent.WHEEL:
        // +1 or -1 depending on direction
        if ( NoSAC() )
          thisControlPanel.SetRelativeValue(1,event.getCount()*10);
        else
          super.mouseEvent(event);
        break;
      case MouseEvent.ENTER:
        break;
      case MouseEvent.EXIT:
        break;
    }
  }
  
  void Run() {
    background(0);
    Title("Path Following",color(255,255,255,100));
    
    // Check Buttons
    if ( thisControlPanel.GetBooleanValue(10) ) {
      pathToFollow.SaveJSONFile();
      thisControlPanel.SetBooleanValue(10,false);
    }
    if ( thisControlPanel.GetBooleanValue(20) ) {
      pathToFollow.LoadJSONFile();
      thisControlPanel.SetBooleanValue(20,false);
    }
    
    pathToFollow.Show();    
    
    UpdateObstaclesAndBadguys();
    
    CreatePathFollowers();
    
    for ( Mover follower : pathFollowers ) {
      follower.FollowPath(pathToFollow,thisControlPanel.GetIntegerValue(4),
                          thisControlPanel.GetIntegerValue(5),
                          thisControlPanel.GetValue(2),thisControlPanel.GetValue(3));
      follower.Separation(pathFollowers);
      DoObstaclesAndBadGuys(follower);
      follower.Update();
      follower.Show();
    }
    
    if ( showMouseVehicle ) {
      mouseVehicle.FollowPath(pathToFollow);
      mouseVehicle.Update();
      mouseVehicle.Show();
    }
  }     
}

class PathLeg {
  PVector start;      // Its starting location
  PVector vector;     // magnitude / direction Pt1 to Pt2
  float   len;        // 
  
  PathLeg() { }
  
  PathLeg ( PVector p1, PVector p2 ) {
    start = p1.copy();
    vector = PVector.sub(p2,p1);
    len = vector.mag();
  } 
  
  void Show () {
    pushMatrix();
      translate(start.x,start.y);
      rotate(vector.heading());
      beginShape();
        vertex(0,0);
        vertex(len,0);
        vertex(len-5,-3);
        vertex(len-5,3);
        vertex(len,0);
      endShape(CLOSE);
    popMatrix();
  }
}

class AddLegInfo {
  PVector pt;
  int     legIndex;
  
  AddLegInfo() { legIndex = -1; }
}

public class PathToFollow {
  final static int POINT_CAPTURE_SIZE = 15;
  final static String JSONfilename = "PathPoints.json";
  
  // May not really need pathPoints... embeded in PathLeg?
  ArrayList<PVector> pathPoints;
  ArrayList<PathLeg> pathLegs;
  
  int movingPointIndex = -1;
  AddLegInfo addLegInfo = new AddLegInfo();
  
  PathToFollow () {
    pathPoints = new ArrayList<PVector>();
    pathLegs = new ArrayList<PathLeg>();
  } 

/*
 // JSON File Format for points
 {
     {
        "x": 160,   // comma needed to show another entry for point
        "y": 103
     },             // comma needed to show another point
     {
        "x": 160,
        "y": 103         
     },
     { 
                    // more x's and y's as needed
     }              // no comma on last one
   ]                // Array list complete
 }                  // file complete
*/
  boolean LoadJSONFile () {
    // If file exists... try to load it  
    // Load array "points", each having an "x" and a "y"
    File f = new File( sketchPath(JSONfilename));
    if ( f.exists() ) {
      JSONArray points = loadJSONArray(JSONfilename);
      if ( points != null ) {
        pathPoints.clear();
        for (int i = 0; i < points.size(); i++) {
          // Get each object in the array
          JSONObject pt = points.getJSONObject(i); 
          PVector pts = new PVector(pt.getInt("x"),pt.getInt("y"));
          AddPoint(pts);
        }
        return true;
      }
    }
    return false;
  }
  
  void SaveJSONFile () {  
    JSONArray points = new JSONArray();
    for ( int i=0; i < pathPoints.size(); i++ ) {
      JSONObject pt = new JSONObject();
      pt.setInt("x", floor(pathPoints.get(i).x));
      pt.setInt("y", floor(pathPoints.get(i).y));
      points.setJSONObject(i,pt);
    }
    saveJSONArray(points,JSONfilename); 
  }
   
  void AddPoint ( PVector pt ) {
    pathPoints.add(pt);
    RecalculateLegs();
  }
  
  void RecalculateLegs() {
    pathLegs.clear();  
    int numPts = pathPoints.size();
    if ( numPts > 1 ) {    // 0 or 1 is no path
      if ( numPts == 2 )
        pathLegs.add(new PathLeg(pathPoints.get(0),pathPoints.get(1)));
      else {
        for ( int i=0; i < numPts-1; i++ ) {
          pathLegs.add(new PathLeg(pathPoints.get(i),pathPoints.get(i+1)));
        }
        // wrap around for last one
        pathLegs.add(new PathLeg(pathPoints.get(numPts-1),pathPoints.get(0)));
      }
    }
  }
  
  // Registered method
  public void mouseEvent ( MouseEvent event ) {
    int x = event.getX();
    int y = event.getY();
    
    switch (event.getAction()) {
      case MouseEvent.PRESS:
        HandleMousePressed();
        break;
      case MouseEvent.RELEASE:
        HandleMouseReleased();
        break;
      case MouseEvent.CLICK:
        break;
      case MouseEvent.DRAG:
        HandleMouseDragged();
        break;
      case MouseEvent.MOVE:
        HandleMouseMoved();
        break;
      case MouseEvent.WHEEL:
        // +1 or -1 depending on direction
        break;
      case MouseEvent.ENTER:
        break;
      case MouseEvent.EXIT:
        break;
    }
  }
 
  void HandleMouseMoved() {
    // Loop though paths and determine if the distance from the mouse to any path
    // is within POINT_CAPTURE_SIZE
    PVector mouse = new PVector(mouseX,mouseY);
    PVector sp;
    PVector mousePosRelativeToLeg;
    
    addLegInfo.legIndex = -1;      // no index found
    
    for ( int i=0; i < pathLegs.size(); i++ ) {
      PathLeg leg = pathLegs.get(i);
      // get scalar projection on the mouse's position onto the leg
      mousePosRelativeToLeg = PVector.sub(mouse,leg.start);
      sp = leg.vector.copy();
      //doesn't matter which way...
      //sp.setMag(mousePosRelativeToLeg.dot(leg.vector) / leg.len); 
      sp.setMag(leg.vector.dot(mousePosRelativeToLeg) / leg.len);
      // Don't look past either end of leg
      if ( PVector.dot(sp,leg.vector) < 0 || sp.mag() > leg.len )
        continue;  
      if ( abs(PVector.dist(sp,mousePosRelativeToLeg)) < POINT_CAPTURE_SIZE && 
          OverPathPoint() == -1 ) {    // Ignore if we're actually on a point
          addLegInfo.pt = sp.copy();
          addLegInfo.legIndex = i;
          return;
      }
    }
  }
  
  void HandleMouseDragged() {
    if ( NoSAC() && movingPointIndex != -1 ) {
      pathPoints.set(movingPointIndex,new PVector(mouseX,mouseY));
      RecalculateLegs();
    }
  }
  
  void HandleMousePressed() {     
    movingPointIndex = OverPathPoint();
    
    if ( NoSAC() && (movingPointIndex != -1) )
      return;

    if ( OnlyShift() && movingPointIndex != -1 ) {
      // Delete the point
      if ( pathPoints.size() > 2 ) {
        pathPoints.remove(movingPointIndex);
        RecalculateLegs();
      }
      movingPointIndex = -1;
    }
      
    // Check if adding point
    if ( OnlyShift() && addLegInfo.legIndex != -1 ) {
      // Get current point and add scalar projection offset
      PVector pt = pathPoints.get(addLegInfo.legIndex);
      pathPoints.add(addLegInfo.legIndex+1,PVector.add(pt,addLegInfo.pt));
      RecalculateLegs();
      addLegInfo.legIndex = -1;
    }   
  }
  
  void HandleMouseReleased() {
    if ( movingPointIndex != -1 ) {
      movingPointIndex = -1;
    }
  }
  
  int OverPathPoint() {
    for ( int i=0; i < pathPoints.size(); i++ ) {
      PVector pt = pathPoints.get(i);
      if ( mouseX >= pt.x - POINT_CAPTURE_SIZE && mouseX <= pt.x + POINT_CAPTURE_SIZE &&
           mouseY >= pt.y - POINT_CAPTURE_SIZE && mouseY <= pt.y + POINT_CAPTURE_SIZE ) {
        return i;
      }
    }    
    return -1;
  }
   
  void Show () {   
    stroke(255,255,0,150);
    strokeWeight(2); 
    textSize(12);
    
    // Draw the path specified by the points
    rectMode(CORNER);
    for ( PathLeg leg : pathLegs ) {
      pushMatrix();
        noStroke();
        fill(64,64,64);
        translate(leg.start.x,leg.start.y);
        rotate(leg.vector.heading());
        float dia = Mover.FOLLOW_PATH_RADIUS * 2;
        //rect(-Mover.FOLLOW_PATH_RADIUS,-Mover.FOLLOW_PATH_RADIUS,leg.len+dia,dia);
        rect(0,-Mover.FOLLOW_PATH_RADIUS,leg.len,dia);
      popMatrix();
    }
    
    stroke(255,255,0);
    strokeWeight(2);
    fill(255,255,0);
    for ( PathLeg leg : pathLegs ) {
      leg.Show();
    }

    stroke(255);
    strokeWeight(1);
    fill(0,255,0,150);
    
    int i = OverPathPoint();
    if ( i >= 0 ) {
      rectMode(CENTER);
      PVector pt = pathPoints.get(i);
      rect(pt.x,pt.y,POINT_CAPTURE_SIZE*2,POINT_CAPTURE_SIZE*2);
      rectMode(CORNER);

     hintMessage = "Left-Drag to Move Point, Shift+Left-Click to Delete point";
    }
    
    if ( addLegInfo.legIndex != -1 ) {
      PathLeg leg = pathLegs.get(addLegInfo.legIndex);
      pushMatrix();
        translate(leg.start.x,leg.start.y);
        ellipse(addLegInfo.pt.x,addLegInfo.pt.y,15,15);
        translate(addLegInfo.pt.x,addLegInfo.pt.y+5);
        String s = "Len: " + nfc(addLegInfo.pt.mag(),1) + 
          " at " + nfc(degrees(leg.vector.heading()),1);
        float w = textWidth(s);
        float h = textAscent() + textDescent();
        noStroke();
        fill(0,0,255,150);
        rectMode(CENTER);
        rect(0,h+5,w+10,h+8);
        fill(255);
        textAlign(CENTER);
        text(s,0,h+8);
        rectMode(CORNER);
      popMatrix();
      
      hintMessage = "Shift+Left-Click to Add a New Point";
    }
  }
}