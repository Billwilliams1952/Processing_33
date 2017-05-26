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

public class FlowFieldSim extends Simulation { 
  final static float CELL_SIZE = 40;  
  final static float INITIAL_ACTORS = 300; 
  final static float MAX_ACTORS = 10000;   
  
  ArrayList<Mover>  flowFollowers;
  PVector[][] field;
  int         numRows, numCols, offset;
  float       cellSize,
              noiseXStart = random(2), 
              noiseYStart = random(2), 
              noiseTime = random(2),
              lastCellSize;
  
  FlowFieldSim ( PApplet p, float cellSize ) {
    this.p = p;
    CreatePanel();
    
    Resize(cellSize);
    
    // Create and allocate 'actors' for this simulation
    flowFollowers = new ArrayList<Mover>();
    CreateFlowFollowers();
    
    simBackground = loadImage("background1.jpg");  // This is slow
    simBackground.resize(width,height);
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
          thisControlPanel.SetRelativeValue(7,event.getCount()*10);
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
 
  void CreatePanel() {
    thisControlPanel = new Panel("Flow Field", new PVector(250,0), 230, 375, 
                      color(0,0,255,100)); 
    float size = thisControlPanel.AddScrollbar ( 1, "Noise Increment", 0.001, 0.5, 5, 0);
    thisControlPanel.SetValue(1,0.1,3);
    thisControlPanel.SetHint(1,"Adjust perlin noise amount - how much change in a frame");
    
    thisControlPanel.AddScrollbar ( 2, "Noise Time Increment", 0.000, 0.05, 5, size);
    thisControlPanel.SetValue(2,0.015,3);
    thisControlPanel.SetHint(2,"Adjust perlin noise time increment - how much change frame to frame");

    thisControlPanel.AddScrollbar ( 3, "Flow Force Lookahead distance", 0, 100, 5, 4*size);
    thisControlPanel.SetValue(3,Mover.FLOWFIELD_LOOKAHEAD,0);
    thisControlPanel.SetHint(3,"Adjust Flow Field lookahead distance");
    
    thisControlPanel.AddScrollbar ( 4, "Maximum Flow Velocity", 1, 10, 5, 2*size);
    thisControlPanel.SetValue(4,Mover.MAX_FLOWFIELD_VELOCITY,1);
    thisControlPanel.SetHint(4,"Adjust Flow Field maximum velocity");
    
    thisControlPanel.AddScrollbar ( 5, "Maximum Flow Force", 0.1, 2, 5, 3*size);
    thisControlPanel.SetValue(5,Mover.MAX_FLOWFIELD_FORCE,2);
    thisControlPanel.SetHint(5,"Adjust Flow Field maximum force");
    
    thisControlPanel.AddScrollbar ( 6, "Flowfield Cell Size", 10, 100, 5, 5*size);
    thisControlPanel.SetValue(6,CELL_SIZE,0);
    thisControlPanel.SetHint(6,"Adjust Flow Field cell size");
    
    thisControlPanel.AddScrollbar ( 7, "Number of Flow Followers", 1, MAX_ACTORS, 5, 6*size);
    thisControlPanel.SetValue(7,INITIAL_ACTORS,0);
    thisControlPanel.SetHint(7,increaseSizeHint); 
    
    thisControlPanel.AddButton(60,"No Separation/Separation",
                          5,7*size+10,color(0,255,255),color(255,255,150));
    thisControlPanel.SetBooleanValue(60,false);
    thisControlPanel.SetHint(60,"Toggle calculate Separation On/Off (Off is faster updates)");
    
    // Need button for Points/Vehicle and Disable Separation
  }
  
  // Call this to change flowField size
  void Resize ( float cellSize ) {
    this.cellSize = cellSize;
    lastCellSize = cellSize;
    Resize();
  }

  // Call this if screen is resized
  void Resize () {
    offset = floor(cellSize / 2);
    numRows = floor(height / cellSize);
    numCols = floor(width / cellSize);
    field = new PVector[numRows][numCols];
  }
  
  void Update ( ) {
    float angle, noiseX, noiseY;
    
    if ( lastCellSize != thisControlPanel.GetValue(6) )
      Resize(thisControlPanel.GetIntegerValue(6));    // User changed field cell size
    
    // Fill the field with Perlin noise values and draw to screen
    noiseY = noiseYStart;
    noiseTime += thisControlPanel.GetValue(2);

    for ( int row = 0, offY = offset; row < numRows; row++, offY += cellSize ) {
      noiseX = noiseXStart;    // restart each pass to ensure consistent noise fields
      for ( int col = 0, offX = offset; col < numCols; col++, offX += cellSize ) {
        angle = TWO_PI * noise(noiseX,noiseY,noiseTime);
        field[row][col] = PVector.fromAngle(angle);
        pushMatrix();
          translate(offX,offY);            // Center of cell
          rotate(angle);                   // Rotate in direction of field
          stroke(255,255,255,150);
          line(-offset+4,0,offset-4,0);    // Draw arrow body
          translate(offset-4,0);           // Move to end and
          fill(255,255,0,150);
          stroke(255,255,0,150);
          triangle(0, 0, -4, 2, -4, -2);   // Draw arrow
        popMatrix();
        noiseX += thisControlPanel.GetValue(1);
      }
      noiseY += thisControlPanel.GetValue(1);
    } 
  }
  
  PVector GetColRow ( PVector pos ) {
    return new PVector(constrain(floor(pos.x/cellSize),0,numCols-1),
                       constrain(floor(pos.y/cellSize),0,numRows-1));
  }
  
  PVector GetColRow (float x, float y ) {
    return GetColRow(new PVector(x,y));
  }
  
  // Obtain the flowField value based on screen position (pos)
  PVector MapPosToField ( PVector pos ) {
    PVector colRow = GetColRow(pos);
    return field[floor(colRow.y)][floor(colRow.x)].copy();
  }
  
  PVector MapPosToField ( float x, float y ) {
    return MapPosToField(new PVector(x,y) );
  }
  
  void SetFieldValue ( PVector pos, PVector value ) {
    PVector colRow = GetColRow(pos);
    field[floor(colRow.y)][floor(colRow.x)] = value.copy();
  }
  
  void SetFieldValue ( float x, float y, PVector value ) {
    SetFieldValue(new PVector(x,y),value); 
  }
  
  void CreateFlowFollowers () {
    int vehicleCount = flowFollowers.size(),
        scrollbarCount = thisControlPanel.GetIntegerValue(7);
    if (  vehicleCount != scrollbarCount ) {
      if ( vehicleCount < scrollbarCount ) {
        for ( int i = 0; i < scrollbarCount - vehicleCount; i++ )
          flowFollowers.add(new Mover(5,color(0,255,255,150))); 
      } else {
        for ( int i = 0; i < vehicleCount - scrollbarCount; i++ )
          flowFollowers.remove(0);    // .removeRange NOT visible !
      }
    }
  }
  
  // Update and display simulation
  public void Run () {
    // How to resize this now?????????
    //image(simBackground,0,0);
    background(0);
    Title("Flowfield",color(255,255,255,100));
    
    Update();    // Update flowField and display vectors
    
    UpdateObstaclesAndBadguys();
    CreateFlowFollowers();
    
    boolean showAsPoint = thisControlPanel.GetBooleanValue(70);
    for ( Mover flowFollower : flowFollowers ) {
      DoObstaclesAndBadGuys ( flowFollower );
      if ( thisControlPanel.GetBooleanValue(60) )
        flowFollower.Separation(flowFollowers);
      flowFollower.FollowFlowField(this,thisControlPanel.GetValue(3), 
                                        thisControlPanel.GetValue(4),
                                        thisControlPanel.GetValue(5));
      flowFollower.Update();
      //flowFollower.showAsPoint = showAsPoint
      flowFollower.Show();
    }
    
    // Highlight field cell under the mouse
    PVector colRow = GetColRow(mouseX,mouseY);
    noStroke();
    fill(0,255,0,100);
    rect(colRow.x*cellSize,colRow.y*cellSize,cellSize,cellSize); 
  }
}