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
 void computeOrientationRotate(float angle, vec OR){
   //first row
   matrix[0][0] = cos(angle) + sq(OR.x)*(1-cos(angle));
   matrix[0][1] = OR.x*OR.y*(1-cos(angle)) - OR.z*sin(angle);
   matrix[0][2] = OR.x*OR.z*(1-cos(angle)) + OR.y*sin(angle);
   //second row
   matrix[1][0] = OR.x*OR.y*(1-cos(angle)) + OR.z*sin(angle);
   matrix[1][1] = cos(angle) + sq(OR.y)*(1-cos(angle));
   matrix[1][2] = OR.z*OR.y*(1-cos(angle)) - OR.x*sin(angle);
   //third row
   matrix[2][0] = OR.z*OR.x*(1-cos(angle)) - OR.y*sin(angle);
   matrix[2][1] = OR.z*OR.y*(1-cos(angle)) + OR.x*sin(angle);
   matrix[2][2] = cos(angle) + sq(OR.z)*(1-cos(angle));
   //fourth row
   matrix[3][3] = 1;
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
    return temp;
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
