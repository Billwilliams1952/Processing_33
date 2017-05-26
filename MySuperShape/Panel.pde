
// Hack to allow me to declare static variables that I can change
public static class BasePanelControl {
  static PanelControl activePanelControl = null;
  static final  int   PADDING = 2;
  public static int   sizeOfText = 12;
  void SetGlobalFontSize ( int sizeOfText ) { BasePanelControl.sizeOfText = sizeOfText; }
}

class PanelControl extends BasePanelControl {
  protected int       ID;                       // ID of this control
  protected float     ctrlX, ctrlY, ctrlW, ctrlH;  // Location and size of control
  protected String    text;                     // text string associated with this control
  protected boolean   disabled = false;         // Is this control disabled?
  protected boolean   overControl;              // Is the mouse over this control?
  protected boolean   mousePress;               // Is the Mouse pressed while over control?
  protected float     value;                    // The current value of this control
  protected float     minValue, maxValue, lastValue, defaultValue;  // Valid values and default
  protected PVector   mousePosRelToPanel;       // Relative to panel!! 
  protected float[]   discreteValues = null;
  
  // Override everything
  PanelControl() {
  }
  
  // These may be overridden
  void SetText ( String text ) { this.text = text; }
  float GetValue () { 
    if ( discreteValues == null )
      return value;
    return discreteValues[(int)value];
  }
  int GetIntegerValue () { 
    if ( discreteValues == null )
      return (int)value;
    return (int)discreteValues[(int)value]; 
  }
  boolean GetBooleanValue () { return value > 0; }
  void SetValue ( float value ) { 
    this.value = constrain(value,minValue,maxValue); 
  }
  void SetRelativeValue ( float value ) { 
    this.value += value;
    this.value = constrain(this.value,minValue,maxValue); 
  }
  void SetBooleanValue ( boolean value ) { this.value = value ? 1 : 0; }
  void SetDefaultValue ( float value ) { defaultValue = value; }
  void ResetToDefaultValue () { value = defaultValue; }
  void SetMousePosition ( PVector childPanelPos ) {
    mousePosRelToPanel = PVector.sub(new PVector(mouseX,mouseY),childPanelPos); }
  boolean MousePressed ( ) { return mousePressed && mouseButton == LEFT; }
  boolean OverControl () {
    overControl = mousePosRelToPanel.x >= ctrlX && 
                  mousePosRelToPanel.x <= ctrlX + ctrlW &&
                  mousePosRelToPanel.y >= ctrlY && 
                  mousePosRelToPanel.y <= ctrlY + ctrlH; 
    return overControl; }
  // MUST declare
  boolean Update ( PVector panelPos ) { return false; } // ALWAYS override
  void Show () {}    // ALWAYS override
}

// Many thanks to Processing.Org for this example!
class HScrollbar extends PanelControl {
  private static final int SLIDER_HEIGHT = 18;
  private static final int SLIDER_WIDTH = 10;
  private static final int ACCEL_FACTOR = 3; 
  public  static final int DISPLAY_INT = 0x1;
  public  static final int DISPLAY_FLOAT = 0x2;
  public  float ScaleFactor = 1;
  
  private float spos, newspos;      // position of slider, and its new position
  private float sposMin, sposMax;   // max and min values of slider
  private int   numDecimals = 2;
  private float sliderStart;

  HScrollbar ( int ID, String name, float min, float max, float x, float y ) {
    this(ID,name,min,max,x,y,-1);
  }
  
  HScrollbar ( int ID, String name, float[] values,  
               float x, float y, int scrollWidth ) {
    this(ID,name,0,values.length-1,x,y,scrollWidth);
    discreteValues = values;
  }

  HScrollbar ( int ID, String name, float min, float max,  
               float x, float y, int scrollWidth ) {
    this.ID = ID;
    text = name;
    minValue = min; maxValue = max;
    ctrlX = sposMin = x;                
    ctrlY = y; // - SLIDER_HEIGHT / 2;  // Add height of text too 
    textFont(BasePanel.fontBold);
    textSize(BasePanelControl.sizeOfText);
    sliderStart = ctrlY + textAscent() + textDescent() + PADDING;
    ctrlW = scrollWidth;
    ctrlH = textAscent() + textDescent() + PADDING + ScaleFactor*SLIDER_HEIGHT;
    sposMax = ctrlX + ctrlW - ScaleFactor*SLIDER_WIDTH;
    spos = map(0.5,0,1,sposMin,sposMax);  // Default to center
  }
  
  void RecalculateRange() {
    sposMax = ctrlX + ctrlW - ScaleFactor*SLIDER_WIDTH;
    spos = map(0.5,0,1,sposMin,sposMax);  // Default to center
  }
  
  float GetSliderHeight () {
    textSize(sizeOfText);
    return textAscent() + textDescent() + 2 * PADDING + ScaleFactor*SLIDER_HEIGHT;
  }

  boolean Update ( PVector panelPos ) {
    if ( disabled ) return false;      // Nothing to see here... move on   
    SetMousePosition(panelPos);
    
    if ( OverControl() && MousePressed() ) {
      mousePress = true;
      cam.setActive(false);
    }

    if ( ! mousePressed ) {
      mousePress = false;
      cam.setActive(true);
    }

    if ( mousePress )
      newspos = constrain(mousePosRelToPanel.x-ScaleFactor*SLIDER_WIDTH/2, sposMin, sposMax);

    if ( abs(newspos - spos) > 1 )  {  
      spos += (newspos-spos) / ACCEL_FACTOR; // Nice trick to add 'acceleration'
      value = map(spos,sposMin,sposMax,minValue,maxValue);
    }   
    activePanelControl = mousePress ? this : null;
    return mousePress;
  }
      
  void SetMinMax ( float min, float max ) { minValue = min; maxValue = max; }
  
  void SetValue ( float value ) {
    super.SetValue(value);    // Constrain the value....
    spos = newspos = map(value,minValue,maxValue,sposMin,sposMax);
  }
  
  void SetRelativeValue ( float value ) {
    super.SetRelativeValue(value);    // Constrain the value....
    spos = newspos = map(this.value,minValue,maxValue,sposMin,sposMax);
  }
  
  void SetValue ( float value, int numDecimals ) { 
    this.numDecimals = numDecimals;
    SetValue(value);
  }

  void Show () {
    // Main slider bar
    if ( overControl & ! mousePress && ! disabled )
      stroke(255);
    else
      noStroke();
    fill(204);
    rect(ctrlX , sliderStart + ScaleFactor*SLIDER_HEIGHT / 2, ctrlW, ScaleFactor*4); 
    // Slider handle
    fill(mousePress && ! disabled ? color(255,255,150) : color(208,197,232));
    stroke(255);
    rect(spos, sliderStart, ScaleFactor*SLIDER_WIDTH, ScaleFactor*SLIDER_HEIGHT, 5);
    // Slider name and current value
    fill(disabled ? 150 : 255);
    textFont(BasePanel.fontBold);
    textAlign(LEFT,TOP);
    textSize(BasePanelControl.sizeOfText);
    text(text,ctrlX,ctrlY);
    textAlign(RIGHT,TOP);
    float val = discreteValues == null ? value : discreteValues[(int)value];
    if ( numDecimals == 0 )
      text(nfc(round(value)),ctrlX+ctrlW,ctrlY);
    else 
      text(nfc(value,numDecimals),ctrlX+ctrlW,ctrlY);
    textFont(BasePanel.font);
  }
}

class Button extends PanelControl {
  private static final int WIDTH = 100;
  private static final int HEIGHT = 20;
  private static final int RADIUS = 10;
  private color    normalClr, pressedClr;
  private String[] stateText;
  
  // Button fields....
  
  // Need to pass a value of the button.  0 is not pressed, 1 is pressed.
  Button ( int ID_, String text_, float x, float y, color normalClr_, color pressedClr_ ) {
    value = 0;    // e.g. OFF or first displayed value
    ID = ID_;
    // Parse out text to get the number of states for this button
    // e.g., "Track OFF/Track ON/Track Mouse" - 3 states - value = 0, 1 or 2
    //       "Reset/Reset"  2 states 0, 1 - same text for each
    // 
    stateText = text_.split("/");
    minValue = 0; maxValue = stateText.length-1;
    ctrlX = x; ctrlY = y; ctrlW = WIDTH; ctrlH = HEIGHT;
    normalClr = normalClr_; pressedClr = pressedClr_;
  }
  
  boolean Update ( PVector panelPos ) {
    if ( disabled ) return false;      // Nothing to see here... move on
    SetMousePosition(panelPos);
    
    if ( OverControl() && MousePressed() && ! mousePress ) {
      mousePress = true;
      value += 1;
      if ( value > maxValue )
        value = minValue;
      cam.setActive(false);
    }

    if ( ! mousePressed ) {
      mousePress = false;
      cam.setActive(true);
    }
     
    activePanelControl = mousePress ? this : null;
    return mousePress;
  }
  
  void Show () {
    pushMatrix();
      translate(ctrlX,ctrlY);
      if ( disabled )  fill(color(208,197,232));
      else             fill(value == 0 ? normalClr : pressedClr);
      stroke(disabled ? 150 : 255);
      strokeWeight(overControl && ! mousePressed && ! disabled ? 3 : 1);
      rect(0,0,WIDTH,HEIGHT,RADIUS);
      strokeWeight(1);
      fill(disabled ? 150 : 0);
      textFont(BasePanel.fontBold);
      textSize(BasePanelControl.sizeOfText);
      textAlign(CENTER);
      text(stateText[floor(value)],WIDTH / 2,textAscent()+textDescent());
    popMatrix();
  } 
}

class TextString extends PanelControl {
  private color   normalClr;
  private int     sizeOfText;
  
  TextString ( int ID, String text, PVector loc, color normalClr, int textSize ) {
    this.ID = ID;
    this.text = text;
    ctrlX = loc.x; ctrlY = loc.y; 
    this.normalClr = normalClr;
    sizeOfText = textSize;
    value = 0;
  }

  boolean Update ( PVector panelPos ) {
    SetMousePosition(panelPos);
    return false;
  }
  
  void Show () {
    pushMatrix();
      translate(ctrlX,ctrlY);
      fill(normalClr);
      textFont(BasePanel.fontBold);
      textSize(BasePanelControl.sizeOfText);
      textAlign(LEFT,TOP);
      text(this.text,0,0);
    popMatrix();
  }
}

public static class BasePanel {
  public static final int SHOW_ALL_PANELS = 0;
  public static final int HIDE_ALL_PANELS = 1;
  public static final int DO_NOTHING_ON_PANELS = 2;
  
  static protected Panel activePanel = null;
  // Need a way to hide/show all panels, or leave them in their current state
  public static int     showPanels = DO_NOTHING_ON_PANELS,
                        DEFAULT_FONT_SIZE = 12, TAB_FONT_SIZE = 16, TITLE_FONT_SIZE = 16;
  public static PFont   font = null, fontBold = null;
  
  public static boolean CreatePanelFonts ( PApplet p, String fontName, String fontBoldName ) {
    BasePanel.font = p.createFont(fontName, BasePanel.DEFAULT_FONT_SIZE);
    BasePanel.fontBold = p.createFont(fontBoldName, BasePanel.DEFAULT_FONT_SIZE);
    if ( BasePanel.font == null || BasePanel.fontBold == null ) {
      println("Invalid pathname for either FONT or FONTBOLD!");
      return false;
    }
    p.textFont(BasePanel.font);
    return true;
  }
}

class Tab {
  String   name;                     // displayed name of Tab
  boolean  activeTab = false;
  private ArrayList<PanelControl> controls;  // controls on this Tab

  Tab ( String name ) {
    this.name = name;
    // Calculate the width and height of this string
    controls = new ArrayList<PanelControl>();
  }
  
  void Show () {
    // The Panel has already translated to this point
    // Draw a box around the tab name that is not 'active'
    rectMode(CORNER);
    noFill();
    stroke(255);
    float textWidth = textWidth(name) + 4;  // Some padding
    textFont(Panel.fontBold);
    float textHeight = textAscent() + textDescent() + 4;
    if ( activeTab ) {
      beginShape();
        vertex(0,textHeight); vertex(0,0); vertex(0,textWidth);
      endShape(); 
    } else {
      rectMode(CORNER);
      rect(0,0,textWidth,textHeight);          
    }
    textAlign(CENTER,CENTER);
    text(name,textWidth/2,textHeight/2);
    // else draw three sided box on the 'active' tab
    // then draw the tab name
    // then translate to the start of the control area and draw the controls
  }
}

public class Panel extends BasePanel {
  protected static final int TITLEBAR_HEIGHT = 20;
  protected static final int PADDING = 5; 
  
  public    boolean showPanel = true;
  
  protected PVector loc, lastMousePos;
  protected String  panelName;
  protected int     minWidth, minHeight;
  protected float   tabHeight;
  protected color   clr;
  protected boolean dragging = false, rolledUp = false, 
                    mousePress = false, keyPress = false;
  protected char    showPanelControlChar = 'l';
  
  private   ArrayList<Tab> tabs;
  private   ArrayList<PanelControl> controls;
  private   Tab     activeTab = null;

  // Supply the PeasyCam object to the constructor
  Panel ( String panelName, PVector loc, int minWidth, int minHeight,
          color clr ) {
    this.panelName = panelName;
    this.loc = loc.copy();
    this.minWidth = minWidth;
    //BasePanelControl.panelWidth = minWidth;
    this.minHeight = minHeight;
    this.clr = clr;
    controls = new ArrayList<PanelControl>();
    tabs = new ArrayList<Tab>();
    textFont(font);
    textSize(BasePanel.TAB_FONT_SIZE);
    tabHeight = textAscent() + textDescent() + PADDING;
    
    for ( int i = 0; i < 4; i++ ) {
      String s = "Test " + i;
      tabs.add(new Tab(s));
    }
    tabs.get(0).activeTab = true;
  }
  
  void AddControl ( PanelControl ctl ) {
    if ( ctl.getClass() == HScrollbar.class ) {
      // Adjust the minWidth
      HScrollbar sb = (HScrollbar)ctl;
      sb.ctrlW = minWidth - 4 * PADDING;
      sb.RecalculateRange();
    }
    controls.add(ctl);
  }
  
  void AddButton ( int ID, String text_, float x, float y, 
           color normalClr_, color pressedClr_ ) {
    // Addbutton row, col  row goes from 0 to n, col = 0, 1, 2, etc
    // width of button is (panelWidth - 10) / numButtons in a row 
    controls.add(new Button(ID,text_, x, y, normalClr_, pressedClr_ ));
  }
  
  void AddTextString ( int ID, String text_, PVector loc_, color normalClr_, int textSize_ ) {
    controls.add(new TextString(ID,text_, loc_, normalClr_, textSize_ ));
  }
  
  float AddScrollbar ( int ID, String name, float min, float max, float xLoc, 
                       float yLoc ) {
    //if ( scrollWidth == -1 ) scrollWidth = minWidth - 4 * PADDING;
    HScrollbar sb = new HScrollbar(ID,name, min, max, xLoc, yLoc, minWidth - 4 * PADDING);
    controls.add(sb);
    return sb.GetSliderHeight();
  }
  
  float AddScrollbar ( int ID, String name, float min, float max, float xLoc, 
                       float yLoc, int w ) {
    //if ( scrollWidth == -1 ) scrollWidth = minWidth - 4 * PADDING;
    HScrollbar sb = new HScrollbar(ID,name, min, max, xLoc, yLoc, w - 4 * PADDING);
    controls.add(sb);
    return sb.GetSliderHeight();
  }
  
  void SetShowPanelChar ( char ch ) { showPanelControlChar = ch; }
    
  void UpdateKeypress () {
    // Now THIS is buggy with more than one panel....
    if ( ! keyPress && keyPressed && key == showPanelControlChar ) {
      showPanel = ! showPanel;
      keyPress = true;
    }
    if ( ! keyPressed )
      keyPress = false;
  }
 
  boolean InTitlebar() {
    return mouseY >= loc.y && mouseY <= loc.y + TITLEBAR_HEIGHT;
  }
  
  boolean OnRollup() {
    return mouseX >= loc.x + minWidth-30 && mouseX <= loc.x + minWidth - 20 && InTitlebar();
  }
  
  boolean OnHidePanel() {
    return mouseX >= loc.x + minWidth-15 && mouseX <= loc.x + minWidth && InTitlebar();
  }
  
  boolean OnDraggingSection() {
    return mouseX >= loc.x && mouseX <= loc.x + minWidth && InTitlebar();
  }
  
  boolean OnPanel () {
    int size = rolledUp ? TITLEBAR_HEIGHT : minHeight;
    return mouseX >= loc.x && mouseX <= loc.x + minWidth &&
           mouseY >= loc.y && mouseY <= loc.y + size;
  }
  
  void ConstrainToWindow() {
    loc.x = constrain(loc.x,0,width - minWidth);          // Keep on screen
    loc.y = constrain(loc.y,0,height - TITLEBAR_HEIGHT); 
  }
  
  // TODO: If Update is handled by the panel, then we don't want it's owner to do any
  // mouse or keyboard processing too.
  void Update () {
    if ( ! showPanel )  return;    // Nothing to see here... move on
    
    if ( width > minWidth ) {
      // If resizeable window, need to check that we are still within the window    
      ConstrainToWindow();  
    }
    
    if ( activePanel != null && activePanel != this ) return;
    
    // mousePress is always true while mouse is pressed!
    if ( mousePressed && ! mousePress && mouseButton == LEFT ) {
      if ( ! OnPanel() ) return;
      activePanel = this;
      mousePress = true;      // This avoids multiple mousePressed calls
      cam.setActive(false);
      if ( OnHidePanel() ) {
        showPanel = false;
        activePanel = null;
      }
      else if ( OnRollup() )
        rolledUp = ! rolledUp;
      else {
        dragging = OnDraggingSection();
        if ( dragging ) {
          lastMousePos = new PVector(mouseX,mouseY);
          cursor(HAND); 
        }
      }
    }
    if ( ! mousePressed ) {
      cam.setActive(true);
      mousePress = false;
      dragging = false;
      cursor(ARROW);
      activePanel = null;
    }
    else if ( dragging ) {      // Do panel dragging
      PVector currentMousePos = new PVector(mouseX,mouseY);
      loc.add(PVector.sub(currentMousePos,lastMousePos));   // add delta to position
      ConstrainToWindow(); 
      lastMousePos = currentMousePos.copy();                // now save new last mouse      
    }
  }
  
  void Disable ( int ID, boolean disable ) {
    PanelControl control = GetChild(ID);
    if ( control != null )
      control.disabled = disable;
  }  
  
  float GetValue ( int ID ) {
    PanelControl control = GetChild(ID);
    return control != null ? control.GetValue() : 0.0;
  }
  
  int GetIntegerValue ( int ID ) {
    PanelControl control = GetChild(ID);
    return control != null ? control.GetIntegerValue() : 0;
  }
  
  boolean GetBooleanValue ( int ID ) {
    PanelControl control = GetChild(ID);
    return control != null ? control.GetBooleanValue() : false;
  }
  
  void SetValue ( int ID, float value ) {
    PanelControl control = GetChild(ID);
    if ( control != null )
      control.SetValue(value);
  }
  
  void SetRelativeValue ( int ID, float value ) {
    PanelControl control = GetChild(ID);
    if ( control != null )
      control.SetRelativeValue(value);    
  }
  
  void SetValue ( int ID, float value, int numDecimals ) {
    PanelControl control = GetChild(ID);
    if ( /*control != null && */ control instanceof HScrollbar ) {
      HScrollbar ctl = (HScrollbar)control;
      ctl.SetValue(value,numDecimals);
    } else println("ID " + ID + " is NOT a Scrollbar!");
  }
  
  void SetBooleanValue ( int ID, boolean value ) {
    PanelControl control = GetChild(ID);
    if ( control != null )
      control.SetBooleanValue(value);
  }
  
  void SetText ( int ID, String text ) {
    PanelControl control = GetChild(ID);
    if ( control != null )
      control.SetText(text);
  }
  
  PanelControl GetChild ( int ID ) {
    for ( PanelControl control : controls ) {
      if ( control.ID == ID )
        return control;
    }
    println("ID " + ID + " NOT FOUND!");
    return null;
  }
  
  void DrawPanel () {
    // Main Panel area
    fill(clr);
    stroke(255);
    rectMode(CORNER);
    rect(0,0,minWidth,rolledUp ? TITLEBAR_HEIGHT : minHeight,5);
    // Now draw Tabs across top of window
    for ( Tab tab : tabs ) {
      
    }

    // Draw the Titlebar and accoutrements
    textFont(fontBold);
    textAlign(LEFT);
    fill(255);
    textSize(BasePanel.TITLE_FONT_SIZE);
    // Clip text if too big for title area
    //clip(loc.x,loc.y,minWidth-35,15);
    text(panelName,5,15);
    //noClip();
    pushMatrix();    // Close 'X'
      strokeWeight(OnHidePanel() ? 2 : 1);
      translate(minWidth-10,9);
      line(5,5,-5,-5);
      line(-5,5,5,-5);
    popMatrix();
    noFill();
    pushMatrix();    // Rollup/rolldown triangle
      translate(minWidth-25,9);
      strokeWeight(OnRollup() ? 2 : 1);
      if ( rolledUp )
        rotate(PI);        
      beginShape();
        vertex(-5,5); vertex(5,5); vertex(0,-5);
      endShape(CLOSE);
    popMatrix();
    strokeWeight(1);
  }
  
  void draw () {           // Registered callback mthod
    noLights();
    UpdateKeypress();      // In case the panel is not visible
    
    if ( BasePanel.font == null || BasePanel.fontBold == null ) {
      println("MUST supply a fontname for the regular and bold fonts !!");
      return;
    }
    
    // NO!!! We should unregister the "draw" method if the panel is not shown
    // This will save compute time.... no "draw" overhead...
    if ( !showPanel ) {
      return;    // Nothing to see here... move on
    }
    
    boolean handled = false;
   
    cam.beginHUD();
    
      ortho(0,width,-height,0);  // now in standard Processing coordinates
      
      pushMatrix();  
        resetMatrix();    // Consistent XYZ frame to frame
        if ( ! rolledUp && ! dragging) { // Only check controls if not rolled up
          PVector childPanelPos = PVector.add(loc,new PVector(0,TITLEBAR_HEIGHT+tabHeight));
          
          for ( PanelControl control : controls ) {
            if ( PanelControl.activePanelControl == null || 
                 PanelControl.activePanelControl == control ) {
              handled = control.Update(childPanelPos);
              if ( handled ) break;
            }
          }
        }
    
        if ( ! handled )
          Update();              // Now check for rollup, hiding, and moving        
    
        // Display the panel based on it's status
        translate(loc.x,loc.y); 
        DrawPanel();    // Including Tabs
        
        // Draw controls if visible
        if ( ! rolledUp ) {
          line(0,TITLEBAR_HEIGHT,minWidth,TITLEBAR_HEIGHT);
          // Now translate past this Titlebar and Tabs
          translate(PADDING,TITLEBAR_HEIGHT+PADDING+tabHeight); 
          // Now loop through all controls. Clip anything outside of panel area.
          //clip(loc.x,loc.y+tabHeight,minWidth,minHeight);
          for ( PanelControl control : controls )
            control.Show();
          //noClip();
        }   
      popMatrix();
      
      perspective(); //fov,aspect,cameraZ/10.0,cameraZ*10.0);
    
    cam.endHUD();
  }
  /// End of Class 
}