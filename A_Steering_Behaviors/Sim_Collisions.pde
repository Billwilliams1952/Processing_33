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

public class CollisionSim extends Simulation {
  private static final int MAX_COLLIDERS = 500;
  ArrayList<Mover>  colliders;
  float   transparancy1 = 255, transparancy2 = 0, tint = 0.25 / 2.0;
  
  CollisionSim ( PApplet p ) {
    this.p = p;
    CreatePanel();
    Resize();
    colliders = new ArrayList<Mover>();
    UpdateNumberOfColliders();
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
  
  void Activate ( boolean activate ) {
    super.Activate(activate);
    simulationPanel.SetBooleanValue(50,!activate);
    simulationPanel.SetBooleanValue(60,!activate);
    simulationPanel.Disable(50,activate);
    simulationPanel.Disable(60,activate);
    simulationPanel.Disable(100,activate);
  }
 
  public void keyEvent ( KeyEvent evt ) { }
 
  void CreatePanel() {
    thisControlPanel = new Panel("Simple Collisions", new PVector(250,0), 230, 375, 
                color(0,0,255,100)); //color(255,130,190,150)); 
  
    float size = thisControlPanel.AddScrollbar ( 1, "Number Of Colliders", 0, 
                                                 MAX_COLLIDERS, 5, 0);
    thisControlPanel.SetValue(1,100,0);
    thisControlPanel.SetHint(1,increaseSizeHint);
  
    thisControlPanel.AddScrollbar(2,"Collision Max Velocity", 1, 15 , 5, size);
    thisControlPanel.SetValue(2,Mover.MAX_COLLISION_VELOCITY,1); 
    thisControlPanel.SetHint(2,"Adjust Collision maximum velocity transferred");
  
    thisControlPanel.AddScrollbar ( 3, "Collision Restitution", 0, 1, 5, 2 * size);
    thisControlPanel.SetValue(3,Mover.COLLISION_CR,2); 
    thisControlPanel.SetHint(3,"Adjust Collision coefficient of restitution. 0 (perfectly inelastic) to 1 (perfectly elastic)");

    thisControlPanel.AddButton(10,"Disabled/Enabled",
                               5,3 * size+5,color(0,255,255),color(255,255,150));
    thisControlPanel.SetBooleanValue(10,false);
    thisControlPanel.SetHint(10,"Enable/Disable use of gravity");                            
    thisControlPanel.AddScrollbar ( 4, "Gravity", -0.1, 0.1, 110, 3 * size,105);
    thisControlPanel.SetValue(4,0,2); 
    thisControlPanel.SetHint(4,"Adjust amount of gravity");
}
  
  void Resize () {
    // Anything to do here?
  }
  
  void UpdateNumberOfColliders () {
    int colliderCount = colliders.size(),
        scrollbarCount = thisControlPanel.GetIntegerValue(1);
    if (  colliderCount != scrollbarCount ) {
      if ( colliderCount < scrollbarCount ) {
        for ( int i = 0; i < scrollbarCount - colliderCount; i++ )
          colliders.add(new Collider(random(5,30),color(255,0,0,150))); 
      } else {
        for ( int i = 0; i < colliderCount - scrollbarCount; i++ )
          colliders.remove(0);    // .removeRange NOT visible !
      }
    }
  }
  
  void Run () {
    background(0);
    Title("Simple Collisions",color(255,255,255,100));
    
    boolean useGravity = thisControlPanel.GetBooleanValue(10);
    thisControlPanel.Disable(4,!useGravity);
    
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
    
    // Override Activate to disable/enable these and the Vehicles/Points button
    //UpdateObstaclesAndBadguys();  
    UpdateNumberOfColliders();
    
    for ( Mover collider : colliders ) collider.collide = false;
    
    //float KE = 0;
    
    for ( Mover collider : colliders ) {
      collider.Collision ( colliders, thisControlPanel.GetValue(2), 
                                      thisControlPanel.GetValue(3));
      if ( useGravity )    // Add gravity if enabled
        collider.AddForce(new PVector(0,thisControlPanel.GetValue(4)));
      collider.Update();
      
      // Square the velocity !! NO - square the magnitude of the velocity
      //s.set(collider.vel.x * collider.vel.x - collider.vel.y * collider.vel.y,
      //      2*collider.vel.x * collider.vel.y);
      //KE += collider.vel.mag() * collider.vel.mag() * collider.mass / 2.0;
      
      collider.Show();
    }
    
    //println(KE);      // NOT RIGHT???????
  }
}