
import processing.opengl.*;                // load OpenGL libraries and utilities
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import java.nio.*;
import java.util.Map.Entry;
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
  Boolean drawRotate,edit,edit1,edit2,edit3;
Curve polygon,controlPoints,temp, tempCurve;
Curve editCurve;
Solid editSolid;
RotateMatrix matrix;
Solid s,s1,s2,s3;
int numRotations;
 Test test;
  float time = 0.0,
        deltaT = 0.01;
// String SCC = "-"; // info on current corner
   
// ****************************** VIEW PARAMETERS *******************************************************
pt F = P(0,0,0); pt T = P(0,0,0); pt E = P(0,0,1000); vec U=V(0,1,0);  // focus  set with mouse when pressing ';', eye, and up vector
pt Q=P(0,0,0); vec I=V(1,0,0); vec J=V(0,1,0); vec K=V(0,0,1); // picked surface point Q and screen aligned vectors {I,J,K} set when picked
void initView() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,0,1500); U=V(0,1,0); } // declares the local frames

// ******************************** MESHES ***********************************************
Mesh M=new Mesh(),
     M1=new Mesh(),
     M2=new Mesh(),
     M3=new Mesh(); // meshes for models M0 and M1

float volume1=0, volume0=0;
float sampleDistance=1;
// ******************************** CURVES & SPINES ***********************************************
//Curve C0 = new Curve(5), S0 = new Curve(), C1 = new Curve(5), S1 = new Curve();  // control points and spines 0 and 1
//Curve C= new Curve(11,130,P());
int nsteps=250; // number of smaples along spine
float sd=10; // sample distance for spine
pt sE = P(), sF = P(); vec sU=V(); //  view parameters (saved with 'j'
pt O;
boolean mainView;
ArrayList<Curve> orientationTest;
int counter;
Solid testSolid;
Curve sCurve, s1Curve,s2Curve,s3Curve;


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
  sCurve=new Curve();
  sCurve.loadPts();
 
  matrix=new RotateMatrix();
  temp=new Curve();
  drawRotate=false;
  s=new Solid(sCurve);
  s.k=5;
  s.setOrigin(new pt(-500,200,0));
  s.readyToDraw(sCurve);
  O =s.curves.get(0).pts.get(s.curves.get(0).pts.size()-1);
  //println("SCURVE1: "+sCurve);
   mainView=true;
   //Create solids
   s1Curve=new Curve();
   s1Curve.loadPts("data/P1.pts");
   s1=new Solid(s1Curve);
   s1.setOrigin(new pt(-250,-400,0));
   s1.k=4;
   s1.readyToDraw(s1Curve);
   
 
   s2Curve=new Curve();
   s2Curve.loadPts("data/P2.pts");
   s2=new Solid(s2Curve);
   s2.setOrigin(new pt(100,-400,0));
   s2.k=6;
   s2.readyToDraw(s2Curve);

   s3Curve=new Curve();
   s3Curve.loadPts("data/P3.pts");
   s3=new Solid(s3Curve);
   s3.setOrigin(new pt(400,200,0));
   s3.k=8;
   s3.readyToDraw(s3Curve);

  M.declareVectors();
  M1.declareVectors();
  M2.declareVectors();
  M3.declareVectors();

   generateMeshes();
   M.map(0, M1);

   //initSolids();
   edit=false;
   edit1=false;
   edit2=false;
   edit3=false;
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
   if(edit){
    sCurve.briansDraw();
    sCurve.drawPoints();
   }
   else if(edit1){
    s1Curve.briansDraw();
    s1Curve.drawPoints(); 
   }
   else if(edit2){
    s2Curve.briansDraw();
    s2Curve.drawPoints(); 
   }
   else if(edit3){
    s3Curve.briansDraw();
    s3Curve.drawPoints(); 
   }
  // -------------------------------------------------------- 3D display : set up view ----------------------------------
  camera(E.x, E.y, E.z, F.x, F.y, F.z, U.x, U.y, U.z); // defines the view : eye, ctr, up
  vec Li=U(A(V(E,F),0.1*d(E,F),J));   // vec Li=U(A(V(E,F),-d(E,F),J)); 
  directionalLight(255,255,255,Li.x,Li.y,Li.z); // direction of light: behind and above the viewer
  specular(255,255,0); shininess(5);
  
  //s.draw();
  //s1.draw();
  //s2.draw();
  //s3.draw(); 

  M.drawMorph(time);

  if(time>=1.0)
    deltaT=-.01;
  else if(time<=0)
    deltaT=.01;
  time+=deltaT;

// -------------------------- display and edit control points of the spines and box ----------------------------------   
    if(pressed) {
         if (keyPressed&&(key=='a')) {//Picks a point on the polygon
           if(edit)
             sCurve.pickPoint(new pt(pmouseX,pmouseY,0));
           else if(edit1)
             s1Curve.pickPoint(new pt(pmouseX,pmouseY,0));
            else if(edit2)
             s2Curve.pickPoint(new pt(pmouseX,pmouseY,0));
            else if(edit3)
             s3Curve.pickPoint(new pt(pmouseX,pmouseY,0));
       }
         if(keyPressed&&(key=='i')){
         }

     }
     
     // -------------------------------------------------------- show mesh ----------------------------------   
   if(showMesh) { 
    fill(yellow); stroke(white);
    M.showFront();
    M1.showFront();
    M2.showFront();
    M3.showFront();
  } 
   
    // -------------------------- pick mesh corner ----------------------------------   
   if(pressed) if (keyPressed&&(key=='.')) M.pickc(Pick());
 
 
     // -------------------------------------------------------- show mesh corner ----------------------------------   
//   if(showMesh) { fill(red); noStroke(); M.showc();} 
 
    // -------------------------------------------------------- edit mesh  ----------------------------------   
  if(pressed) {
   
     if (keyPressed&&(key=='X'||key=='Z')) M.pickc(Pick()); // sets M.sc to the closest corner in M from the pick point
     }
 
  // -------------------------------------------------------- graphic picking on surface and view control ----------------------------------   
 //if (keyPressed&&key==' ') T.set(Pick()); // sets point T on the surface where the mouse points. The camera will turn toward's it when the ';' key is released
  //SetFrame(Q,I,J,K);  // showFrame(Q,I,J,K,30);  // sets frame from picked points and screen axes
  // rotate view 
  if(!keyPressed&&mousePressed) {E=R(E,  PI*float(mouseX-pmouseX)/width,I,K,F); E=R(E,-PI*float(mouseY-pmouseY)/width,J,K,F); } // rotate E around F 
  if(keyPressed&&key=='D'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K); }  //   Moves E forward/backward
  if(keyPressed&&key=='d'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K);U=R(U, -PI*float(mouseX-pmouseX)/width,I,J); }//   Moves E forward/backward and rotatees around (F,Y)
  
  // -------------------------------------------------------- Disable z-buffer to display occluded silhouettes and other things ---------------------------------- 
  hint(DISABLE_DEPTH_TEST);  // show on top
 // stroke(black); if(showControl) {C0.showSamples(2);}
  if(showMesh&&showSilhouette) {stroke(dbrown); M.drawSilhouettes(); }  // display silhouettes
  //strokeWeight(2); stroke(red);if(showMesh&&showNMBE) M.showMBEs();  // manifold borders
  camera(); // 2D view to write help text
  writeFooterHelp();
  hint(ENABLE_DEPTH_TEST); // show silouettes

  // -------------------------------------------------------- SNAP PICTURE ---------------------------------- 
   if(snapping) snapPicture(); // does not work for a large screen
    pressed=false;
  
} // end draw

void generateMeshes() {
    M.resetCounters();
    M.makeRevolution(s);
    M1.resetCounters();
    M1.makeRevolution(s1);
    M2.resetCounters();
    M2.makeRevolution(s2);
    M3.resetCounters();
    M3.makeRevolution(s3);
}
 
 void regenerateMeshes() {
    generateMeshes();

    M.remap(0);
    //M.map(1, M2);
    //M.map(2, M3);
 }
 
 // ****************************************************************************************************************************** INTERRUPTS
Boolean pressed=false;
void mousePressed() {pressed=true; }
void mouseDragged() {
   if(keyPressed&&key=='a'){
     if(edit&&sCurve.p!=-1){
        if(sCurve.p==0 || sCurve.p==sCurve.pts.size()-1){
          sCurve.dragPoint(V(0,new vec(0,0,0),.5*(mouseY-pmouseY),J));
        }
        else{
            sCurve.dragPoint(V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),J));
        }
       s.readyToDraw(sCurve);
     }
     if(edit1&&s1Curve.p!=-1){
        if(s1Curve.p==0 || s1Curve.p==s1Curve.pts.size()-1){
          s1Curve.dragPoint(V(0,new vec(0,0,0),.5*(mouseY-pmouseY),J));
        }
        else{
         s1Curve.dragPoint(V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),J));
       }
       s1.readyToDraw(s1Curve);
     }
     if(edit2&&s2Curve.p!=-1){
        if(s2Curve.p==0 || s2Curve.p==s2Curve.pts.size()-1){
          s2Curve.dragPoint(V(0,new vec(0,0,0),.5*(mouseY-pmouseY),J));
        }
        else{
         s2Curve.dragPoint(V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),J));
       }
       s2.readyToDraw(s2Curve);
     }
     if(edit3&&s3Curve.p!=-1){
        if(s3Curve.p==0 || s3Curve.p==s3Curve.pts.size()-1){
          s3Curve.dragPoint(V(0,new vec(0,0,0),.5*(mouseY-pmouseY),J));
        }
        else{
         s3Curve.dragPoint(V(.5*(mouseX-pmouseX),I,.5*(mouseY-pmouseY),J));
       }
       s3.readyToDraw(s3Curve);
     }
     //regenerateMeshes();
  } 
  if(keyPressed&&key=='s') {
     
     }
  if(keyPressed&&key=='o'){
     Solid localSolid;
    if(edit){
      println("Solid: "+s);
     localSolid=s.toLocalSolid(s.I,s.J,s.K,s.origin);
     if(mouseX-pmouseX<0){
         s.decrementIX();
      }
     else if(mouseX-pmouseX>0){
       s.incrementIX(); 
     }
     if(mouseY-pmouseY>0){
       s.incrementIY();
     }
     else if(mouseY-pmouseY<0){
      s.decrementIY(); 
     }
     s.I.normalize();
     s.J=N(s.K,s.I).normalize();
     s.copyPts(localSolid.toGlobalSolid(s.I,s.J,s.K,s.origin));
    }
    else if(edit1){
     localSolid=s1.toLocalSolid(s1.I,s1.J,s1.K,s1.origin);
     if(mouseX-pmouseX<0){
         s1.decrementIX();
      }
     else if(mouseX-pmouseX>0){
       s1.incrementIX(); 
     }
     if(mouseY-pmouseY>0){
       s1.incrementIY();
     }
     else if(mouseY-pmouseY<0){
      s1.decrementIY(); 
     }
     s1.I.normalize();
     s1.J=N(s1.K,s1.I).normalize();
     s1.copyPts(localSolid.toGlobalSolid(s1.I,s1.J,s1.K,s1.origin));
    }
    else if(edit2){
     localSolid=s2.toLocalSolid(s2.I,s2.J,s2.K,s2.origin);
     if(mouseX-pmouseX<0){
         s2.decrementIX();
      }
     else if(mouseX-pmouseX>0){
       s2.incrementIX(); 
     }
     if(mouseY-pmouseY>0){
       s2.incrementIY();
     }
     else if(mouseY-pmouseY<0){
      s2.decrementIY(); 
     }
     s2.I.normalize();
     s2.J=N(s2.K,s2.I).normalize();
     s2.copyPts(localSolid.toGlobalSolid(s2.I,s2.J,s2.K,s2.origin));
    }
    else if(edit3){
     localSolid=s3.toLocalSolid(s3.I,s3.J,s3.K,s3.origin);
     if(mouseX-pmouseX<0){
         s3.decrementIX();
      }
     else if(mouseX-pmouseX>0){
       s3.incrementIX(); 
     }
     if(mouseY-pmouseY>0){
       s3.incrementIY();
     }
     else if(mouseY-pmouseY<0){
      s3.decrementIY(); 
     }
     s3.I.normalize();
     s3.J=N(s3.K,s3.I).normalize();
     s3.copyPts(localSolid.toGlobalSolid(s3.I,s3.J,s3.K,s3.origin));
    }
  }  
  if(keyPressed&&key=='p'){
         Solid localSolid;
    if(edit){
     println("Solid: "+s);
     localSolid=s.toLocalSolid(s.I,s.J,s.K,s.origin);
     if(mouseX-pmouseX<0){
         s.decrementJY();
      }
     else if(mouseX-pmouseX>0){
       s.incrementJY(); 
     }
     if(mouseY-pmouseY>0){
       s.incrementJZ();
     }
     else if(mouseY-pmouseY<0){
      s.decrementJZ(); 
     }
     s.J.normalize();
     s.K=N(s.I,s.J).normalize();
     s.copyPts(localSolid.toGlobalSolid(s.I,s.J,s.K,s.origin));
    }
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
  regenerateMeshes();
   //  U.set(M(J)); // reset camera up vector
    }
  
void keyReleased() {
   //if(key==' ') F=P(T);                           //   if(key=='c') M0.moveTo(C.Pof(10));
  // U.set(M(J)); // reset camera up vector
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
  if(key=='s') {
    if(edit){
      sCurve = sCurve.subdivision();
    }else if(edit1){
      s1Curve = s1Curve.subdivision();
    }else if(edit2){
      s2Curve = s2Curve.subdivision();
    }else if(edit3){
      s3Curve = s3Curve.subdivision();
    }
  } //subdivide currently selected control curve
  if(key=='t') {showTube=!showTube;}
  if(key=='u') {}
  if(key=='v') {} // move S2
  if(key=='w') {}
  if(key=='x') {} // drag mesh vertex in xy (mouseDragged)
  if(key=='y') {}
  if(key=='z') {} // drag mesh vertex in xz (mouseDragged)
   
  if(key=='A')// {C.savePts();}
  if(key=='B') {}
  if(key=='C') {
   if(edit) {
     sCurve = sCurve.makeConvex();
     s.readyToDraw(sCurve);
   } else if(edit1) {
     s1Curve.makeConvex();
     s1.readyToDraw(s1Curve);
   } else if(edit2) {
     s2Curve.makeConvex();
     s2.readyToDraw(s2Curve);
   } else if(edit3) {
     s3Curve.makeConvex();
     s3.readyToDraw(s3Curve);
   }
   regenerateMeshes();
  }
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
  if(key=='@') {
  println("s: "+s);
  }
  if(key=='#') {}
  if(key=='$') //{M.moveTo(C.Pof(10));} // ???????
  if(key=='%') {}
  if(key=='&') {}
  if(key=='*') {sampleDistance*=2;}
  if(key=='(') {}
  if(key==')') {showSilhouette=!showSilhouette;}
  if(key=='_') {
    M.flatShading=!M.flatShading;
    M1.flatShading=!M1.flatShading;
    M2.flatShading=!M2.flatShading;
    M3.flatShading=!M3.flatShading;
  }
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
      if(edit){
        s.k++;
        s.readyToDraw(sCurve);
      }
      else if(edit1){
        s1.k++;
        s1.readyToDraw(s1Curve);
      }
      else if(edit2){
        s2.k++;
        s2.readyToDraw(s2Curve);
      }
      else if(edit3){
        s3.k++;
        s3.readyToDraw(s3Curve);
      }
  } // pick corner
  if(key==',') {
    if(edit&&s.k>2){
        s.k--;
        s.readyToDraw(sCurve);
      }
      else if(edit1&&s1.k>2){
        s1.k--;
        s1.readyToDraw(s1Curve);
      }
      else if(edit2&&s2.k>2){
        s2.k--;
        s2.readyToDraw(s2Curve);
      }
      else if(edit3&&s3.k>2){
        s3.k--;
        s3.readyToDraw(s3Curve);
      }
  }
  if(key=='^') {} 
  if(key=='/') {} 
  if(key==' ') {
    edit1=false;
    edit2=false;
    edit3=false;
    edit=false;
   
  } // pick focus point (will be centered) (draw & keyReleased)
  if(key=='1'){
    //set view to curve one editing view
   edit=true;
   edit1=false;
   edit2=false;
   edit3=false;
  }
 if(key=='2'){
  edit1=true;
  edit2=false;
  edit3=false;
  edit=false;
  }
  if(key=='3'){
   edit2=true;
   edit3=false;
   edit=false;
   edit1=false; 
  }
  if(key=='4'){
   edit3=true;
   edit=false;
   edit2=false;
   edit1=false; 
    
  }
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
void initSolids(){

}


 

