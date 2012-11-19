class RotateMatrix{
  float [][] matrix;
  //float angle;
  RotateMatrix(){
   matrix= new float [4][4]; 
 } 
  RotateMatrix(int xD, int yD){
   int [][] matrix= new int [xD][yD];
 } 
 void computeYRotate(float angle){
     matrix[0][0]=cos(angle);
     matrix[0][2]=sin(angle);
     matrix[2][0]=-1*sin(angle);
     matrix[2][2]=cos(angle);
     matrix[1][1]=1;
     matrix[3][3]=1;
     matrix[0][1]=0;
     matrix[0][3]=0;
     matrix[1][0]=0;
     matrix[1][2]=0;
     matrix[2][1]=0;
     matrix[2][3]=0;
     matrix[3][0]=0;
     matrix[3][1]=0;
     matrix[3][2]=0;
 }
 void changeBasisMatrix(){
  //
 }
 fourDPoint matrixMultiplication(fourDPoint pt){
    pt.x=matrix[0][0]*pt.x+matrix[0][1]*pt.y+matrix[0][2]*pt.z +matrix[0][3]*pt.last;
    pt.y=matrix[1][0]*pt.x+matrix[1][1]*pt.y+matrix[1][2]*pt.z +matrix[1][3]*pt.last;
    pt.z=matrix[2][0]*pt.x+matrix[2][1]*pt.y+matrix[2][2]*pt.z +matrix[2][3]*pt.last;
    pt.last=1;
    return pt;
 }
}
