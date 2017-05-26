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

import java.awt.event.KeyEvent; 

/*
    The main simulations 
*/
FlowFieldSim       flowFieldSim;
AvoidanceSim       avoidanceSim;
PathFollowerSim    pathFollowerSim; 
CollisionSim       collisionSim;
FlockingSim        flockingSim;

// The currently active simulation
Simulation         currentSimulation = null; 

// 
Panel              simulationPanel, statusPanel, keyboardShortcutPanel;

/*
    Common variables for the main loop
*/
int                lastWidth, lastHeight;
boolean            shiftKey = false, altKey = false, controlKey = false;
boolean            singleStep = false, doSingleStep = false;
String             hintMessage = "";

void setup () {
  size(1280,1024,FX2D);      // P2D or FX2D. FX2D clip() / noClip() not supported yet
  hint(ENABLE_KEY_REPEAT);   // Problem with registerMethod("keyPress")  AFU
  
  lastWidth = width; lastHeight = height;
   //surface.setResizable(true);
    
  //thread("LoadBackgroundImagesThread");

  //                 !!!! MUST CALL THIS !!!!
  // Use this function to create fonts for your application. Reference the
  // font using BasePanel.font or BasePanel.fontBold
  BasePanel.CreatePanelFonts(this,"arial.ttf","arialbd.ttf");

  //keyboardShortcutPanel = new Panel(this, "Keyboard Shortcuts", new PVector(20,20), 230, 300, 
  //            color(0,0,255,100)); //color(255,130,190,150)); 
  
  CreateSimulationPanel();
  CreateStatusPanel ();
  
  /*
      Create the simulation objects and assign the flowFieldSim as the
      active one.
  */
  avoidanceSim = new AvoidanceSim(this);
  pathFollowerSim = new PathFollowerSim(this);
  flockingSim = new FlockingSim(this);
  flowFieldSim = new FlowFieldSim(this,FlowFieldSim.CELL_SIZE);  
  collisionSim = new CollisionSim(this);
  
  currentSimulation = flockingSim;
  currentSimulation.Activate(true);
}

/*
    The main simulation panel.  This panel allow the user to move from simulation 
    to simulation.
*/
void CreateSimulationPanel () {
  simulationPanel = new Panel("Run Simulations", new PVector(0,0), 300, 375, 
                              color(0,0,255,100));
  
  float size = simulationPanel.AddScrollbar ( 1, "Number of Obstacles", 0, 300 , 110, 0, 180);
  simulationPanel.SetValue(1,50,0);
  simulationPanel.SetHint(1,"Ctrl+" + BaseSimulation.increaseSizeHint); //MouseWheel increase/decrease");
  simulationPanel.AddButton(50,"Disabled/Enabled",
                          5,5,color(0,255,255),color(255,255,150));
  simulationPanel.SetBooleanValue(50,true);
  String msg = "Toggle display and reaction with ";
  simulationPanel.SetHint(50,msg+"Obstacles");
  
  simulationPanel.AddScrollbar ( 2, "Number of Badguys", 0, 50 , 110, size, 180);
  simulationPanel.SetValue(2,10,0);
  simulationPanel.SetHint(2,"Alt+" + BaseSimulation.increaseSizeHint);
  simulationPanel.AddButton(60,"Disabled/Enabled",
                          5,size+5,color(0,255,255),color(255,255,150));
  simulationPanel.SetBooleanValue(60,true); 
  simulationPanel.SetHint(60,msg+"BadGuys");
  
  float off = 2 * size + 10;
  simulationPanel.AddButton(6,"No Vectors/Show Vectors",5,off,color(0,255,255),color(255,255,150));
  simulationPanel.SetBooleanValue(6,false);
  simulationPanel.SetHint(6,"Toggle showing force vectors. Off is faster updates");
  
  simulationPanel.AddButton(100,"Draw Vehicles/Draw Points",
                          115,off,color(0,255,255),color(255,255,150));
  simulationPanel.SetBooleanValue(100,true);
  simulationPanel.SetHint(100,"Toggle display as Point or Vehicle. Points are faster updates");
  
  off += 30;
  simulationPanel.AddButton(110,"Run/Singlestep",5,off,color(0,255,255),color(255,255,150));
  simulationPanel.SetBooleanValue(110,false);
  simulationPanel.SetHint(110,"'S' - Toggle Singlestep mode");
  
  simulationPanel.AddButton(120,"Step/Step",
                          115,off,color(0,255,255),color(255,255,150));
  simulationPanel.SetBooleanValue(120,false);
  simulationPanel.SetHint(120,"'Spacebar' - Single step simulation");

  registerMethod("draw",simulationPanel);
}

void CreateStatusPanel () {
    statusPanel = new Panel("Run Simulations", new PVector(0,height-20), -1, 20, 
                              color(0,0,255,100));
                              
    statusPanel.AddTextString (100, "Distance", 150, -45, color(255),14 );
    //registerMethod("draw",statusPanel);
}

void draw() {
  // We want to have a singlestep function, without actually placing the system
  // in a noLoop() mode.
  singleStep = simulationPanel.GetBooleanValue(110);
  if ( ! doSingleStep ) {
    doSingleStep = simulationPanel.GetBooleanValue(120);
    simulationPanel.SetBooleanValue(120,false);
  }
  simulationPanel.Disable(120,!singleStep);
  Mover.EnableUpdates(! singleStep || (singleStep && doSingleStep));
  Mover.EnableVectors(simulationPanel.GetBooleanValue(6));
  
  // Update Obstacles and badGuys
  simulationPanel.Disable(1,!simulationPanel.GetBooleanValue(50)); 
  simulationPanel.Disable(2,!simulationPanel.GetBooleanValue(60)); 
  Mover.drawAsPoint = simulationPanel.GetBooleanValue(100);
  
  currentSimulation.Run();
  
  // This could become a panel !!!!!
  // Some info common to all simulation screens
  fill(color(0,0,255,100));
  stroke(255);
  strokeWeight(1);
  rect(0,height-20,width,height);
  fill(255);
  textAlign(LEFT);
  textFont(BasePanel.font);
  textSize(14);
  text("X: " + nf(mouseX) + " Y: " + nf(mouseY) + 
       " Framerate: " + nf(floor(frameRate)),5,height-5);
  if ( singleStep )
    text("SingleStep",200,height-5);
  textAlign(RIGHT);
  text("2017 - Bill Williams ",width,height-5);
  
  textAlign(CENTER,CENTER);
  textFont(BasePanel.fontBold);
  textSize(14);
  fill(255,255,0);
  text(hintMessage,width/2,height-10);
  hintMessage = "";
  
  doSingleStep = false;      // Make sure we stop updates if in singleStep
}

void keyPressed() {
  if ( key == CODED ) {
    if ( keyCode == CONTROL )  controlKey = true;
    if ( keyCode == SHIFT )    shiftKey = true;
    if ( keyCode == ALT )      altKey = true; 
  } else {
    char ch = char(keyCode);
    switch ( ch ) {
      case 's': case 'S':
        singleStep = ! singleStep;
        simulationPanel.ToggleBooleanValue(110);
        break;
      case ' ':
        if ( singleStep ) doSingleStep = true;
        break;
      case 'c': case 'C':
        currentSimulation.Activate(false);
        currentSimulation = collisionSim;
        currentSimulation.Activate(true);
        break;
      case 'F': case 'f':
        currentSimulation.Activate(false);
        currentSimulation = flowFieldSim;
        currentSimulation.Activate(true);
        break;
      case 'k': case 'K':
        currentSimulation.Activate(false);
        currentSimulation = flockingSim;
        currentSimulation.Activate(true);
        break;
      case 'A': case 'a':
        currentSimulation.Activate(false);
        currentSimulation = avoidanceSim;
        currentSimulation.Activate(true);
        break;
      case 'P': case 'p':
        currentSimulation.Activate(false);
        currentSimulation = pathFollowerSim;
        currentSimulation.Activate(true);
        break;
    }
  }
}

void keyReleased () {
  if ( key == CODED ) {
    if ( keyCode == CONTROL )  controlKey = false;
    if ( keyCode == SHIFT )    shiftKey = false;
    if ( keyCode == ALT )      altKey = false;
  }  
}

boolean NoSAC () { return ! shiftKey && ! altKey  && ! controlKey; }
boolean SA () { return shiftKey && altKey; }
boolean SC () { return shiftKey && controlKey; }
boolean AC () { return altKey && controlKey; }
boolean OnlyShift () { return shiftKey && ! altKey && ! controlKey; }
boolean OnlyAlt () { return altKey && !shiftKey && !controlKey; }
boolean OnlyControl () { return controlKey && !shiftKey  && !altKey; }