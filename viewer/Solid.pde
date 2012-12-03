class Solid{
  int k;//number of edges for computing rotational sweeps
  float d;//orientation of solid with respect to x axis
  ArrayList <Curve> curves;
  vec I,J,K;
  pt origin = new pt(0, 0, 0);
  Solid(Curve p){//Curve p, int k, float d, float angle){
     curves=new ArrayList<Curve>();
     curves.add(p);
     this.I=new vec(1,0,0);
     this.J=V(p.pts.get(p.pts.size()-1),p.pts.get(0)).normalize();
     this.K=new vec(0,0,1);
     //origin
  }
  Solid(){
    curves=new ArrayList<Curve>();
    //this.I=new vec(1,0,0);
    //this.J=new vec(0,1,0);
    //this.K=new vec(0,0,1);
  }
  void rotationalSweep(int k){
    //need to implement
    this.k = k;
    fourDPoint pt=new fourDPoint();
    matrix.computeYRotate(2*PI/k);
    Curve temp;
    int i=1;
    while(i<k){
      temp=new Curve();
      for(int j=0;j<curves.get(i-1).pts.size();j++){
        pt.setPt(curves.get(i-1).pts.get(j));
        temp.pts.add(matrix.matrixMultiplication(pt).toPt());
      }
    curves.add(temp);
    i++;
    }
  }
 void setOrigin(pt O){
  this.origin=O; 
 }
 String toString(){
   String ret="";
   for(int i=0;i<curves.size();i++){
    ret+=curves.get(i).toString()+"\n"; 
   }
   ret+="I: "+this.I+"\n";
   ret+="J: "+this.J+"\n";
   ret+="K: "+this.K+"\n";
   ret+="origin: "+this.origin+"\n";
   ret+="k: "+this.k;
    return ret; 
    
  }
  void draw(){
    for(int i=0;i<curves.size();i++){
     // curves.get(i).drawPoints();
      curves.get(i).briansDraw();
    } 
  }
  void calculateJ(){
    J=R(this.I).normalize();
  }
  void calcJ(){
     J=R(this.I,90.0,this.I,this.I);
  }
  void calculateI(){
     this.I=curves.get(0).orientationVec().normalize(); 
  }
  void calculateK(){
     this.K= N(J,I).normalize();
  }
  void incrementIX(){
    this.I.x+=1.0;
   // this.I.normalize(); 
  }
  void incrementIY(){
   this.I.y+=1.0; 
   //this.I.normalize();
  }
  void decrementIX(){
   this.I.x-=1.0; 
 //  this.I.normalize();
  }
  void decrementIY(){
   this.I.y-=1.0;
   //this.I.normalize();
  }
  void incrementIZ(){
    this.I.z+=1.0;
  }
  void decrementIZ(){
    this.I.z-=1.0;
  }
    void incrementKX(){
    this.K.x+=1.0;
   // this.I.normalize(); 
  }
  void incrementKY(){
   this.K.y+=1.0; 
   //this.I.normalize();
  }
  void decrementKX(){
   this.K.x-=1.0; 
 //  this.I.normalize();
  }
  void decrementKY(){
   this.K.y-=1.0;
   //this.I.normalize();
  }
     void incrementJZ(){
    this.J.z+=1.0;
   // this.I.normalize(); 
  }
  void incrementJY(){
   this.J.y+=1.0; 
   //this.I.normalize();
  }
  void decrementJZ(){
   this.J.z-=1.0; 
 //  this.I.normalize();
  }
  void decrementJY(){
   this.J.y-=1.0;
   //this.I.normalize();
  }
  Solid toLocalSolid(vec I, vec J, vec K, pt O){
    Solid temp= new Solid();
    for(int i=0; i<curves.size();i++){
     temp.curves.add(this.curves.get(i).toLocalCurve(I,J,K,O));
    }
     temp.origin=this.origin;
    return temp;
  }
 Solid toLocalSolid(){
    Solid temp= new Solid();
    for(int i=0; i<curves.size();i++){
     temp.curves.add(this.curves.get(i).toLocalCurve(this.I,this.J,this.K,this.origin));
    }
    temp.origin=this.origin;
    temp.k=this.k;
    return temp;
  }
  Solid toGlobalSolid(vec I, vec J, vec K, pt O){
    Solid temp= new Solid();
    for(int i=0; i<curves.size();i++){
     temp.curves.add(this.curves.get(i).toGlobalCurve(I,J,K,O));
    }
    temp.I= I.normalize();
    temp.J= J.normalize();
    temp.K= K.normalize();
    temp.origin= this.origin;
    temp.k=this.k;
    return temp;
  } 
  Solid set(Solid t){
   this.curves=t.curves;
   this.origin=t.origin;
   this.I=t.I;
   this.J=t.J;
   this.K=t.K; 
   this.k=t.k;
   return this;
  }
  Solid copyPts(Solid s){
   this.curves.clear();
    for(int i=0;i<s.curves.size();i++){
     this.curves.add(s.curves.get(i));
    } 
    return this;
  }
  void readyToDraw(Curve c){ 
    Curve tempy= new Curve();
    tempy.deepCopy(c);
    curves.clear();
    curves.add(tempy);
    pt tempOrigin = curves.get(0).pts.get(curves.get(0).pts.size()-1);
    this.rotationalSweep(this.k);
    vec dV= V(tempOrigin,this.origin);
    this.translate(dV);

  }
  void translate(vec delta){
    pt tempPt;
    for(int i=0; i<curves.size();i++){
      for(int j=0;j<curves.get(i).pts.size();j++){
        tempPt=this.curves.get(i).pts.get(j);
        curves.get(i).pts.set(j,P(tempPt,delta));
      }
    } 
  }
  void save(){
    String savePath = selectOutput("Select or specify .pts file where the curve points will be saved");  // Opens file chooser
    if (savePath == null) {println("No output file was selected..."); return;}
    else println("writing curve to "+savePath);
    save(savePath);
  }
  void save(String fn){
    int curvesSize = curves.size();
    int ptsSize = curves.get(0).pts.size();

    String[] input = new String[(curvesSize*(ptsSize+1))+2];
    int s = 0;
    input[s++] = str(curves.size());
    input[s++] = str(ptsSize);
    int curveI = 0;
    ArrayList<String> stringList;
    for(Curve c : curves){
      stringList = c.getSaveString();
      input[s++] = str(curveI);

      for(String s1 : stringList){
        println("String for curve "+s1);
        input[s++] = s1;
      }
      curveI++;
    }
    saveStrings(fn,input);
  }

  void load(String fn){
    String[] inputs = loadStrings(fn);
    int s = 0;
    int numCurves = Integer.parseInt(inputs[s++]);
    int numPts = Integer.parseInt(inputs[s++]);

    for(int i=0; i<numCurves; i++){
      Curve temp = new Curve();
      int curveIndex = Integer.parseInt(inputs[s++]);
      for(int j=0; j<numPts; j++){
        //compute the x value of the curve point
        String ptString = inputs[s++];
        println(ptString);
        int comma1 = ptString.indexOf(',');
        float x = float(ptString.substring(0,comma1));
        //compute the y value of the curve point
        String ptString2 = ptString.substring(comma1+1);
        int comma2 = ptString2.indexOf(',');
        float y = float(ptString2.substring(0,comma2));
        //compute the z value of the curve point
        float z = float(ptString2.substring(comma2+1));
        temp.pts.add(P(x,y,z));
        //curves.get(curveIndex).pts.add(P(x,y,z));
      }
      this.curves.add(temp);
    }
    //book keeping to ensure data for solid is maintained correctly
    this.k = numCurves;
    this.I = V(1,0,0);
    this.J = V(0,1,0);
    this.K = V(0,0,1);
    this.origin = curves.get(0).pts.get(numPts-1);
  }
  void drawOrientationVectors(){
    stroke(red);
    show(this.origin,V(50,this.I));
    stroke(black);
    show(this.origin,V(50,this.J));
    stroke(green);
    show(this.origin,V(50,this.K)); 
  }
}
