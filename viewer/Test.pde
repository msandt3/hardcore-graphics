 class Test{
  public Test(){
     
  }
  void runTests(){
    println("Tests should be run here, but nothing happens");
  // println(testRotationalSweep());
   
   //println("MatrixMultiplication: Expected Values: 0,0,+-1"+" Actual Values: "+testMatrixMultiplication());
  // println("globalToLocal(): EV: 0,0,0 AV: "+testGlobalToLocal());
  // println("localToGlobal(): EV: 1,2,3 AV: "+testLocalToGlobal());
   
  }
  String testMatrixMultiplication(){
    ArrayList <Float>values=new ArrayList<Float>();
    for(float i=0.0;i<16.0;i+=1.0){
     values.add(i); 
    }
 //   println("Size of values:"+values.size());
    matrix.setValues(values);
//   println(matrix.toString());
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
   pt C= new pt(0,0,0);
   pt D= C.toLocalPt(I,J,K,O);
  // println("D: "+D.toString());
   return B.toString();
   }
   String testLocalToGlobal(){
       pt A= new pt(-1.0,1.0,1.0);
       vec I=new vec(1.0,0.0,0.0);
       vec J= new vec(0.0,1.0,0.0);
       vec K=new vec(0.0,0.0,1.0);
       pt O=new pt(2,1,2);
       pt B= A.toGlobalPt(I,J,K,O);
       pt D = new pt(0,0,0);
       pt C = D.toGlobalPt(I,J,K,O);
       //println("C: "+C.toString());
       return B.toString();
   }
   ArrayList<Curve> testToLocalCurve(){
     ArrayList<Curve> templist = new ArrayList<Curve>();
     Curve c= new Curve();
     Curve temp= new Curve();
     
     c.deepCopy(polygon);
     pt O=c.pts.get(c.pts.size()-1);
     //templist.add(c);
     //c.briansDraw();
     //c.drawPoints();
     vec I=new vec(1,0.0,0.0);
     vec J=new vec(0,1,0);
     vec K=new vec(0,0,1);
     temp=c.toLocalCurve(I,J,K,O);
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
     //Create a globalCurveHereo
      Curve global=new Curve();
      global.deepCopy(temp);
      global=global.toGlobalCurve(I,J,K,O);
      templist.add(global);
      return templist;
   }
  /* ArrayList<Solid> testToLocalSolid(){
    Solid tester= new Solid();
   
   }*/
}
