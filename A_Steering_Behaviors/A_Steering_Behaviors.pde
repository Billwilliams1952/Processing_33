import java.awt.event.KeyEvent; 

Simulation         currentSimulation; 
FlowFieldSim       flowFieldSim;
AvoidanceSim       avoidanceSim;
PathFollowerSim    pathFollowerSim; 

boolean            singleStep = false, doSingleStep = false;
Panel              simulationPanel, keyboardShortcutPanel;
int                lastWidth, lastHeight;
boolean            shiftKey = false;
boolean            altKey = false;
boolean            controlKey = false;
//boolean singleStep = false;

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
  
  avoidanceSim = new AvoidanceSim(this);
  pathFollowerSim = new PathFollowerSim(this);
  flowFieldSim = new FlowFieldSim(this,FlowFieldSim.CELL_SIZE);
  currentSimulation = flowFieldSim;
  currentSimulation.Activate(true);
}

/*
    The main simulation panel.  This panel allow the user to move from simulation to
    simulation.  M<aybe it hold the generic obstacles and badGuys??
*/
void CreateSimulationPanel () {
  simulationPanel = new Panel("Run Simulations", new PVector(250,20), 230, 375, 
              color(0,0,255,100));
  float size = simulationPanel.AddScrollbar ( 1, "Number of Obstacles", 0, 300 , 5, 0);
  simulationPanel.SetValue(1,50,0);
  simulationPanel.AddScrollbar ( 2, "Number of Badguys", 0, 50 , 5, size);
  simulationPanel.SetValue(2,10,0);
  
  float off = 2 * size + 10;
  simulationPanel.AddButton(6,"No Vectors/Show Vectors",0,off,color(0,255,255),color(255,255,150));
  simulationPanel.SetBooleanValue(6,false);
  registerMethod("draw",simulationPanel);
}

void draw() {
  // We want to have a singlestep function, without actually placing the system
  // in a noLoop() mode.
  Mover.EnableUpdates(! singleStep || (singleStep && doSingleStep));
  Mover.EnableVectors(simulationPanel.GetBooleanValue(6));
  
  currentSimulation.Run();
  
  // This could become a panel !!!!!
  // Some info common to all simulation screens
  fill(135,206,250,200);
  rect(0,height-20,width,height);
  fill(0);
  textAlign(LEFT);
  textFont(BasePanel.font);
  textSize(14);
  text("X: " + nf(mouseX) + " Y: " + nf(mouseY) + 
       " Framerate: " + nf(floor(frameRate)),5,height-5);
  if ( singleStep )
    text("SingleStep",200,height-5);
  
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
        break;
      case ' ':
        if ( singleStep ) doSingleStep = true;
        break;
      case 'F': case 'f':
        currentSimulation.Activate(false);
        currentSimulation = flowFieldSim;
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