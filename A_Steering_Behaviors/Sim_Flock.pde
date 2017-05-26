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

public class FlockingSim extends Simulation {
  static final int MAX_FLOCKING_SIZE = 1000;
  
  ArrayList<Mover>  flockers;
  
  FlockingSim ( PApplet p ) {
    this.p = p;
    flockers = new ArrayList<Mover>();
    CreatePanel();
    CreateFlockers();
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
  
  public void keyEvent ( KeyEvent event ) { }
  
  void CreatePanel () {
    thisControlPanel = new Panel("Flocking", new PVector(250,0), 400, 230, 
                color(0,0,255,100)); //color(255,130,190,150)); 
  
    float size = thisControlPanel.AddScrollbar ( 1, "Flock Size", 0, 
      MAX_FLOCKING_SIZE, 5, 0, 150);
    thisControlPanel.SetValue(1,300,0);
    thisControlPanel.SetHint(1,increaseSizeHint); 
  
    color c = color(255,255,0);
    thisControlPanel.AddTextString (100, "Look Radius", 40, size+10, c,14 );
    thisControlPanel.AddTextString (101, "Velocity", 160, size+10, c,14 );
    thisControlPanel.AddTextString (102, "Force", 300, size+10, c,14 );
    float loc = size + 30;
    int w = 120, pad = 5;
    thisControlPanel.AddScrollbar(2,"Separation", 0, 200 , pad, loc, w);
    thisControlPanel.SetValue(2,Mover.MIN_SEPARATION_DISTANCE,0);
    thisControlPanel.SetHint(2,"Adjust Separation look radius");
    thisControlPanel.AddScrollbar ( 3, "Separation", 1, 15, w + 2*pad, loc, w);
    thisControlPanel.SetValue(3,Mover.MAX_SEPARATION_VELOCITY,1); 
    thisControlPanel.SetHint(3,"Adjust Separation maximum velocity");
    thisControlPanel.AddScrollbar ( 4, "Separation", 0, 3, 2*w + 4*pad, loc, w);
    thisControlPanel.SetValue(4,Mover.MAX_SEPARATION_FORCE,2); 
    thisControlPanel.SetHint(4,"Adjust Separation maximum force");
    
    thisControlPanel.AddScrollbar(5,"Alignment", 0, 200 , pad, loc+size, w);
    thisControlPanel.SetValue(5,Mover.MAX_ALIGNMENT_DISTANCE,0); 
    thisControlPanel.SetHint(5,"Adjust Alignment look radius");
    thisControlPanel.AddScrollbar ( 6, "Alignment", 1, 15, w + 2*pad, loc+size, w);
    thisControlPanel.SetValue(6,Mover.MAX_ALIGNMENT_VELOCITY,1); 
    thisControlPanel.SetHint(6,"Adjust Alignment maximum velocity");
    thisControlPanel.AddScrollbar ( 7, "Alignment", 0, 3, 2*w + 4*pad, loc+size, w);
    thisControlPanel.SetValue(7,Mover.MAX_ALIGNMENT_FORCE,2);
    thisControlPanel.SetHint(7,"Adjust Alignment maximum force");
    
    thisControlPanel.AddScrollbar(8,"Cohesion", 0, 200 , pad, loc+2*size, w);
    thisControlPanel.SetValue(8,Mover.MAX_COHESION_DISTANCE,0);  
    thisControlPanel.SetHint(8,"Adjust Cohesion look radius");
    thisControlPanel.AddScrollbar ( 9, "Cohesion", 1, 15, w + 2*pad, loc+2*size, w);
    thisControlPanel.SetValue(9,Mover.MAX_COHESION_VELOCITY,1);
    thisControlPanel.SetHint(9,"Adjust Cohesion maximum velocity");
    thisControlPanel.AddScrollbar ( 10, "Cohesion", 0, 3, 2*w + 4*pad, loc+2*size, w);
    thisControlPanel.SetValue(10,Mover.MAX_COHESION_FORCE,2); 
    thisControlPanel.SetHint(10,"Adjust Cohesion maximum force");    
  }
  
  void CreateFlockers () {
    int count = flockers.size(),
        scrollbarCount = thisControlPanel.GetIntegerValue(1);
    if (  count != scrollbarCount ) {
      if ( count < scrollbarCount ) {
        for ( int i = 0; i < scrollbarCount - count; i++ )
          flockers.add(new Mover(5,color(0,255,255,150))); 
      } else {
        for ( int i = 0; i < count - scrollbarCount; i++ )
          flockers.remove(0);    // .removeRange NOT visible !
      }
    }
  }
  
  void Resize() {
  }
  
  void Run () {
    background(0);
    Title("Flocking",color(255,255,255,100));
    
    UpdateObstaclesAndBadguys();
    CreateFlockers ();
    
    for ( Mover flocker : flockers ) {
      flocker.Separation(flockers,thisControlPanel.GetValue(2),
                thisControlPanel.GetValue(3), thisControlPanel.GetValue(4));
      flocker.Alignment(flockers,thisControlPanel.GetValue(5),
                thisControlPanel.GetValue(6), thisControlPanel.GetValue(7));
      flocker.Cohesion(flockers,thisControlPanel.GetValue(8),
                thisControlPanel.GetValue(9), thisControlPanel.GetValue(10));
      DoObstaclesAndBadGuys ( flocker );
      flocker.Update();
      flocker.Show();
    }
  }
}