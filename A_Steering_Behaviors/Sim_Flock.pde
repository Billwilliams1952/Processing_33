
public class FlockingSim extends Simulation {
  static final int MAX_VEHICLES = 500;
  
  FlockingSim ( PApplet p ) {
    this.p = p;
    CreatePanel();
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
          thisControlPanel.SetRelativeValue(11,event.getCount()*10);
        else
          super.mouseEvent(event);
        break;
      case MouseEvent.ENTER:
        break;
      case MouseEvent.EXIT:
        break;
    }
  }
  
  public void keyEvent ( KeyEvent event ) { }
  
  void CreatePanel () {
  }
  
  void Resize() {
  }
  
  void Run () {
    background(0);
    UpdateObstaclesAndBadguys();
  }
}