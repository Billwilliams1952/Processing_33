import peasy.*;

float     radius = 100;
int       samples = 150;  // 1, 2, 3, 5, 10, 15
float[]   lineInc = {1,2,3,5,10,15};
PVector   pts[][];
PeasyCam  cam;
PMatrix3D baseMat;
Panel     p;
PImage    earth;
float     changeU, changeV; // Delta width (u), height (v) for texture
float     u = 0, v = 0;     // Width and height location for texture map 
int       origHeight, w, h;
float     fov, aspect, cameraZ;

void setup () {
  //fullScreen(P3D);
  size(1280,1024,P3D);
  surface.setResizable(true);
  origHeight = height;
  
  fov = PI / 3.0;
  aspect = width/height;
  cameraZ = (height / 2.0) / tan(fov/2.0);
  
 // w = width; h = height;
  
  pts = new PVector[samples+1][samples+1];
  
  earth = loadImage("route.png");//"earthbig.jpg");
  changeU = earth.width/(float)(samples);
  changeV = earth.height/(float)(samples);
  
  baseMat = g.getMatrix(baseMat);
  cam = new PeasyCam(this, 300);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(10000);
  state = cam.getState();
  
  BasePanel.CreatePanelFonts(this,"arial.ttf","arialbd.ttf");
  p = new Panel("SuperShapes", new PVector(250,20), 495, 320, 
                color(0,0,255,150));
  float size = p.AddScrollbar ( 1, "R1 A", -5, 5 , 5, 0, 250);
  p.SetValue(1,1,2);  
  p.AddScrollbar ( 2, "R1 B", -5, 5 , 5, size, 250);
  p.SetValue(2,1,2);   
  p.AddScrollbar ( 3, "R1 M", 0, 50 , 5, 2*size, 250);
  p.SetValue(3,0,2);  
  p.AddScrollbar ( 4, "R1 N1", -50, 50 , 5, 3*size, 250);
  p.SetValue(4,1,2);  
  p.AddScrollbar ( 5, "R1 N2", -50, 50 , 5, 4*size, 250);
  p.SetValue(5,1,2);   
  p.AddScrollbar ( 6, "R1 N3", -50, 50 , 5, 5*size, 250);
  p.SetValue(6,1,2); 
  
  p.AddScrollbar ( 7, "R2 A", -5, 5 , 250, 0, 250);
  p.SetValue(7,1,2);  
  p.AddScrollbar ( 8, "R2 B", -5, 5 , 250, size, 250);
  p.SetValue(8,1,2);   
  p.AddScrollbar ( 9, "R2 M", 0, 50 , 250, 2*size, 250);
  p.SetValue(9,0,2);  
  p.AddScrollbar ( 10, "R2 N1", -50, 50 , 250, 3*size, 250);
  p.SetValue(10,1,2);  
  p.AddScrollbar ( 11, "R2 N2", -50, 50 , 250, 4*size, 250);
  p.SetValue(11,1,2);   
  p.AddScrollbar ( 12, "R2 N3", -50, 50 , 250, 5*size, 250);
  p.SetValue(12,1,2); 

  p.AddButton(13,"Reset/Reset",0,6*size + 10,
                            color(0,255,255),color(255,255,150));
  p.SetBooleanValue(13,false);
  p.AddButton(14,"Texture/Mesh/Lines/Texture+Lines/Mesh+Lines",125,6*size +10,
                            color(0,255,255),color(255,255,150));
  p.SetBooleanValue(14,false);
  p.AddScrollbar ( 15, "#Lines", 0, 5 , 250, 6*size, 100);
  p.SetValue(15,0,0); 

  registerMethod("draw",p);
  
  SetValues(0.85,1.6,7.24,3.99,-17.09,20.36,1.75,1.84,22.68,6.59,12.61,6.86);
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
    cam.reset(500);
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
  ortho();
    noLights();
    ambientLight(255,255,255);
    fill(255);
    pushMatrix();
      translate(200,200,0);
      rotateX(rotations[0]);
      rotateY(rotations[1]);
      rotateZ(rotations[2]);
      textSize(18);
      strokeWeight(2);
      //fill(255,0,0);
      stroke(255,0,0);
      line(0,0,0,50,0,0);
      text("X",50,0,0);
      //fill(0,255,0);
      stroke(0,255,0);
      line(0,0,0,0,50,0);
      text("Y",0,50,0);
      //fill(0,0,255);
      stroke(0,0,255);
      line(0,0,0,0,0,50);
      text("Z",0,0,50);
    popMatrix();
    fill(255);
    textAlign(LEFT);
    text("Distance: "+nfc(round((float)cam.getDistance())),10,height-20);
    text("X: "+nfc((int)mouseX)+" Y: "+nfc((int)mouseY),10,height-40);
    noFill();
    perspective(fov,aspect,cameraZ/10.0,cameraZ*10.0);
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

void DrawSuperShape() {
  u = 0;  // Width variable for the texture
  v = 0;  // Height variable for the texture  
  int drawType = p.GetIntegerValue(14); 
  //Texture = 0, Mesh = 1, Lines = 2, Texture+Lines = 3, Mesh+Lines = 4 
  
  if ( drawType != 2 ) {
    if ( drawType == 1 || drawType == 4 ) stroke(255,255,255,150); 
    else noStroke();
    beginShape(TRIANGLE_STRIP);
    if ( drawType == 0 || drawType == 3 )
      texture(earth);
    for ( int lat = 0; lat < samples; lat++ ) {
        for ( int lon = 0; lon <= samples; lon++ ) {
          PVector p = pts[lat][lon];    // readability only
          vertex(p.x,p.y,p.z,u,v);
          p = pts[lat+1][lon];
          vertex(p.x,p.y,p.z,u,v+changeV);
          u += changeU;
        }
      v += changeV;
      u = 0;
     }  
     endShape();
  }
  
  if ( drawType >= 2 ) {
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

float angle = 0, angle1 = 0.0;
CameraState state;

void draw() {
  background(0);
  
  if ( width != w || height != h ) {
    cam.setState(state);
    w = width; h = height;
    perspective(fov,aspect,cameraZ/10.0,cameraZ*10.0);
  }
  
  state = cam.getState();
  
  CheckReset();
  
  // Make sure peasyCam doesn't rotate the lights!
  pushMatrix();
    setMatrix(baseMat);
    
    //lights();
    // Orange point light on the right
    pushMatrix();
    rotateX(angle);    
    rotateY(angle1); 
    //rotateZ(angle);
    pointLight(150, 100, 0, // Color
               500, -550, 300); // Position

    // Blue directional light from the left
    directionalLight(0, 102, 255,//(0, 102, 255, // Color
                     1, 1, 0); // The x-, y-, z-axis direction
    angle += 0.05; angle1 += 0.1;
    popMatrix();
  
    // Yellow spotlight from the front
    spotLight(255,0,0, //255, 255, 109, // Color
              0, 0, 500, // Position
              0, -0.5, -0.5, // Direction
              PI / 32, 500); // Angle, concentration
              
    //lightSpecular(1,1,1);
  popMatrix();
  
  //lightSpecular(255, 255, 255);
  //specular(255, 255,255);
  //shininess(15.0); 
  ambientLight(60,60,60);
  //ambient(255,255,255);
  //colorMode(HSB);
  noStroke();
  
  pushMatrix();
    rotateX(-HALF_PI);    // Earth north up
    noFill();
    CreateSuperShape();
    DrawSuperShape();
  popMatrix();
  
  noLights();
  
  DrawXYZ(); 
}