class Test{
  public Test(){
<<<<<<< HEAD
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
  
=======
     
  }
  void runTests(){
  // println(testRotationalSweep());
   
   println("MatrixMultiplication: Expected Values: 0,0,+-1"+" Actual Values: "+testMatrixMultiplication());
   println("globalToLocal(): EV: -1.0,1.0,1.0 AV: "+testGlobalToLocal());
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
   pt O=new pt(2,1,2);
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
   ArrayList<Curve> testToLocalCurve(){
     ArrayList<Curve> templist = new ArrayList<Curve>();
     Curve c= new Curve();
     Curve temp= new Curve();
     c.deepCopy(polygon);
     templist.add(c);
     //c.briansDraw();
     //c.drawPoints();
     temp=c.toLocalCurve(c.calculateI(),c.calculateJ(),c.calculateK(),c.pts.get(c.pts.size()-1));
     templist.add(temp);
     //stroke(green);
     //show(c.pts.get(c.pts.size()-1),V(50.0,c.calculateI()));
     //show(c.pts.get(c.pts.size()-1),V(50.0,c.calculateJ()));
     //show(c.pts.get(c.pts.size()-1),V(50.0,c.calculateK()));
     //temp.briansDraw();
     //temp.drawPoints(); 
     //stroke(black);
     //show(temp.pts.get(temp.pts.size()-1),V(100.0,temp.calculateI()));
     //show(temp.pts.get(temp.pts.size()-1),V(100.0,temp.calculateJ()));
     //show(temp.pts.get(temp.pts.size()-1),V(100.0,temp.calculateK()));
     //Create a globalCurveHere
      Curve global=new Curve();
      global.deepCopy(temp);
      global=global.toGlobalCurve(temp.calculateI(),temp.calculateJ(),temp.calculateK(),temp.pts.get(temp.pts.size()-1));
      templist.add(global);
      return templist;
   }
>>>>>>> 4d55b93a0f283981cd2a661650d885000949b546
}
