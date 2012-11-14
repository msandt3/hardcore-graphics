class RotateMatrix{
  float [][] matrix;
  //float angle;
  RotateMatrix(){
   matrix= new float [4][4]; 
 } 
  RotateMatrix(int xD, int yD){
   int [][] matrix= new int [xD][yD];
 } 
 void setValues(ArrayList<Float> values){
   int k=0;
   for(int i=0;i<4;i++){
     for(int j=0;j<4;j++){
       //print("J = "+j);
       matrix[i][j]=(float)values.get(k);
       //print("Matrix ["+i+"]"+" ["+j+"]"+" = "+values.get(k)+" ");
       k++;
     } 
   }
 }
 void computeYRotate(float angle){
     matrix[0][0]=cos(angle);
     matrix[0][2]=sin(angle);
     matrix[2][0]=-1*sin(angle);
     matrix[2][2]=cos(angle);
     matrix[1][1]=1;
     matrix[3][3]=1;
 }
 void changeBasisMatrix(){
  //
 }
 fourDPoint matrixMultiplication(fourDPoint pt){
   fourDPoint temp= new fourDPoint();
    temp.x=matrix[0][0]*pt.x+matrix[0][1]*pt.y+matrix[0][2]*pt.z +matrix[0][3]*pt.last;
    temp.y=matrix[1][0]*pt.x+matrix[1][1]*pt.y+matrix[1][2]*pt.z +matrix[1][3]*pt.last;
    temp.z=matrix[2][0]*pt.x+matrix[2][1]*pt.y+matrix[2][2]*pt.z +matrix[2][3]*pt.last;
    temp.last=1;
    return temp ;
 }
 String toString(){
    String ret="";
    for(int i=0;i<4;i++){
     ret+=matrix[i][0]+", "+matrix[i][1]+", "+matrix[i][2]+", "+matrix[i][3]; 
     ret+="\n";
    } 
    return ret;
 }
}
