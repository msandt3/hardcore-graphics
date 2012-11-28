float w=0;
class Curve {
  int n=0;                            // current number of control points
  pt [] P = new pt[5000];            //  array of points
  ArrayList<pt> pts = new ArrayList<pt>(5000);
   
  vec [] Nx = new vec[5000];          // twist free normal vectors 
  vec [] Ny = new vec[5000];          // twist free binormal vectors
  vec [] Nfx = new vec[5000];          // Frenet normal vectors
  vec [] Nfy = new vec[5000];          // Frenet normal vectors
  float [] twist = new float[5000];       // angle between Frenet and twist-free normal
  float [] curvature = new float[5000];   // curvature between Frenet and twist-free normal
  float [] curv = new float[5000];   // curvature between Frenet and twist-free normal
  
  vec [] L = new vec[5000];          // Laplace vectors for smoothing
  int p=0;                          // index to the currently selected vertex being dragged
  Curve(int pn) {n=pn; declarePoints();}
  Curve(int pn, float r) {n=pn; declarePoints(); resetPoints(r); }
  Curve(int pn, float r, pt Q) {n=pn; declarePoints(); resetPoints(r,Q); }
  Curve() {declarePoints(); resetPoints(); }
  int next(int j) {  return min(n-1,j+1); }  // next point 
  int prev(int j) {  return max(0,j-1); }   // previous point                                                      
  void pp() {p=prev(p);}
  void np() {p=next(p);}
  pt Pof(int p) {return pts.get(p);}
  pt lastP(){
    return pts.get(pts.size()-1);
  }
  pt nextP(pt P){
     int vertex= closestVertexID(P);
    if(vertex==pts.size()-1)
      return pts.get(pts.size()-1);
    return pts.get(closestVertexID(P)+1);
  }
  
  pt prevP(pt P){
    int vertex= closestVertexID(P);
    if(vertex==0)
      return pts.get(0);
  return pts.get(closestVertexID(P)-1);  
}
  int numPts(){
    return pts.size();
  }
  pt getPtAtIndex(int i){
    return pts.get(i);
  }
  pt cP() {return pts.get(p);}
  pt pP() {return pts.get(prev(p));}
  pt nP() {return pts.get(next(p));}
  void declarePoints() {for (int i=0; i<pts.size(); i++) {pts.set(i,P()); Nfx[i]=V(); Nfy[i]=V(); Nx[i]=V(); Ny[i]=V();} }  // allocates space
  void resetPoints() {
    float r=100; 
    for (int i=0; i<n; i++) {
      pt temp = pts.get(i);
      temp.x=r*cos(TWO_PI/n);
      temp.y=r*sin(TWO_PI/n);
      pts.set(i,temp);
    }
  } // init the points to be on a circle
  void resetPoints(float r) {
    //println(">>n="+n);
    for (int i=0; i<n; i++) {
      pt temp = pts.get(i);
      temp.x=r*cos(TWO_PI/n);
      temp.y=r*sin(TWO_PI/n);
      pts.set(i,temp);
    }
  } // init the points to be on a circle
  void resetPoints(float r, pt Q) {
    println(">>n="+n); 
    for (int i=0; i<n; i++) {
      pt temp = pts.get(i);
      temp.x=r*cos(TWO_PI/n);
      temp.y=r*sin(TWO_PI/n);
      temp.add(Q);
      pts.set(i,temp);
    }
  } // init the points to be on a circle
  Curve empty(){ n=0; pts.clear(); return this; };      // resets the vertex count to zero
  void pick(pt M) {
    p=0; 
    for (int i=1; i<n; i++){
      if (d(M,pts.get(i))<d(M,pts.get(p))) 
        p=i;
    }
  }
  void dragPoint(vec V) {
    pt temp = P(pts.get(p));
    if(temp.add(V).x >= 0){
      pts.get(p).add(V);
    }
  }
  void dragAll(vec V) {
    for (int i=0; i<n; i++)
      pts.get(i).add(V);
  }
  void dragAll(int s, int e, vec V) {
    for (int i=s; i<e+1; i++) 
      pts.get(i).add(V);
  }
  void movePointTo(pt Q) {
    pts.get(p).set(Q);
  }
  Curve append(pt Q)  {
    if(n+1 < P.length) { 
      p=n; 
      pts.get(n++).set(Q); 
    } 
    return this; 
  } // add point at end of list
  
  void delete() { 
    for (int i=p; i<n-1; i++) 
      pts.get(i).set(pts.get(next(i))); 
    n--; 
    p=prev(p);
  }
  
  void insert() { // inserts after p
    if(p==n-1) {
      pts.get(n).set(pts.get(n-1)); 
      p=n; 
      n++; 
    } 
    else {
      for (int i=n-1; i>p; i--) P[i+1].set(P[i]); 
      n++;  
      pts.get(p+1).set(pts.get(p)); 
      p=p+1; 
    }
  };
  void insert(pt M) {                // grabs closeest vertex or adds vertex at closest edge. It will be dragged by te mouse
     p=0; 
     for (int i=0; i<n; i++){
       if (d(M,pts.get(i))<d(M,pts.get(p))) 
         p=i; 
     }
     
     pts.add(p,M);

  }
   
  Curve makeFrom(Curve C, int v) {
    empty(); 
    for(float t=0; t<=1.001; t+=.1/v) 
      append(C.interpolate(t)); 
    return this;
  }
  pt interpolate(float t) { 
    return D(pts.get(0),pts.get(1),pts.get(2),pts.get(3),pts.get(4),t); 
  }

  Curve drawEdges() {
    beginShape(); 
    for (int i=0; i<pts.size(); i++)
      vertex(pts.get(i)); 
    endShape(); 
    return this;
  }  // fast draw of edges
  
  Curve showSamples() {
    for (int i=0; i<pts.size(); i++)
      show(pts.get(i),1); 
    return this;
  }  // fast draw of edges
  
  Curve showSamples(float r) {
    for (int i=0; i<pts.size(); i++)
      show(pts.get(i),r); 
    return this;
  }  // fast draw of edges
  void showPick() {show(pts.get(p),2); }  // fast draw of edges
  
  void cloneFrom(Curve D) {
    for (int i=0; i<max(n,D.n); i++) 
      pts.get(i).set(D.pts.get(i)); 
      n=D.n;
  }
  pt pt(int i) {
    return pts.get(i);
  }
  void showLoop() { 
    noFill();
    stroke(orange);
    drawEdges();
    noStroke();
    fill(orange);
    showSamples(); 
  }
  void briansDraw(){
    
    stroke(blue);
    noFill();
    for(int i=0;i<pts.size()-1;i++){
       line(pts.get(i).x,pts.get(i).y,pts.get(i).z,pts.get(i+1).x,pts.get(i+1).y,pts.get(i+1).z);
    }
  }  
  int indexOf(pt M){
   for(int i=0;i<pts.size();i++){
    if(M==pts.get(i))
      return i;
   } 
   return -1;
    
  }
  int closestVertexID(pt M) {
    int v=0; 
    for (int i=1; i<pts.size(); i++) 
    if (d(M,pts.get(i))<d(M,pts.get(v)))
      v=i;
    if(v>=this.pts.size()){
      return -1;
    }
    return v;
  }
  pt ClosestVertex(pt M) {
    pt R=pts.get(0); 
    for (int i=1; i<n; i++){ 
      if (d(M,pts.get(i))<d(M,R)) 
        R=pts.get(i);
    }
    return P(R);
  }
  void pickPoint(pt M){
    //pt R=pts.get(0); 
    p=-1;
    for (int i=0; i<pts.size(); i++){ 
      if (d(M,pts.get(i))<10) {
        p=i;
        return;
      }
    }
  }
  float distanceTo(pt M) {
    float md=d(M,pts.get(0));
    for (int i=1; i<n; i++)
      md=min(md,d(M,pts.get(i)));
    return md;
  }
  void savePts() {savePts("data/P.pts");}
  
  void savePts(String fn) { String [] inppts = new String [n+1];
    int s=0; inppts[s++]=str(n); 
    for (int i=0; i<n; i++) {inppts[s++]=str(pts.get(i).x)+","+str(pts.get(i).y)+","+str(pts.get(i).z);};
    saveStrings(fn,inppts);  };
  void loadPts() {loadPts("data/P.pts");
      
}
   
  void loadPts(String fn) { String [] ss = loadStrings(fn);
    String subpts;
    int s=0; int comma1, comma2; n = int(ss[s]);
   // println(n);
  //  println(pts.size());
    for(int i=0; i<n; i++) { 
      String S =  ss[++s];
      comma1=S.indexOf(',');
      float x=float(S.substring(0, comma1));
      String R = S.substring(comma1+1);
      comma2=R.indexOf(',');      
      float y=float(R.substring(0, comma2)); 
      float z=float(R.substring(comma2+1));
      pts.add(P(x,y,z));  
      }
    }
  void addDif(Curve R, Curve C) {for(int i=0;i<n; i++) pts.get(i).add(V(R.pt(i),C.pt(i)));}    
  float length () {float L=0; for (int i=0; i<n; i++) L+=d(pts.get(i),pts.get(next(i)));  return(L); }    

// ******************************************************************************************** LACING ***************
  Curve resampleDistance(float r) { 
    Curve NL = new Curve();
    NL.append(pts.get(0));          if (n<3) return NL;
    pt C = new pt();
    C.set(pts.get(0));
    int i=0; 
    Boolean go=true;
    while(go) {
      int j=i; while(j<n && d(P[j+1],C)<r) j++; // last vertex in sphere(C,r);
      if(j>=n-1) go=false; 
      else {
        pt A=pts.get(j), B=pts.get(j+1); 
        float a=d2(A,B), b=d(V(C,A),V(A,B)), c=d2(C,A)-sq(r);  
        float s=(-b+sqrt(sq(b)-a*c))/a; 
        C.set(P(A,s,B)); 
        NL.append(C);
        i=j;           
        }
      }
    return NL;
    }
   void deepCopy(Curve c){
     this.pts.clear();
     for(int i=0;i<c.pts.size();i++){
       pts.add(c.pts.get(i));
    } 
     
   }
  void resample(int nn) { // resamples the curve with new nn vertices
    if(nn<3) return;
    float L = length();  // current total length  
    float d = L / nn;   // desired arc-length spacing                        
    float rd=d;        // remaining distance to next sample
    float cl=0;        // length of remaining portion of current edge
    int k=0,nk;        // counters
    pt [] R = new pt [nn]; // temporary array for the new points
    pt Q;
    int s=0;
    Q=pts.get(0);         
    R[s++]=P(Q);     
    while (s<nn) {
       nk=next(k);
       cl=d(Q,P[nk]);                            
       if (rd<cl) {Q=P(Q,rd,pts.get(nk)); R[s++]=P(Q); cl-=rd; rd=d; } 
       else {rd-=cl; Q.set(pts.get(nk)); k++; };
       };
     n=s;   for (int i=0; i<n; i++)  pts.set(i,R[i]);
   }
   void changeCurve(pt A){
    pts.clear(); 
    this.loadPts();
    
    pts.add(A);
    
   
   }
   void save() {
    String savePath = selectOutput("Select or specify .pts file where the curve points will be saved");  // Opens file chooser
    if (savePath == null) {println("No output file was selected..."); return;}
    else println("writing curve to "+savePath);
    save(savePath);
    }

  void save(String fn) {
    String [] inppts = new String [n+1];
    int s=0;
    inppts[s++]=str(n);
    for (int i=0; i<n; i++) {inppts[s++]=str(pts.get(i).x)+","+str(pts.get(i).y)+","+str(pts.get(i).z);};
    saveStrings(fn,inppts);  
    };
  
  void load() {
    String loadPath = selectInput("Select .pts file to load for the curve");  // Opens file chooser
    if (loadPath == null) {println("No input file was selected..."); return;}
    else println("reading curve from "+loadPath); 
    load(loadPath);
    }

  void load(String fn) {
    println("loading curve: "+fn); 
    String [] ss = loadStrings(fn);
    String subpts;
    int s=0;   int comma1, comma2;   float x, y, z;   
    n = int(ss[s++]);
    println("n="+n);
    for(int k=0; k<n; k++) {
      int i=k+s; 
      comma1=ss[i].indexOf(',');   
      x=float(ss[i].substring(0, comma1));
      String rest = ss[i].substring(comma1+1, ss[i].length());
      comma2=rest.indexOf(',');    y=float(rest.substring(0, comma2)); z=float(rest.substring(comma2+1, rest.length()));
      pts.set(k,P(x,y,z));
      //      println(k+":"+"("+x+","+y+","+z+"),");
      };
      println("done loading");  
    }; 
  
   /// ******************************** compute normals *******************************************************
   Curve computeFirstTwistFreeNormal() {
     vec V=V(pts.get(0),pts.get(1)); vec I=V(1,0,0); vec J=V(0,1,0); vec VxI = N(V,I); vec VxJ = N(V,J); 
     if (VxI.norm() > VxJ.norm()) Nx[0]=U(N(VxI,V)); else Nx[0]=U(N(VxJ,V));
     return this;}
     
   Curve computeTwistFreeNormals() {
     pt Q=P(pts.get(0),50,Nx[0]);
     for(int i=1; i<n-1; i++) {vec BD=V(pts.get(i-1),pts.get(i+1)); float s=d(V(Q,pts.get(i)),BD)/d(V(pts.get(i-1),pts.get(i)),BD); Q=P(Q,s,V(pts.get(i-1),pts.get(i))); Nx[i]=U(pts.get(i),Q);}
     Nx[n-1]=Nx[n-2];
     return this;}
 
   Curve computeTwistFreeBiNormals() {
     for(int i=1; i<n-1; i++) {vec T=V(pts.get(i-1),pts.get(i+1)); Ny[i]=U(N(Nx[i],T)); }
     Ny[0]=U(N(Nx[0],V(pts.get(0),pts.get(1))));
     Ny[n-1]=U(N(Nx[n-1],V(pts.get(n-2),pts.get(n-1))));
     return this;}
     
   Curve rotateFirstTwistFreeNormal(float ang) {
     vec N=Nx[0];
     vec T=U(pts.get(0),pts.get(1));
     vec B=U(N(N,T));
     N.rotate(ang,N,B);
     return this;} 
 
  Curve prepareSpine(float ang) {   
    computeFirstTwistFreeNormal();
    rotateFirstTwistFreeNormal(ang);
    computeTwistFreeNormals();
    computeTwistFreeBiNormals();
    return this;}
    
  void showTube(float r, int ne, int nq, color col) {
      pt [][] C = new pt [2][ne];
      boolean dark=true;
      // make circle in local cross section
      float [] c = new float [ne]; float [] s = new float [ne];
      for (int j=0; j<ne; j++) {c[j]=r*cos(TWO_PI*j/ne); s[j]=r*sin(TWO_PI*j/ne); };    
      int p=0; 
      for (int j=0; j<ne; j++) C[p][j]=P( pts.get(0) , c[j],Nx[0], s[j],Ny[0] ); p=1-p;
      noStroke();
      for (int i=1; i<n-1; i++) {
        if(i%nq==0) dark=!dark; 
        for (int j=0; j<ne; j++) C[p][j]=P( pts.get(1), c[j],Nx[i], s[j],Ny[i]); p=1-p;
        if(i>0) for (int j=0; j<ne; j++) {
            if(dark) fill(200,200,200); else fill(col); dark=!dark; 
            int jp=(j+ne-1)%ne; beginShape(); v(C[p][jp]); v(C[p][j]); v(C[1-p][j]); v(C[1-p][jp]); endShape(CLOSE);};
        }        
      }

  vec II = V(1,0,0), JJ = V(0,1,0);
 Curve subdivision(){
    pt []temp= new pt[5000];
    ArrayList<pt> temp2 = new ArrayList<pt>(5000);
    for(int i=0; i<pts.size()*2-1; i++)
      temp2.add(null);
    
    int length = pts.size()*2-1;
  for (int i=0; i<length; i++){
    int j=i/2;
    if(i%2==0){ 
     temp2.set(i,this.pts.get(j));
    }
    else{
      if(i==1){
        temp2.set(i,P(normalNeville(pts.get(0),pts.get(0),pts.get(1),-1,0,1,.5),normalNeville(pts.get(2),pts.get(1),pts.get(0),-1,0,1,.5)));
      }
      else if(i==length-2){
        temp2.set(i,P(normalNeville(pts.get(j-1),pts.get(j),pts.get(j+1),-1,0,1,.5),normalNeville(pts.get(j+1),pts.get(j+1),pts.get(j),-1,0,1,.5)));
      }
      else{
        temp2.set(i,P(normalNeville(pts.get(j-1),pts.get(j),pts.get(j+1),-1,0,1,.5),normalNeville(pts.get(j+2),pts.get(j+1),pts.get(j),-1,0,1,.5)));
      }
    }
  }
  pts = temp2;
  n = n*2-1;
  return this;
}
void drawPoints(){
   for(int i=0;i<pts.size();i++){
      pushMatrix();
      noStroke();
      fill(red);
      translate(pts.get(i).x,pts.get(i).y,pts.get(i).z); 
      sphereDetail(15,15);
      sphere(10);
      popMatrix();
   } 
  
}

pt normalNeville(pt A, pt B, pt C, float tA, float tB, float tC, float t){
    float normalizedA= (t-tA)/(tB-tA);
    float normalizedB= (t-tB)/(tC-tB);
    float normalizedC= (t-tA)/(tC-tA);
    pt P=P(A,normalizedA,B); 
    pt Q=P(B,normalizedB,C); 
    return P(P,normalizedC,Q); 
}
vec orientationVec(){
  return V(pts.get(pts.size()-1),pts.get(0));
  //Need to normalize
}
String toString(){
    String ret="";
    for(int i=0;i<pts.size();i++){
       ret+=pts.get(i).toString()+"\n";
    }
    return ret;
}
  Curve toLocalCurve(vec I, vec J, vec K, pt O){
    Curve temp= new Curve();
     for(int i=0;i<pts.size();i++){
       temp.pts.add(this.pts.get(i).toLocalPt(I,J,K,O)); 
     }
     return temp;
  }
  Curve toGlobalCurve(vec I,vec J,vec K, pt O){
    Curve temp = new Curve();
    for(int i=0;i<pts.size();i++){
      temp.pts.add(this.pts.get(i).toGlobalPt(I,J,K,O));
    }
    return temp;
  }
  vec calculateJ(){
    return R(this.calculateI()).normalize();
  }
  vec calculateI(){
   return orientationVec().normalize(); 
  }
  vec calculateK(){
   return N(calculateJ(),calculateI()).normalize();
  }
  Curve makeConvex() {
    ArrayList<pt> convexHull = new ArrayList<pt>();
    pt pointOnHull = pts.get(0);
    pt endPoint;
    int i = 0;
    do {
      convexHull.add(pointOnHull);
      endPoint = pts.get(0);
      for (int j = 1; j < pts.size(); j++) {
        if (endPoint == pointOnHull || isLeft(convexHull.get(i), endPoint, pts.get(j))) {
          endPoint = pts.get(j);
        }
      }
      i++;
      pointOnHull = endPoint;
    } while (endPoint != pts.get(0));

    empty();
    for (pt p : convexHull) {
      pts.add(p);
    }
    
    return this;
  }
};  // end class Curve
