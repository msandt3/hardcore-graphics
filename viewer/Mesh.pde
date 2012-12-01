class Mesh {
    List<pt> G;
    List<Integer> V;
    Map<Integer, List<Integer>> vertexEdges;
    Map<Integer, List<Integer>> edgeTriangles;
    List<Edge> edges;
    List<vec> Nt;
    List<vec> Nv;
    boolean flatShading = true;

    Mesh() {
        empty();
    }

    Mesh(Mesh m1, float time, Mesh m2) {
        empty();

        MeshMap map = new MeshMap(m1, m2);
        if (time < 1) {
            for (int i = 0; i < m1.nt(); i++) {
                List<Integer> vertices = map.F2V.get(i);
                for (Integer morphV : vertices) {
                    pt morphTo = m2.g(morphV);
                    this.addTriangle(
                        P(m1.g(3 * i + 0), time, morphTo),
                        P(m1.g(3 * i + 1), time, morphTo),
                        P(m1.g(3 * i + 2), time, morphTo)
                    );
                }
            }
        }

        for (int i = 0; i < m1.nc(); i++) {
            List<Integer> faces = map.V2F.get(i);
            for (Integer face : faces) {
                this.addTriangle(
                    P(m1.g(i), time, m2.g(3 * face + 0)),
                    P(m1.g(i), time, m2.g(3 * face + 1)),
                    P(m1.g(i), time, m2.g(3 * face + 2))
                );
            }
        }

        /*for (Entry<Integer, List<Integer>> entry : map.E2E.entrySet()) {
            int e1 = entry.getKey();
            List<Integer> edges = entry.getValue();
            for (Integer e2 : edges) {
                Edge ee1 = m1.edges.get(e1);
                Edge ee2 = m2.edges.get(e2);
                EdgePoints edge1 = m1.makeEdge(ee1);
                EdgePoints edge2 = m2.makeEdge(ee2);
                this.addQuad(
                    P(edge1.v2, time, edge2.v2),
                    P(edge1.v1, time, edge2.v2),
                    P(edge1.v1, time, edge2.v1),
                    P(edge1.v2, time, edge2.v1)
                );
            }
        }*/
        normals();
    }

    void empty() {
        G = new ArrayList<pt>();
        V = new ArrayList<Integer>();
        vertexEdges = new HashMap<Integer, List<Integer>>();
        edgeTriangles = new HashMap<Integer, List<Integer>>();
        edges = new ArrayList<Edge>();
        Nt = new ArrayList<vec>();
        Nv = new ArrayList<vec>();
    }

    int n (int c) {return 3*t(c)+(c+1)%3;}
    int p (int c) {return n(n(c));}

    int nt() {
        return V.size()/3;
    }

    int nc() {
        return V.size();
    }

    pt G(int v) {
        return G.get(v);
    }

    pt g(int c) {
        return G.get(v(c));
    }

    int v(int c) {
        return V.get(c);
    }

    int t(int c) {
        return int(c/3);
    }

    vec Nt(int i) {
        return Nt.get(i);
    }

    vec Nv(int i) {
        return Nv.get(i);
    }
    
    int addVertex(pt P) {
        int index = G.indexOf(P);
        if (index != -1) return index;

        G.add(P);
        return G.size() - 1;
    }

    EdgePoints makeEdge(Edge e) {
        return new EdgePoints(G(e.v1), G(e.v2));
    }

    void addEdge(int Ai, int Bi, int nt) {
        Edge edge = new Edge(Ai, Bi);
        int Ei = edges.indexOf(edge);
        if (Ei == -1) {
            edges.add(edge);
            Ei = edges.size() - 1;
        }

        edges.add(edge);

        boolean foundA = vertexEdges.containsKey(Ai),
                foundE = edgeTriangles.containsKey(Ei);

        if (!foundA) vertexEdges.put(Ai, new ArrayList<Integer>());

        List<Integer> edgeListA = vertexEdges.get(Ai);
        if (!edgeListA.contains(Ei)) {
            edgeListA.add(Ei);
        }

        if (!foundE) edgeTriangles.put(Ei, new ArrayList<Integer>());

        edgeTriangles.get(Ei).add(nt);
    }

    int addTriangle(int i, int j, int k) {
        V.add(i);
        V.add(j);
        V.add(k);
        int ntri = nt() - 1;

        /*addEdge(i, j, ntri);
        addEdge(j, k, ntri);
        addEdge(i, k, ntri);*/

        addEdge(i, j, ntri);
        addEdge(i, k, ntri);
        addEdge(j, k, ntri);
        addEdge(j, i, ntri);
        addEdge(k, i, ntri);
        addEdge(k, j, ntri);

        return ntri;
    }

    void addTriangle(pt i, pt j, pt k) {
        addTriangle(addVertex(i), addVertex(j), addVertex(k));
    }

    void addQuad(int i, int j, int k, int l) {
        addTriangle(k, j, i);
        addTriangle(j, k, l);
    }

    void addQuad(pt i, pt j, pt k, pt l) {
        addTriangle(k, j, i);
        addTriangle(j, k, l);
    }

    void makeRevolution(Solid s) {
        empty();

        Curve current;
        int faces = s.k;
        if (faces == 0) return;

        int n = s.curves.get(0).pts.size(); // number of points on curve
        int firstV = addVertex(s.curves.get(0).pts.get(0));
        int lastV = addVertex(s.curves.get(0).pts.get(n - 1));
        int[][] vertices = new int[faces][n];
        for (int i = 0; i < faces; i++) { // loop through faces
            current = s.curves.get(i);
            vertices[i][0] = firstV;
            vertices[i][n - 1] = firstV;
            for (int j = 1; j < n - 1; j++) {
                vertices[i][j] = addVertex(s.curves.get(i).pts.get(j));
            }
        }

        for (int i = 0; i < faces; i++) {
            int[] currentFace = vertices[i];
            int[] nextFace = vertices[(i + 1) % faces];
            for (int j = 0; j < n - 1; j++) {
                if (j == 0) {
                    addTriangle(currentFace[j + 1], firstV, nextFace[j + 1]);
                } else if (j == n - 2) {
                    addTriangle(currentFace[j], nextFace[j], lastV);
                } else {
                    addQuad(currentFace[j], currentFace[j + 1], nextFace[j], nextFace[j + 1]);
                }
            }
        }

        normals();
    }

    vec triNormal(int t) {
        return N(V(g(3*t), g(3*t+1)), V(g(3*t), g(3*t+2)));
    }

    void normals() {
        computeTriNormals();
        computeVertexNormals();
    }

    void computeTriNormals() {
        Nt.clear();
        while (Nt.size() < nt()) {
            Nt.add(V());
        }
        for (int i=0; i < Nt.size(); i++) {
            Nt.get(i).add(triNormal(i));
        }
    }

    void computeVertexNormals() {  // computes the vertex normals as sums of the normal vectors of incident tirangles scaled by area/2
        Nv.clear();
        while (Nv.size() < G.size()) {
            Nv.add(V());
        }
        for (int i = 0; i < V.size(); i++) {
            Nv(v(i)).add(Nt(t(i)));
        }
        for (int i = 0; i < G.size(); i++) {
            Nv(i).normalize();
        }
    }

    void drawEdges() {
        stroke(blue);
        for (int i = 0; i < G.size(); i++) {
            List<Integer> es = vertexEdges.get(i);
            for (int j = 0; j < es.size(); j++) {
                EdgePoints edge = makeEdge(edges.get(es.get(j)));
                beginShape(LINES);
                    vertex(edge.v1.x, edge.v1.y, edge.v1.z);
                    vertex(edge.v2.x, edge.v2.y, edge.v2.z);
                endShape();                
            }
        }

        /*stroke(black);
        for (Edge e : edges) {
            beginShape(LINES);
                vertex(e.X);
                vertex(e.Y);
            endShape();
        }*/
    }

    void draw() {
        for (int t = 0; t < V.size()/3; t++) {
            beginShape();
            if (flatShading) {
                vertex(g(3*t));
                vertex(g(3*t+1));
                vertex(g(3*t+2));
            } else {
                normal(Nv(v(3*t)));
                vertex(g(3*t));
                normal(Nv(v(3*t+1)));
                vertex(g(3*t+1));
                normal(Nv(v(3*t+2)));
                vertex(g(3*t+2));
            }
            endShape();
        }
    }

    void drawDummy(float time, Mesh m2) {
        MeshMap map = new MeshMap(this, m2);
        Set<StartEnd> startEnd = new HashSet<StartEnd>();
    }

    void draw(float time, Mesh m2) {
        MeshMap map = new MeshMap(this, m2);
        Set<StartEnd> startEnd = new HashSet<StartEnd>();
        for (int i = 0; i < nt(); i++) {
            List<Integer> vertices = map.F2V.get(i);
            for (Integer morphV : vertices) {
                pt morphTo = m2.g(morphV);
                fill(blue);
                beginShape();
                    for (int j = 0; j < 3; j++) {
                        StartEnd pair = new StartEnd(v(3 * i + j), morphV);
                        if (!startEnd.contains(pair)) startEnd.add(pair);
                        else {
                            println("damn");
                            continue;
                        }
                        vertex(P(g(3 * i + j), time, morphTo));
                    }
                endShape();
            }
        }

        for (int i = 0; i < nc(); i++) {
            List<Integer> faces = map.V2F.get(i);
            for (Integer face : faces) {
                fill(red);
                beginShape();
                    for (int j = 0; j < 3; j++) {
                        StartEnd pair = new StartEnd(v(i), m2.v(3 * face + j));
                        if (!startEnd.contains(pair)) startEnd.add(pair);
                        else {
                            println("damn");
                            continue;
                        }
                        vertex(P(g(i), time, m2.g(3 * face + j)));
                    }
                endShape();
            }
        }

        for (Entry<Integer, List<Integer>> entry : map.E2E.entrySet()) {
            int e1 = entry.getKey();
            List<Integer> edges = entry.getValue();
            for (Integer e2 : edges) {
                Edge ee1 = this.edges.get(e1);
                Edge ee2 = m2.edges.get(e2);
                EdgePoints edge1 = this.makeEdge(ee1);
                EdgePoints edge2 = m2.makeEdge(ee2);
                fill(green);
                beginShape();
                    List<Integer> startPoints = new ArrayList<Integer>();
                    List<Integer> endPoints = new ArrayList<Integer>();
                    startPoints.add(ee1.v1);
                    startPoints.add(ee1.v2);
                    endPoints.add(ee2.v1);
                    endPoints.add(ee2.v2);
                    for (Integer s : startPoints) {
                        for (Integer e : endPoints) {
                            StartEnd pair = new StartEnd(s, e);
                            if (!startEnd.contains(pair)) startEnd.add(pair);
                            else {
                                println("damn");
                                continue;
                            }
                        }
                    }
                    vertex(P(edge1.v2, time, edge2.v2));
                    vertex(P(edge1.v1, time, edge2.v2));
                    vertex(P(edge1.v1, time, edge2.v1));
                    vertex(P(edge1.v2, time, edge2.v1));
                endShape();
            }
        }
    }
};

Mesh Neville (Mesh A, Mesh B, Mesh C, float t) {
    Mesh P = new Mesh(A,t,B);
    Mesh Q = new Mesh(B,t-1,C);
    return new Mesh(P,t/2,Q);
}

Mesh Neville (Mesh A, Mesh B, Mesh C, Mesh D, float t) {
    Mesh PAB = new Mesh(A, t, B);
    Mesh PBC = new Mesh(B, t-1, C);
    Mesh PCD = new Mesh(C, t-2, D);
    Mesh PABC = new Mesh(PAB, t/2, PBC);
    Mesh PBCD = new Mesh(PBC, (t-1)/2, PCD);
    Mesh PABCD = new Mesh(PABC, t/3, PBCD);
    return PABCD;
}