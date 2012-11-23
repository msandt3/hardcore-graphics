//*********************************************************************
//**                            3D template                          **
//**                 Jarek Rossignac, Oct  2012                      **   
//*********************************************************************
import processing.opengl.*;                // load OpenGL libraries and utilities
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import java.nio.*;
GL gl; 
GLU glu; 

// ****************************** GLOBAL VARIABLES FOR DISPLAY OPTIONS *********************************
Boolean 
  showMesh=true,
  translucent=false,   
  showSilhouette=true, 
  showNMBE=true,
  showSpine=true,
  showControl=true,
  showTube=true,
  showFrenetQuads=false,
  showFrenetNormal=false,
  filterFrenetNormal=true,
  showTwistFreeNormal=false, 
  showHelpText=false;
  Boolean drawRotate;
Curve polygon,controlPoints,temp;
RotateMatrix matrix;
Solid s;
int numRotations;
Test test;
// String SCC = "-"; // info on current corner
   
// ****************************** VIEW PARAMETERS *******************************************************
pt F = P(0,0,0); pt T = P(0,0,0); pt E = P(0,0,1000); vec U=V(0,1,0);  // focus  set with mouse when pressing ';', eye, and up vector
pt Q=P(0,0,0); vec I=V(1,0,0); vec J=V(0,1,0); vec K=V(0,0,1); // picked surface point Q and screen aligned vectors {I,J,K} set when picked
void initView() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,0,1500); U=V(0,1,0); } // declares the local frames

// ******************************** MESHES ***********************************************
Mesh M=new Mesh(); // meshes for models M0 and M1

float volume1=0, volume0=0;
float sampleDistance=1;
// ******************************** CURVES & SPINES ***********************************************
//Curve C0 = new Curve(5), S0 = new Curve(), C1 = new Curve(5), S1 = new Curve();  // control points and spines 0 and 1
//Curve C= new Curve(11,130,P());
int nsteps=250; // number of smaples along spine
float sd=10; // sample distance for spine
pt sE = P(), sF = P(); vec sU=V(); //  view parameters (saved with 'j'
pt O;
boolean testBoolean;
ArrayList<Curve> orientationTest;
ArrayList<Solid> solids = new ArrayList<Solid>(4);
int counter;

// *******************************************************************************************************************    SETUP
void setup() {
  size(800, 800, OPENGL);  
  //size(800,800,800);
  setColors(); sphereDetail(6); 
   numRotations=6;
  PFont font = loadFont("GillSans-24.vlw"); textFont(font, 20);  // font for writing labels on //  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12); 
  // ***************** OpenGL and View setup
  glu= ((PGraphicsOpenGL) g).glu;  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  gl = pgl.beginGL();  pgl.endGL();
  initView(); // declares the local frames for 3D GUI
  polygon=new Curve();
  controlPoints= new Curve();
  computePolygon();
  matrix=new RotateMatrix();
  temp=new Curve();
  drawRotate=false;
  s=new Solid(polygon);
  s.rotationalSweep(numRotations);
  s.calculateI();
  s.calculateJ();
  s.calculateK();
  O =s.curves.get(0).pts.get(s.curves.get(0).pts.size()-1);
  M.declareVectors();
  M.makeRevolution(s);
  testBoolean=false;
  test= new Test();
  orientationTest= test.testToLocalCurve();
  counter=0;
  //Adding functionality for four shapes
  for(int index=0; index<4; index++){
    solids.add(index,new Solid(polygon));
  }


   
  // ***************** Set view  
}
// ******************************************************************************************************************* DRAW      
void draw() {  
  background(white);
  // -------------------------------------------------------- Help ----------------------------------
  if(showHelpText) {
    camera(); // 2D display to show cutout
    lights();
    fill(black); writeHelp();
    return;
  } 
  if(!testBoolean){
    polygon.briansDraw();
    //controlPoints.drawPoints(); 
  }
  // -------------------------------------------------------- 3D display : set up view ----------------------------------
  camera(E.x, E.y, E.z, F.x, F.y, F.z, U.x, U.y, U.z); // defines the view : eye, ctr, up
  vec Li=U(A(V(E,F),0.1*d(E,F),J));   // vec Li=U(A(V(E,F),-d(E,F),J)); 
  directionalLight(255,255,255,Li.x,Li.y,Li.z); // direction of light: behind and above the viewer
  specular(255,255,0); shininess(5);
  if(testBoolean){
    println("Test boolean tripped, drawing orientation test stuff");
    for(int i=0;  i<orientationTest.size();i++){
      orientationTest.get(i).briansDraw(); 
    }
  }
  else{
    println("Drawing S at: "+s.stringOrigin());
    s.draw();
    /*
    for(int i=0; i<solids.size(); i++){
      pushMatrix();
      translate(20*i,20*i,20*i);
      solids.get(i).draw();
      popMatrix();
    }
    */
    stroke(black);
  //show(polygon.pts.get(polygon.pts.size()-1),s.I);
  //show(polygon.pts.get(polygon.pts.size()-1),s.J);
  //show(polygon.pts.get(polygon.pts.size()-1),s.K);
  
  // -------------------------- display and edit control points of the spines and box ----------------------------------   
    if(pressed) {
         if (keyPressed&&(key=='a')) {//Picks a point on the polygon
           controlPoints.pick(new pt(pmouseX,pmouseY,0)); 
            polygon.deepCopy(controlPoints); 
            
       }
         if(keyPressed&&(key=='i')){
            controlPoints.insert(new pt(pmouseX,pmouseY,0));
            polygon.deepCopy(controlPoints); 
         }

     }
     
     // -------------------------------------------------------- show mesh ----------------------------------   
   if(showMesh) { fill(yellow); if(M.showEdges) stroke(white);  else noStroke(); M.showFront();} 
   
    // -------------------------- pick mesh corner ----------------------------------   
   if(pressed) if (keyPressed&&(key=='.')) M.pickc(Pick());
 
 
     // -------------------------------------------------------- show mesh corner ----------------------------------   
   if(showMesh) { fill(red); noStroke(); M.showc();} 
 
    // -------------------------------------------------------- edit mesh  ----------------------------------   
  if(pressed) {
   
     if (keyPressed&&(key=='X'||key=='Z')) M.pickc(Pick()); // sets M.sc to the closest corner in M from the pick point
     }
 
  // -------------------------------------------------------- graphic picking on surface and view control ----------------------------------   
 if (keyPressed&&key==';'){
  T.set(Pick()); // sets point T on the surface where the mouse points. The camera will turn toward's it when the ';' key is released
  SetFrame(Q,I,J,K);
  showFrame(Q,I,J,K,30);  // sets frame from picked points and screen axes
}
  // rotate view 
 /* if(!keyPressed&&mousePressed) {E=R(E,  PI*float(mouseX-pmouseX)/width,I,K,F); E=R(E,-PI*float(mouseY-pmouseY)/width,J,K,F); } // rotate E around F 
  if(keyPressed&&key=='D'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K); }  //   Moves E forward/backward
  if(keyPressed&&key=='d'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K);U=R(U, -PI*float(mouseX-pmouseX)/width,I,J); }//   Moves E forward/backward and rotatees around (F,Y)*/
  
  // -------------------------------------------------------- Disable z-buffer to display occluded silhouettes and other things ---------------------------------- 
  hint(DISABLE_DEPTH_TEST);  // show on top
 // stroke(black); if(showControl) {C0.showSamples(2);}
  if(showMesh&&showSilhouette) {stroke(dbrown); M.drawSilhouettes(); }  // display silhouettes
  strokeWeight(2); stroke(red);if(showMesh&&showNMBE) M.showMBEs();  // manifold borders
  camera(); // 2D view to write help text
  writeFooterHelp();
  hint(ENABLE_DEPTH_TEST); // show silouettes

  // -------------------------------------------------------- SNAP PICTURE ---------------------------------- 
   if(snapping) snapPicture(); // does not work for a large screen
    pressed=false;
  }
} // end draw
 
 
 // ****************************************************************************************************************************** INTERRUPTS
Boolean pressed=false;

void mousePressed() {pressed=true; }
  
void mouseDragged() {
   if(keyPressed&&key=='a'){
     if(controlPoints.p==0 || controlPoints.p==controlPoints.pts.size()-1){
             controlPoints.dragPoint(V(0,new vec(0.0,0.0,0.0),-.5*(mouseY-pmouseY),J));
     }
     else{
      controlPoints.dragPoint(V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J));
     }
    polygon.deepCopy(controlPoints);
    s.curves.clear();
    s.curves.add(polygon);
    s.rotationalSweep(numRotations);
    M.resetCounters();
    M.makeRevolution(s);
    
   } 
  if(keyPressed&&key=='s') {
     
     }
  if(keyPressed&&key=='o'){
     println("counter: "+counter);
     Solid localSolid=s.toLocalSolid(s.I,s.J,s.K,O);
     
     println("Local Solid:" +localSolid);
     if(mouseX-pmouseX<0){
       s.decrementIX();
    }
     else if(mouseX-pmouseX>0){
       s.incrementIX(); 
     }
     else if(mouseY-pmouseY>0){
       s.incrementIY();
     }
     else if(mouseY-pmouseY<0){
      s.decrementIY(); 
     }
     s.calculateJ();
     s.calculateK();

     println(s.I);
     
     s = localSolid.toGlobalSolid(s.I,s.J,s.K,O);
     println("S: "+s);
     counter++;
  }  
     // move selected vertex of curve C in screen plane
  if(keyPressed&&key=='b') //{C.dragAll(0,5, V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),K) ); } // move selected vertex of curve C in screen plane
  if(keyPressed&&key=='v') //{C.dragAll(0,5, V(.5*(mouseX-pmouseX),I,-.5*(mouseY-pmouseY),J) ); } // move selected vertex of curve Cb in XZ
  if(keyPressed&&key=='x') {M.add(float(mouseX-pmouseX),I).add(-float(mouseY-pmouseY),J); M.normals();} // move selected vertex in screen plane
  if(keyPressed&&key=='z') {M.add(float(mouseX-pmouseX),I).add(float(mouseY-pmouseY),K); M.normals();}  // move selected vertex in X/Z screen plane
  if(keyPressed&&key=='X') {M.addROI(float(mouseX-pmouseX),I).addROI(-float(mouseY-pmouseY),J); M.normals();} // move selected vertex in screen plane
  if(keyPressed&&key=='Z') {M.addROI(float(mouseX-pmouseX),I).addROI(float(mouseY-pmouseY),K); M.normals();}  // move selected vertex in X/Z screen plane 
  }

void mouseReleased() {
     U.set(M(J)); // reset camera up vector
    }
  
void keyReleased() {
   if(key=='-') F=P(T);                           //   if(key=='c') M0.moveTo(C.Pof(10));
   U.set(M(J)); // reset camera up vector
   } 

 
void keyPressed() {
  if(key=='a') {} // drag curve control point in xz (mouseDragged)
  if(key=='b') {
  }  // move S2 in XZ
  if(key=='c') {} // load curve
  if(key=='d') {
  
  
  } 
  if(key=='e') {}
  if(key=='f') {}
  if(key=='g') {} // change global twist w (mouseDrag)
  if(key=='h') {} // hide picked vertex (mousePressed)
  if(key=='i') {}
  if(key=='j') {}
  if(key=='k') {}
  if(key=='l') {}
  if(key=='m') {showMesh=!showMesh;}
  if(key=='n') {showNMBE=!showNMBE;}
  if(key=='o') {}
  if(key=='p') {}
  if(key=='q') {}
  if(key=='r') {}
  if(key=='s') {} // drag curve control point in xz (mouseDragged)
  if(key=='t') {showTube=!showTube;}
  if(key=='u') {}
  if(key=='v') {} // move S2
  if(key=='w') {}
  if(key=='x') {} // drag mesh vertex in xy (mouseDragged)
  if(key=='y') {}
  if(key=='z') {} // drag mesh vertex in xz (mouseDragged)
   
  if(key=='A')// {C.savePts();}
  if(key=='B') {}
  if(key=='C') //{C.loadPts();} // save curve
  if(key=='D') {} //move in depth without rotation (draw)
  if(key=='E') {M.smoothen(); M.normals();}
  if(key=='F') {}
  if(key=='G') {}
  if(key=='H') {}
  if(key=='I') {}
  if(key=='J') {}
  if(key=='K') {}
  if(key=='L') {M.loadMeshVTS().updateON().resetMarkers().computeBox(); F.set(M.Cbox); E.set(P(F,M.rbox*2,K)); for(int i=0; i<10; i++) vis[i]=true;}
  if(key=='M') {}
  if(key=='N') {M.next();}
  if(key=='O') {}
  if(key=='P') {}
  if(key=='Q') {exit();}
  if(key=='R') {}
  if(key=='S') {M.swing();}
  if(key=='T') {}
  if(key=='U') {}
  if(key=='V') {} 
  if(key=='W') {M.saveMeshVTS();}
  if(key=='X') {} // drag mesh vertex in xy and neighbors (mouseDragged)
  if(key=='Y') {M.refine(); M.makeAllVisible();}
  if(key=='Z') {} // drag mesh vertex in xz and neighbors (mouseDragged)

  if(key=='`') {M.perturb();}
  if(key=='~') {showSpine=!showSpine;}
  if(key=='!') {snapping=true;}
  if(key=='@') {}
  if(key=='#') {}
  if(key=='$') //{M.moveTo(C.Pof(10));} // ???????
  if(key=='%') {}
  if(key=='&') {}
  if(key=='*') {sampleDistance*=2;}
  if(key=='(') {}
  if(key==')') {showSilhouette=!showSilhouette;}
  if(key=='_') //{M.flatShading=!M.flatShading;}
  if(key=='+') {M.flip();} // flip edge of M
  if(key=='-') {M.showEdges=!M.showEdges;}
  if(key=='=') //{C.P[5].set(C.P[0]); C.P[6].set(C.P[1]); C.P[7].set(C.P[2]); C.P[8].set(C.P[3]); C.P[9].set(C.P[4]);}
  if(key=='{') {showFrenetQuads=!showFrenetQuads;}
  if(key=='}') {}
  if(key=='|') {}
  if(key=='[') {initView(); F.set(M.Cbox); E.set(P(F,M.rbox*2,K));}
  if(key==']') {F.set(M.Cbox);}
  if(key==':') {translucent=!translucent;}
  if(key==';') {showControl=!showControl;}
  if(key=='<') {}
  if(key=='>') {if (shrunk==0) shrunk=1; else shrunk=0;}
  if(key=='?') {showHelpText=!showHelpText;}
    if(key=='.') {
    numRotations++;
    s.curves.clear();
    s.curves.add(polygon);
    s.rotationalSweep(numRotations);
  } // pick corner
  if(key==',') {
    if(numRotations>2){
    numRotations--;
    s.curves.clear();
    s.curves.add(polygon);
    s.rotationalSweep(numRotations);
    }
  }
  if(key=='^') {} 
  if(key=='/') {} 
  if(key==' ') {
    //s=s.rotationalSweep(polygon,0,0,PI,matrix);
    println("Spacebar Pressed");
    test.runTests();
    testBoolean=!testBoolean;
  } // pick focus point (will be centered) (draw & keyReleased)

  if(key=='0') {w=0;}
//  for(int i=0; i<10; i++) if (key==char(i+48)) vis[i]=!vis[i];
  
} //------------------------------------------------------------------------ end keyPressed

float [] Volume = new float [3];
float [] Area = new float [3];
float dis = 0;
  
Boolean prev=false;

void showGrid(float s) {
  for (float x=0; x<width; x+=s*20) line(x,0,x,height);
  for (float y=0; y<height; y+=s*20) line(0,y,width,y);
}
  
  // Snapping PICTURES of the screen
PImage myFace; // picture of author's face, read from file pic.jpg in data folder
int pictureCounter=0;
Boolean snapping=false; // used to hide some text whil emaking a picture
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); snapping=false;}
void computePolygon(){//used for loading and subdividing curve
  controlPoints.loadPts();
  polygon.deepCopy(controlPoints);
}//End of computePolygon

 

