class Solid{
  int k;//number of edges for computing rotational sweeps
  float d;//orientation of solid with respect to x axis
  ArrayList <Curve> curves;
  vec I,J,K;
  Solid(Curve p){//Curve p, int k, float d, float angle){
     curves=new ArrayList<Curve>();
     curves.add(p);
   
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
 String toString(){
   String ret="";
   for(int i=0;i<curves.size();i++){
    ret=curves.get(i).toString()+"\n"; 
   }
    return ret; 
    
  }
  void createTriangleMesh(){
   //need to implement 
    
  }
  /*void setP(Curve p){
    p.deepCopy(p);
  }*/
 // void setOrientation(float d){
   // this.d=d; 
 // }
 /* void setAngle(float angle){
   this.angle=angle; 
  }*/
  //void setK(int k){
   //this.k=k; 
 // }
  void draw(){
    for(int i=0;i<curves.size();i++){
      curves.get(i).drawPoints();
      curves.get(i).briansDraw();
    } 
  }
  /*void generateQuadVertices(){
    for(int i=0;i<curves.size();i++){
      for(int j=0;j<curves.get(i).size();j++){
          //if(curves.)
      } 
    }
  }*/
  void calculateJ(){
    
    J=R(this.I).normalize();
  }
  void calculateI(){
   I=curves.get(0).orientationVec().normalize(); 
  }
  void calculateK(){
   K= N(J,I).normalize();
  }
  void incrementIX(){
    I.x++; 
  }
  void incrementIY(){
   I.y++; 
  }
  void decrementIX(){
   I.x--; 
  }
  void decrementIY(){
   I.y--;
  }
  void orientTo(vec newOr){
    //normalize our new orientation vector
    newOr = newOr.normalize();
    //determine if we're rotating about J or K
    float jangle = (angle(newOr,this.J)-angle(this.I,this.J));
    float kangle = (angle(newOr,this.K)-angle(this.I,this.K));
    fourDPoint pt=new fourDPoint();
    //rotating about J 
    if( jangle != 0.0){
      RotateMatrix orientRotate = new RotateMatrix();
      orientRotate.computeOrientationRotate(jangle,this.J.normalize());
      for(int i=0; i<curves.size(); i++){
        for(int j=0; j<curves.get(i).pts.size(); j++){
          pt.setPt(curves.get(i).pts.get(j));
          pt temp = orientRotate.matrixMultiplication(pt).toPt();
          curves.get(i).pts.set(j,temp);
        }
      }
      //this.K = N(J,I).normalize();
          
    }
    //rotating about K
    else{
      RotateMatrix orientRotate = new RotateMatrix();
      print(kangle+"\n");
      orientRotate.computeOrientationRotate(kangle,this.K.normalize());
      print(orientRotate.toString()+"\n");
      for(int i=0; i<curves.size(); i++){
        for(int j=0; j<curves.get(i).pts.size(); j++){
          pt.setPt(curves.get(i).pts.get(j));
          pt temp = orientRotate.matrixMultiplication(pt).toPt();
          curves.get(i).pts.set(j,temp);
        }
      }
      //double check this to make sure we arent switching vector directions
      //this.J = N(K,I).normalize();
    }
    this.I = newOr;
  }
    
    

}
