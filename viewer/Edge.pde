class Edge {
  int v1, v2;
  Edge() { };
  Edge(int v1, int v2) {
    this.v1 = v1;
    this.v2 = v2;
  };
  public boolean equals(Object o) {
    Edge e = (Edge) o;
    return (this.v1 == e.v1 && this.v2 == e.v2);
  }
};

class EdgePoints {
  pt v1, v2;
  EdgePoints(pt v1, pt v2) {
    this.v1 = v1;
    this.v2 = v2;
  }
};

//Edge edge(pt A, pt B) { return new Edge(A, B); };
vec V(EdgePoints e) {
  return V(e.v1, e.v2);
}