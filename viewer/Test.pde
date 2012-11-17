class Test{
  public Test(){
     
  }
  void runTests(){
  // println(testRotationalSweep());
   
   println("MatrixMultiplication: Expected Values: 0,0,+-1"+" Actual Values: "+testMatrixMultiplication());
   println("globalToLocal(): EV: -1.0,1.0,0 AV: "+testGlobalToLocal());
   println("localToGlobal(): EV: 1,2,3 AV: "+testLocalToGlobal());
   
  }
  String testMatrixMultiplication(){
    ArrayList <Float>values=new ArrayList<Float>();
    for(float i=0.0;i<16.0;i+=1.0){
     values.add(i); 
    }
    println("Size of values:"+values.size());
    matrix.setValues(values);
    println(matrix.toString());
    fourDPoint testPt= new fourDPoint();
    testPt.setPt(new pt(1,0,0));
    testPt=matrix.matrixMultiplication(testPt);
    return testPt.toString();
   }
 String testGlobalToLocal(){
   pt A= new pt(1.0,2.0,3.0);
   vec I=new vec(1.0,0.0,0.0);
   vec J= new vec(0.0,1.0,0.0);
   vec K=new vec(0.0,0.0,1.0);
   pt O=new pt(2,1,3);
   pt B= A.toLocalPt(I,J,K,O);
   return B.toString();
   }
   String testLocalToGlobal(){
       pt A= new pt(-1.0,1.0,0.0);
       vec I=new vec(1.0,0.0,0.0);
       vec J= new vec(0.0,1.0,0.0);
       vec K=new vec(0.0,0.0,1.0);
       pt O=new pt(2,1,3);
       pt B= A.toGlobalPt(I,J,K,O);
       return B.toString();
   }
   void testToLocalCurve(){
     Curve c= new Curve();
     Curve temp= new Curve();
     c.deepCopy(polygon);
     c.briansDraw();
     c.drawPoints();
     temp=c.toLocalCurve(c.calculateI(),c.calculateJ(),c.calculateK(),c.pts.get(c.pts.size()-1));
     temp.briansDraw();
     temp.drawPoints();
     
   }
}
