class Test{
  public Test(){
   //run Tests here
   
  }
  void runTests(){
  // println(testRotationalSweep());
   println("Expected Values: 0,0,+-1"+" Actual Values: "+testMatrixMultiplication());
  }
  String testMatrixMultiplication(){
    matrix.computeYRotate(PI/(2.0));
    fourDPoint testPt= new fourDPoint();
    testPt.setPt(new pt(1,0,0));
    testPt=matrix.matrixMultiplication(testPt);
    return testPt.toPt().toString();
   }
  /*String testRotationalSweep(){
   Solid testSolid= new Solid(new Curve(),); 
    
  }*/
  
}
