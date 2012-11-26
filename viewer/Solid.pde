class Solid{
  int k;//number of edges for computing rotational sweeps
  float d;//orientation of solid with respect to x axis
  ArrayList <Curve> curves;
  vec I,J,K;
  pt origin;
  Solid(Curve p){//Curve p, int k, float d, float angle){
     curves=new ArrayList<Curve>();
     curves.add(p);
     this.I=new vec(1,0,0);
     this.J=new vec(0,1,0);
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
    ret=curves.get(i).toString()+"\n"; 
   }
    return ret; 
    
  }
  void draw(){
    for(int i=0;i<curves.size();i++){
      curves.get(i).drawPoints();
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
   K= N(J,I).normalize();
  }
  void incrementIX(){
    I.x+=.5;
    I.normalize(); 
  }
  void incrementIY(){
   I.y+=.5; 
   I.normalize();
  }
  void decrementIX(){
   I.x-=.5; 
   I.normalize();
  }
  void decrementIY(){
   I.y-=.5;
   I.normalize();
  }
  void incrementIZ(){
    I.z+=1.0;
    I.normalize(); 
  }
  void decrementIZ(){
    I.z-=1.0;
    I.normalize();
  }
  Solid toLocalSolid(vec I, vec J, vec K, pt O){
    Solid temp= new Solid();
    for(int i=0; i<curves.size();i++){
     temp.curves.add(this.curves.get(i).toLocalCurve(I,J,K,O));
    }
    return temp;
  }
 Solid toLocalSolid(){
    Solid temp= new Solid();
    for(int i=0; i<curves.size();i++){
     temp.curves.add(this.curves.get(i).toLocalCurve(this.I,this.J,this.K,this.origin));
    }
    temp.origin=this.origin;
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
    return temp;
  } 
  void set(Solid t){
   this.curves=t.curves;
   this.origin=t.origin;
   this.I=t.I;
   this.J=t.J;
   this.K=t.K; 
   this.k=t.k;
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
   // Solid localSolid= this.toLocalSolid(new vec(1,0,0),new vec(0,1,0),new vec(0,0,1),this.origin);
  //  this.curves = localSolid.toGlobalSolid(this.I,this.J,this.K,this.origin).curves;
    //localSolid= this.toLocalSolid(new vec(1,0,0),new vec(0,1,0),new vec(0,0,1),tempOrigin);
    //this.curves = localSolid.toGlobalSolid(this.I,this.J,this.K,curves.get(0).pts.get(curves.get(0).pts.size()-1)).curves;
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
}
