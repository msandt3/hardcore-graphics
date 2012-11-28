class Edge {
  pt X, Y;
  List<Integer> triangles;
  Edge() { };
  Edge(pt X, pt Y) {
    this.X = X;
    this.Y = Y;
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
};

Edge edge(pt A, pt B) { return new Edge(A, B); };
vec V(Edge e) {
  return V(e.X, e.Y);
}