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

/*  
   Functions to load the background image(s) in a thread to improve response
   time.
*/

volatile boolean inWork = false;
volatile String  imageName1, imageName2;
volatile PImage  background1 = null, background2 = null;

void LoadTwoBackgroundImagesThread() {
  inWork = true;
  background1 = loadImage(imageName1);  // This is slow
  background1.resize(width,height);
  background2 = loadImage(imageName2);  // This is slow
  background2.resize(width,height);
  inWork = false;
}

void LoadOneBackgroundImageThread() {
  inWork = true;
  background1 = loadImage(imageName1);  // This is slow
  background1.resize(width,height);
  inWork = false;
}

static public class BaseSimulation {
  // These are common to all simulation pages. Only the size of the array differs
  static ArrayList<Mover>   obstacles = null;
  static ArrayList<Mover>   badGuys = null;
  
  // Common hint messages for all Simulations
  public static String increaseSizeHint = "MouseWheel to increase/decrease";
}

public abstract class Simulation extends BaseSimulation {
  protected PApplet p;    // Technically - this can be static.
  protected PImage  simBackground = null;
  protected int     lastWidth, lastHeight;     // for resizing
  public    Panel   thisControlPanel = null;
  // Must implement these in your sim class...
  abstract void     Resize();
  abstract void     Run();
  abstract void     keyEvent ( KeyEvent event );
  
  // These store the state of the simulationPanel for each simulation.
  private boolean   showVectors = false, drawAsPoints = true, 
                    enableObstacles = true, enableBadGuys = true;
  private int       obstacleCount = 50, badGuyCount = 10;

  //////// MOVE TO BASE_SIMULATION - call as part of Run() method
  //if ( lastWidth != width || lastHeight != height ) {
  //  //if ( backgroundReady ) {
  //  //  thread("LoadBackgroundImagesThread");
  //  //}
  //  lastWidth = width; lastHeight = height; 
  //  // Resize all of them??
  //  currentSimulation.Resize();
  //} 

  void CheckResize() {
  }
  
  void Title ( String s, color c ) {
    fill(c);
    textFont(BasePanel.font);
    textSize(60);
    textAlign(CENTER,TOP);
    text(s,width/2,10);
  }
  
  // Override this if necessary
  void Activate ( boolean activate ) {
    if ( activate ) {  // This simulation will be running now.
      if ( thisControlPanel != null )
        p.registerMethod("draw",thisControlPanel);
      p.registerMethod("mouseEvent",this);
      // AFU
      // If using P2D  - Immediatley closes down after calling function
      // If using FX2D - Error "keyEvent" method not found
      //p.registerMethod("keyEvent",this);
      // Restore simulationPanel state
      simulationPanel.SetBooleanValue(6,showVectors);
      simulationPanel.SetBooleanValue(100,drawAsPoints);
      simulationPanel.SetBooleanValue(50,enableObstacles);
      simulationPanel.SetValue(1,obstacleCount,0);
      simulationPanel.SetBooleanValue(60,enableBadGuys);
      simulationPanel.SetValue(2,badGuyCount,0);  
    } else {    // This simulation is stopping.
      if ( thisControlPanel != null )
        p.unregisterMethod("draw",thisControlPanel);
      p.unregisterMethod("mouseEvent",this);
      // See AFU comments above...
      //p.unregisterMethod("keyEvent",this);
      
      // Save simulationPanel state
      showVectors = simulationPanel.GetBooleanValue(6);
      drawAsPoints = simulationPanel.GetBooleanValue(100);
      enableObstacles = simulationPanel.GetBooleanValue(50);
      obstacleCount = simulationPanel.GetIntegerValue(1);
      enableBadGuys = simulationPanel.GetBooleanValue(60);
      badGuyCount = simulationPanel.GetIntegerValue(2);
    }
  }
  
  public void mouseEvent ( MouseEvent event ) {
    // Check for Ctrl+WHEEL (Obstacles) or Alt+WHEEL (BadGuys)
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
        if ( OnlyControl() )     // Obstacles....
          simulationPanel.SetRelativeValue(1,event.getCount()*5);
        else if ( OnlyAlt() )    // BadGuys....
          simulationPanel.SetRelativeValue(2,event.getCount());
        break;
      case MouseEvent.ENTER:
        break;
      case MouseEvent.EXIT:
        break;
    }    
  }
  
  void DoObstaclesAndBadGuys ( Mover mover ) {
    if ( simulationPanel.GetBooleanValue(50) )
      mover.AvoidObstacles(obstacles);
    if ( simulationPanel.GetBooleanValue(60) )
      mover.Flee(badGuys);
  }
  
  void UpdateActors ( ArrayList<Mover> actors, boolean obstacle, int ID ) {
    int count = actors.size(),
        scrollbarCount = simulationPanel.GetIntegerValue(ID);
    if (  count != scrollbarCount ) {
      if ( count < scrollbarCount )
        for ( int i = 0; i < scrollbarCount - count; i++ )
          actors.add(obstacle ? new Obstacle() : new BadGuy() ); 
      else 
        for ( int i = 0; i < count - scrollbarCount; i++ )
          actors.remove(0);    // .removeRange NOT visible !
    }
  }
  
  void UpdateObstaclesAndBadguys () {
    if ( obstacles == null )
      obstacles = new ArrayList<Mover>();
    UpdateActors(obstacles,true,1);

    if ( badGuys == null )
      badGuys = new ArrayList<Mover>();
    UpdateActors(badGuys,false,2);
    
    if ( simulationPanel.GetBooleanValue(50) ) {
      for ( Mover o : obstacles ) {
        o.Collision(obstacles);
        o.Update();
        o.Show();
      }
    }

    if ( simulationPanel.GetBooleanValue(60) ) {
      for ( Mover badGuy : badGuys ) {
        badGuy.Separation(badGuys);
        badGuy.AvoidObstacles(obstacles);
        badGuy.Update();
        badGuy.Show();
      }
    }
  }
}