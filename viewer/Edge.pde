class Edge {
  pt X, Y;
  Edge() { };
  Edge(pt X, pt Y) {
    this.X = X;
    this.Y = Y;
  };
  public boolean equals(Object o) {
    Edge e = (Edge) o;
    return (e.X == e.X && e.Y == e.Y) || (e.Y == e.X && e.X == e.Y);
  }
  public int hashCode() {
    return (int) (X.x + X.y + X.z + Y.x + Y.y + Y.z);
  }
};

Edge edge(pt A, pt B) { return new Edge(A, B); };
vec V(Edge e) {
  return V(e.X, e.Y);
}