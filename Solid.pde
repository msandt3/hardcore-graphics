class Solid{
  int k;//number of edges for computing rotational sweeps
  float d;//orientation of solid with respect to x axis
  ArrayList <Curve> curves;
  Solid(Curve p){//Curve p, int k, float d, float angle){
     curves=new ArrayList<Curve>();
     curves.add(p);
   
  }
  void rotationalSweep(int k){
    //need to implement
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
}
