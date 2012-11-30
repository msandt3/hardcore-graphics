class Edge {
  pt X, Y;
  vec tan1,tan2;
  List<Integer> triangles;
  Edge() { };
  Edge(pt X, pt Y) {
    this.X = X;
    this.Y = Y;
    tan1=new vec();
    tan2=new vec();
    triangles = new ArrayList<Integer>();
  };
  Edge(pt X, pt Y, int nt) {
    this(X, Y);
    triangles.add(nt);
  };
  public boolean equals(Object o) {
    Edge e = (Edge) o;
    return (this.X == e.X && this.Y == e.Y) || (this.Y == e.X && this.X == e.Y);
  }
  public int hashCode() {
    return (int) (X.x + X.y + X.z + Y.x + Y.y + Y.z);
  }
  void addTriangle(int t) {
  	triangles.add(t);
  }
  void drawTangents(){
  stroke(red);
 // P(this.X,this.Y).drawPt();
  show(P(this.X,this.Y),this.tan1); 
  show(P(this.X,this.Y),this.tan2);
}
};

Edge edge(pt A, pt B) { return new Edge(A, B); };
vec V(Edge e) {
  return V(e.X, e.Y);
}
vec getTangent(Edge e, vec faceNorm){
    	return N(V(e),faceNorm);
}


