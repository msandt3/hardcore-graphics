class Test{
  public Test(){
   //run Tests here
   
  }
  void runTests(){
  // println(testRotationalSweep());
   
   println("Expected Values: 0,0,+-1"+" Actual Values: "+testMatrixMultiplication());
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
  /*String testRotationalSweep(){
   Solid testSolid= new Solid(new Curve(),); 
    
  }*/
  
}
