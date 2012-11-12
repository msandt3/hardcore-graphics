class Solid{
  Curve polygon;
  int k;//number of edges for computing rotational sweeps
  float d;//orientation of solid with respect to x axis
  float angle;//angle of rotational sweep with respect to y axis
  Solid(){//Curve p, int k, float d, float angle){
   // this.rotationalSweep(p,k,d,angle);
   polygon=new Curve();
  }
 /* void rotationalSweep(p,k,d,angle){
    //need to implement
  }*/
  String toString(){
     return("Polygon: "+polygon+" Number of Edges(k): "+k+" Orientation(d): "+d+" Angle of Rotation: "+angle); 
    
  }
  void createTriangleMesh(){
   //need to implement 
    
  }
  /*void setP(Curve p){
    p.deepCopy(p);
  }*/
  void setOrientation(float d){
    this.d=d; 
  }
  void setAngle(float angle){
   this.angle=angle; 
  }
  void setK(int k){
   this.k=k; 
  }
  void draw(){
   //need to implement 
    
  }
}
