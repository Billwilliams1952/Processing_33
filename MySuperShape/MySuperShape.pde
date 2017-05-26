

import peasy.*;

static final float CAMERA_DISTANCE = 275;
static final long CAMERA_ANIMATION_TIME_MSEC = 500;

float     radius = 100;
int       samples = 150;  // 1, 2, 3, 5, 10, 15
float[]   lineInc = {1,2,3,5,10,15};
PVector   pts[][];
PeasyCam  cam;
PMatrix3D baseMat;
Panel     p, lights;
PImage    earth;
float     changeU, changeV; // Delta width (u), height (v) for texture
float     u = 0, v = 0;     // Width and height location for texture map 
int       origHeight, w, h;

void setup () {
  //fullScreen(P3D);
  size(1280,1024,P3D);
  surface.setResizable(true);
  origHeight = height;
  frameRate = 60;
  
  pts = new PVector[samples+1][samples+1];
  
  earth = loadImage("route.png");//"earthbig.jpg");
  changeU = earth.width/(float)(samples);
  changeV = earth.height/(float)(samples);
  
  baseMat = g.getMatrix(baseMat);
  cam = new PeasyCam(this, CAMERA_DISTANCE);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(10000);
  state = cam.getState();        // save for resizing...
  
  BasePanel.CreatePanelFonts(this,"arial.ttf","arialbd.ttf");
  p = new Panel("SuperShapes", new PVector(0,0), 495, 320, 
                color(0,0,255,150));
  float size = p.AddScrollbar ( 1, "R1 A", -5, 5 , 5, 0, 250);
  p.SetValue(1,1,2);  
  p.AddScrollbar ( 2, "R1 B", -5, 5 , 5, size, 250);
  p.SetValue(2,1,2);   
  p.AddScrollbar ( 3, "R1 M", 0, 50 , 5, 2*size, 250);
  p.SetValue(3,0,2);  
  p.AddScrollbar ( 4, "R1 N1", -500, 500 , 5, 3*size, 250);
  p.SetValue(4,1,2);  
  p.AddScrollbar ( 5, "R1 N2", -500, 500 , 5, 4*size, 250);
  p.SetValue(5,1,2);   
  p.AddScrollbar ( 6, "R1 N3", -500, 500 , 5, 5*size, 250);
  p.SetValue(6,1,2); 
  
  p.AddScrollbar ( 7, "R2 A", -5, 5 , 250, 0, 250);
  p.SetValue(7,1,2);  
  p.AddScrollbar ( 8, "R2 B", -5, 5 , 250, size, 250);
  p.SetValue(8,1,2);   
  p.AddScrollbar ( 9, "R2 M", 0, 50 , 250, 2*size, 250);
  p.SetValue(9,0,2);  
  p.AddScrollbar ( 10, "R2 N1", -500, 500 , 250, 3*size, 250);
  p.SetValue(10,1,2);  
  p.AddScrollbar ( 11, "R2 N2", -500, 500 , 250, 4*size, 250);
  p.SetValue(11,1,2);   
  p.AddScrollbar ( 12, "R2 N3", -500, 500 , 250, 5*size, 250);
  p.SetValue(12,1,2); 

  p.AddButton(13,"Reset/Reset",0,6*size + 10,
                            color(0,255,255),color(255,255,150));
  p.SetBooleanValue(13,false);
  p.AddButton(14,"Texture/Color/Mesh",105,6*size +10,
                            color(0,255,255),color(255,255,150));
  p.SetBooleanValue(14,false);
  p.AddButton(16,"No Lines/Lat-Lon Lines",210,6*size +10,
                            color(0,255,255),color(255,255,150));
  p.SetBooleanValue(16,false);  
  
  p.AddScrollbar ( 15, "#Lines", 0, 5 , 320, 6*size, 100);
  p.SetValue(15,0,0); 

  registerMethod("draw",p);
  
  SetValues(0.85,1.6,7.24,3.99,-17.09,20.36,1.75,1.84,22.68,6.59,12.61,6.86);
  
  // Lighting Panel
  lights = new Panel("Lighting", new PVector(0,330), 495, 320, 
                color(0,0,255,150));
  size = lights.AddScrollbar ( 1, "Red", 0, 255 , 5, 0, 250);
  lights.SetValue(1,128,0);  
  lights.AddScrollbar ( 2, "Green", -5, 5 , 5, size, 250);
  lights.SetValue(2,128,0);   
  lights.AddScrollbar ( 3, "Blue", 0, 50 , 5, 2*size, 250);
  lights.SetValue(3,128,0);  
  lights.AddScrollbar ( 4, "R1 N1", -500, 500 , 5, 3*size, 250);
  lights.SetValue(4,1,2);  
  lights.AddScrollbar ( 5, "R1 N2", -500, 500 , 5, 4*size, 250);
  lights.SetValue(5,1,2);   
  lights.AddScrollbar ( 6, "R1 N3", -500, 500 , 5, 5*size, 250);
  lights.SetValue(6,1,2); 
  registerMethod("draw",lights);


}

void CheckReset() {
  if ( p.GetBooleanValue(13) ) {
    p.SetBooleanValue(13,false);
    p.SetValue(1,1,2);
    p.SetValue(2,1,2);   
    p.SetValue(3,0,2);  
    p.SetValue(4,1,2);  
    p.SetValue(5,1,2);   
    p.SetValue(6,1,2); 
    p.SetValue(7,1,2);
    p.SetValue(8,1,2);   
    p.SetValue(9,0,2);  
    p.SetValue(10,1,2);  
    p.SetValue(11,1,2);   
    p.SetValue(12,1,2);
    cam.reset(CAMERA_ANIMATION_TIME_MSEC);
  }
}

void SetValues ( float a1, float b1, float m1, float n11, float n12, float n13,
                 float a2, float b2, float m2, float n21, float n22, float n23 ) {
  p.SetValue(1,a1,2);
  p.SetValue(2,b1,2);   
  p.SetValue(3,m1,2);  
  p.SetValue(4,n11,2);  
  p.SetValue(5,n12,2);   
  p.SetValue(6,n13,2); 
  p.SetValue(7,a2,2);
  p.SetValue(8,b2,2);   
  p.SetValue(9,m2,2);  
  p.SetValue(10,n21,2);  
  p.SetValue(11,n22,2);   
  p.SetValue(12,n23,2);                   
}

void DrawXYZ () {
  float[] rotations = cam.getRotations();
  cam.beginHUD();    
    noLights();
    ambientLight(255,255,255);
    ambient(255,255,255);
    fill(255);
    ortho(0,width,-height,0);
    pushMatrix();
      resetMatrix();
      fill(255);
      textAlign(LEFT);
      textFont(BasePanel.fontBold);
      textSize(16);
      text("Framerate: " + nfc((int)frameRate) + "  Distance: "+nfc((int)cam.getDistance()),10,height-20);
      text("X: "+nfc((int)mouseX)+" Y: "+nfc((int)mouseY),10,height-40);
      text("Rotations  X: "+nfc(degrees(rotations[0]),1) +
           "  Y: "+nfc(degrees(rotations[1]),1) +
           "  Z: "+nfc(degrees(rotations[2]),1) ,10,height-60);
      noFill();
      float z = -100;    // Push back enough so there is no clipping
      translate(60,height-160,z);
      rotateX(rotations[0]);
      rotateY(rotations[1]);
      rotateZ(rotations[2]);
      textSize(18);
      strokeWeight(2);
      stroke(255,0,0);
      line(0,0,0,50,0,0);
      text("X",50,0,0);
      stroke(0,255,0);
      line(0,0,0,0,50,0);
      text("Y",0,50,0);
      stroke(0,0,255);
      line(0,0,0,0,0,50);
      text("Z",0,0,50);
    popMatrix();
    perspective();
  cam.endHUD();
}

float SuperShapeRadius ( float theta, float a, float b, float m,
                         float n1, float n2, float n3 ) {
  float val1 = pow(abs(cos(m * theta / 4) / a),n2);
  float val2 = pow(abs(sin(m * theta / 4) / b),n3);
  return pow((val1 + val2),-1/n1);
}

//r2 = SuperShapeRadius(latInRads,1,1,0,1,1,1);
//r1 = SuperShapeRadius(lonInRads,1,1,0,1,1,1);
//r2 = SuperShapeRadius(latInRads,1,1,0,1,1,1);
//r1 = SuperShapeRadius(lonInRads,1,1,20.2,0.16,2.3,2.3);
//r2 = SuperShapeRadius(latInRads,1,1,3,3,0.2,1);
//r1 = SuperShapeRadius(lonInRads,1,1,2.6,0.1,1,2.5);
//r1 = SuperShapeRadius(lonInRads,1,1,6,1000,400,400);
//r2 = SuperShapeRadius(latInRads,1,1,4,300,300,300);
//r1 = SuperShapeRadius(lonInRads,1,1,4,200,200,200);
//r2 = SuperShapeRadius(latInRads,1,1,3,200,500,500);
//r1 = SuperShapeRadius(lonInRads,1,1,3,260,500,500);
//r2 = SuperShapeRadius(latInRads,1,1,4,200,200,200);
//r1 = SuperShapeRadius(latInRads,0.85,1.6,7.24,3.99,-17.09,20.36);  // 1450 lookdistance
//r2 = SuperShapeRadius(latInRads,1.75,1.84,22.68,6.59,12.61,6.86);
//r1 = SuperShapeRadius(latInRads,0.9,0.01,23.91,4.91,-36.01,15.56);  // 3000 lookdistance
//r2 = SuperShapeRadius(latInRads,-0.08,1.84,21.32,16.5,13.05,9.59);
//r1 = SuperShapeRadius(latInRads,1.69,1,3,100,100,100);
//r2 = SuperShapeRadius(latInRads,1.59,2.9,3,100,100,100);


void CreateSuperShape() {
  float r1, r2, latInRads, lonInRads, cosLatRads, sinLatRads;
  
  for ( int lat = 0; lat < samples+1; lat++ ) {
    latInRads = map(lat,0,samples,-HALF_PI,HALF_PI);
    r2 = SuperShapeRadius(latInRads,p.GetValue(1),p.GetValue(2),p.GetValue(3),
                                    p.GetValue(4),p.GetValue(5),p.GetValue(6));
    cosLatRads = cos(latInRads);
    sinLatRads = sin(latInRads);
    for ( int lon = 0; lon < samples+1; lon++ ) {
      lonInRads = map(lon,0,samples,-PI,PI);
      r1 = SuperShapeRadius(lonInRads,p.GetValue(7),p.GetValue(8),p.GetValue(9),
                                      p.GetValue(10),p.GetValue(11),p.GetValue(12));
      pts[lat][lon] = new PVector(radius * r1 * cos(lonInRads) * r2 * cosLatRads,
                                  radius * r1 * sin(lonInRads) * r2 * cosLatRads,
                                  radius * r2 * sinLatRads);
    }    
  }
}

float ArchimedesSpiral ( float theta, float a, float b ) {
  // Take SuperShape radius
  return a + b * theta;    // New radius
}

void DrawSuperShape() {
  u = 0;  // Width variable for the texture
  v = 0;  // Height variable for the texture  
  int drawType = p.GetIntegerValue(14); 
  // Texture = 0, Color = 1, Mesh = 2
 
  colorMode(HSB,samples);
  beginShape(TRIANGLE_STRIP);
  noStroke();
  if ( drawType == 0 )
    texture(earth);
  for ( int lat = 0; lat < samples; lat++ ) {
      for ( int lon = 0; lon <= samples; lon++ ) {
        PVector p = pts[lat][lon];    // readability only
        if ( drawType == 2 ) {
          stroke(lat,samples,samples);  // Hue, Saturation, Brightness
        } else if ( drawType == 1 ) {
          fill(lat,samples,samples);  // Hue, Saturation, Brightness
        }
        vertex(p.x,p.y,p.z,u,v);
        p = pts[lat+1][lon];
        vertex(p.x,p.y,p.z,u,v+changeV);
        u += changeU;
      }
    v += changeV;
    u = 0;
   }  
   endShape();
   colorMode(RGB,255);
  
  if ( p.GetBooleanValue(16) ) {
    strokeWeight(3);
    stroke(255,0,0);
    int inc = (int)lineInc[p.GetIntegerValue(15)];
    for ( int lon = 0; lon <= samples; lon += inc ) {
      beginShape();
      for ( int lat = 0; lat <= samples; lat++ ) {
          PVector p = pts[lat][lon];    // readability only
          vertex(p.x,p.y,p.z);
        }
      endShape();
     }  
    for ( int lat = 0; lat <= samples; lat += inc ) {
      beginShape();
      for ( int lon = 0; lon <= samples; lon++ ) {
          PVector p = pts[lat][lon];    // readability only
          vertex(p.x,p.y,p.z);
        }
      endShape();
     } 
  }
}

float angle = random(TWO_PI), angle1 = random(TWO_PI), angle2 = random(TWO_PI);
CameraState state;

void draw() {
  background(0);
  
  if ( width != w || height != h ) {
    cam.setState(state);      // This seems to fix a bug(?) where PeasyCam
                              // does not display correctly after a resize
    w = width; h = height;
  }
  
  CheckReset();
  
  // Make sure peasyCam doesn't rotate the lights!
  pushMatrix();
    resetMatrix();
    translate(0.0,0.0,-(float)cam.getDistance());
    pushMatrix();
      rotateX(angle);    
      rotateY(angle1); 
      rotateZ(angle2);
      float red = 200, green = 200, blue = 200;
      pushMatrix();
        translate(0,-550,300);
        noStroke();
        lights();
        ambientLight(red, green, blue);
        ambient(red, green, blue);
        sphere(10);
        stroke(red,green,blue,100);
        for ( int i = 0; i < 50; i++ )
          line(0,0,0,random(-80,80),random(-80,80),random(-80,80));
        noLights();          
        lightSpecular(50,50,50);
        pointLight(red, green, blue, //150, 100, 0, // Color
                   0, 0, 0); // Position
      popMatrix();

      angle += 0.04; angle1 += 0.01;
    popMatrix();
    // Blue directional light from the left
    directionalLight(0, 102, 255, // Color
                      1, 1, 0); // The x-, y-, z-axis direction
  
    // spotlight from the front
    spotLight(255, 0, 255, //255, 255, 109, // Color
              0, 0, 500, // Position
              0, -0.1, -0.5, // Direction
              PI / 8, 500); // Angle, concentration
              
  popMatrix();

  specular(50,50,50);
  shininess(0.1); 
  ambientLight(60,60,60);
  ambient(60,60,60);
  noStroke();
  
  pushMatrix();
    rotateX(-HALF_PI);    // Earth north up
    noFill();
    CreateSuperShape();
    DrawSuperShape();
  popMatrix();

  DrawXYZ(); 
  state = cam.getState();
}

public void mouseEvent ( MouseEvent event ) {
  // Check for Ctrl+WHEEL (Obstacles) or Alt+WHEEL (BadGuys)
  float x = event.getX();
  float y = event.getY();  
}