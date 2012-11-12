class RotateMatrix{
  float [][] matrix;
  float angle;
  RotateMatrix(){
   matrix= new float [4][4];
   angle=0;
   
 } 
  RotateMatrix(int xD, int yD){
   int [][] matrix= new int [xD][yD];
 } 
 void setRotationAngle(float newAngle){
  angle=newAngle; 
 }
 void computeYRotate(){
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

}
