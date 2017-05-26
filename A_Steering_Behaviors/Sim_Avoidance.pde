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

public class AvoidanceSim extends Simulation {
  Target  target;
  ArrayList<Mover>  avoiders;
  float   transparancy1 = 255, transparancy2 = 0, tint = 0.25 / 2.0;
  
  AvoidanceSim ( PApplet p ) {
    this.p = p;
    CreatePanel();
    Resize();
    avoiders = new ArrayList<Mover>();
    UpdateNumberOfAvoiders();
    target = new Target(color(0,255,0,150));  
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
 
  public void keyEvent ( KeyEvent evt ) { }
 
  void CreatePanel() {
    thisControlPanel = new Panel("Avoidance", new PVector(250,0), 230, 375, 
                color(0,0,255,100)); //color(255,130,190,150)); 
  
    float size = thisControlPanel.AddScrollbar ( 8, "Avoidance Look Radius", 0, 
      2*Mover.AVOID_LOOK_DISTANCE, 5, 0);
    thisControlPanel.SetValue(8,Mover.AVOID_LOOK_DISTANCE,0);
    thisControlPanel.SetHint(8,"Adjust Avoidance lookahead radius");
  
    //panel.AddControl ( new HScrollbar(1,"Avoidance Max Velocity", 1, 12 , 5, 40));
    thisControlPanel.AddScrollbar(1,"Avoidance Max Velocity", 1, 12 , 5, size);
    thisControlPanel.SetValue(1,Mover.MAX_AVOID_VELOCITY,1); 
    thisControlPanel.SetHint(1,"Adjust Avoidance maximum velocity");
  
    thisControlPanel.AddScrollbar ( 3, "Avoidance Force", 0, 2, 5, 2 * size);
    thisControlPanel.SetValue(3,Mover.MAX_AVOID_FORCE); 
    thisControlPanel.SetHint(3,"Adjust Avoidance maximum force");
    
    thisControlPanel.AddScrollbar ( 2, "Separation Force", 0, 2, 5, 3 * size);
    thisControlPanel.SetValue(2,Mover.MAX_SEPARATION_FORCE);
    thisControlPanel.SetHint(2,"Adjust Separation maximum force");
    
    float off = 4 * size + 5;
    thisControlPanel.AddButton(4,"Track OFF/Track Target/Track Mouse",5,off,color(0,255,255),color(255,255,150));
    thisControlPanel.SetValue(4,1);
    thisControlPanel.SetHint(4,"Toggle tracking mode");

    off += 30;
    thisControlPanel.AddScrollbar ( 11, "Number of Avoiders", 1, 500 , 5, off);
    thisControlPanel.SetValue(11,200,0);
    thisControlPanel.SetHint(11,increaseSizeHint);
  }
  
  void Resize () {
    // Anything to do here?
  }
  
  void UpdateNumberOfAvoiders () {
    int vehicleCount = avoiders.size(),
        scrollbarCount = thisControlPanel.GetIntegerValue(11);
    if (  vehicleCount != scrollbarCount ) {
      if ( vehicleCount < scrollbarCount ) {
        for ( int i = 0; i < scrollbarCount - vehicleCount; i++ )
          avoiders.add(new Avoider(5,color(199,21,133,150),thisControlPanel.GetChild(8))); 
      } else {
        for ( int i = 0; i < vehicleCount - scrollbarCount; i++ )
          avoiders.remove(0);    // .removeRange NOT visible !
      }
    }
  }
  
  void Run () {
    background(0);
    Title("Seek / Pursue / Avoid / Flee",color(255,255,255,100));
    
    // Slowly fade out one background while fading in another background
    // Make this framerate independent.... specify a fadeTime
    //if ( ! inWork ) {
    //  transparancy1 -= tint;
    //  transparancy2 += tint;
    //  if ( transparancy1 >= 255 || transparancy1 <= 0 )
    //    tint *= -1;
    //  tint(255,transparancy1);
    //  image(background1,0,0);
    //  tint(255,transparancy2);
    //  //flowField.Resize(false);
    //  image(background2,0,0); 
    //} else {
    //  background(0);
    //}
    
    UpdateObstaclesAndBadguys();
    UpdateNumberOfAvoiders();
        
    target.Update();
    target.Show();
    
    for ( Mover avoider : avoiders ) {
      avoider.Separation(avoiders,Mover.MIN_SEPARATION_DISTANCE, 
                         Mover.MAX_SEPARATION_VELOCITY, 
                         thisControlPanel.GetValue(2));
      target.follow = thisControlPanel.GetIntegerValue(4);
      if ( target.follow != Target.TARGET_FOLLOW_NONE ) {
        // Change the MAX_AVOID_VELOCITY and MAX_AVOID_FORCE
        avoider.Pursue(target);
      } else {
        avoider.Cohesion(avoiders);
        avoider.Alignment(avoiders);
      }
      if ( simulationPanel.GetBooleanValue(50) )
        avoider.AvoidObstacles(obstacles,thisControlPanel.GetValue(8),
                             thisControlPanel.GetValue(1),thisControlPanel.GetValue(3));
      if ( simulationPanel.GetBooleanValue(60) )
        avoider.Flee(badGuys);
      avoider.Update();
      avoider.Show();
    }
  }
}