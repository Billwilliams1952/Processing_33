
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
  // These are common to all simulation pages...
  static ArrayList<Mover>   obstacles = null;
  static ArrayList<Mover>   badGuys = null;
}
// Use Interfaces here??


public abstract class Simulation extends BaseSimulation {
  protected PApplet p;    // Technically - this can be static.
  protected PImage  simBackground = null;
  protected int     lastWidth, lastHeight;     // for resizing
  public    Panel   thisControlPanel = null;
  // Must implement these in your sim class...
  abstract void     Resize();
  abstract void     Run();
  abstract void     keyEvent ( KeyEvent event );

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
  
  // Override this if necessary
  void Activate ( boolean activate ) {
    if ( activate ) {
      if ( thisControlPanel != null )
        p.registerMethod("draw",thisControlPanel);
      p.registerMethod("mouseEvent",this);
      // AFU
      // If using P2D  - Immediatley closes down after calling function
      // If using FX2D - Error "keyEvent" method not found
      //p.registerMethod("keyEvent",this);
    } else {
      if ( thisControlPanel != null )
        p.unregisterMethod("draw",thisControlPanel);
      p.unregisterMethod("mouseEvent",this);
      // See AFU comments above...
      //p.unregisterMethod("keyEvent",this);
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
  
  void UpdateObstaclesAndBadguys () {
    if ( obstacles == null )
      obstacles = new ArrayList<Mover>();
    if ( simulationPanel.GetIntegerValue(1) != obstacles.size() ) {
      obstacles.clear();
      for ( int i = 0; i < simulationPanel.GetIntegerValue(1); i ++ )
        obstacles.add(new Obstacle(floor(random(15,30)),color(255,0,0,200)));
    }

    if ( badGuys == null )
      badGuys = new ArrayList<Mover>();
    if ( simulationPanel.GetIntegerValue(2) != badGuys.size() ) {
      badGuys.clear();
      for ( int i = 0; i < simulationPanel.GetIntegerValue(2); i ++ )
        badGuys.add(new BadGuy(floor(random(20,40)),color(0,0,255,150)));  
    }
    
    for ( Mover o : obstacles ) {
      //o.Separation(obstacles);
      o.Collision(obstacles);
      o.Update();
      o.Show();
    }
  
    for ( Mover badGuy : badGuys ) {
      badGuy.Separation(badGuys);
      badGuy.AvoidObstacles(obstacles);
      badGuy.Update();
      badGuy.Show();
    }
  }
}