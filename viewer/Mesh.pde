class Mesh {
    List<pt> G;
    List<Integer> V;
    List<Integer> O;
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
        computeO();
    }

    void empty() {
        G = new ArrayList<pt>();
        V = new ArrayList<Integer>();
        O = new ArrayList<Integer>();
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

    int o(int c) {
        return O.get(c);
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
        computeO();
    }

    void computeO() {
        O.clear();
        for (int i = 0; i < nc(); i++) O.add(i);
        for (int i = 0; i < nc(); i++) {
            for (int j = i + 1; j < nc(); j++) {
                if ((v(n(i))==v(p(j))) && (v(p(i))==v(n(j)))) {
                    O.set(i, j);
                    O.set(j, i);
                }
            }
        }
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
        for (int i = 0; i < nt(); i++) {
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

    void drawTangents() {
        for (int i = 29; i < 30; i++) {
            int o = o(i);
            int t = t(i);
            int t2 = t(o);
            Edge edge = new Edge(v(n(o)), v(p(o)));
            EdgePoints ep = makeEdge(edge);
            vec B1 = N(V(ep), Nt(t));
            vec B2 = N(M(V(ep)), Nt(t2));

            stroke(blue);
            beginShape(LINES);
                vertex(g(3 * t + 0));
                vertex(g(3 * t + 1));
                vertex(g(3 * t + 2));
                vertex(g(3 * t + 0));
                vertex(g(3 * t + 1));
                vertex(g(3 * t + 2));
            endShape();

            beginShape(LINES);
                vertex(g(3 * t2 + 0));
                vertex(g(3 * t2 + 1));
                vertex(g(3 * t2 + 2));
                vertex(g(3 * t2 + 0));
                vertex(g(3 * t2 + 1));
                vertex(g(3 * t2 + 2));
            endShape();

            stroke(red);
            beginShape(LINES);
                vertex(ep.v1);
                vertex(ep.v2);
            endShape();

            stroke(black);
            show(P(g(3 * t + 0), g(3 * t + 1), g(3 * t + 2)), Nt(t));
            show(P(g(3 * t2 + 0), g(3 * t2 + 1), g(3 * t2 + 2)), Nt(t2));

            stroke(orange);
            show(P(ep.v1, ep.v2), B1);
            show(P(ep.v1, ep.v2), B2);
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

    void drawFace(int c) {
        vertex(g(c));
        vertex(g(n(c)));
        vertex(g(n(n(c))));
    }

    void drawDummy(float time, Mesh m2) {
        MeshMap map = new MeshMap(this, m2);
        Set<StartEnd> startEnd = new HashSet<StartEnd>();
    }

    void draw(float time, Mesh m2, MeshMap map, boolean E2E, boolean V2F, boolean F2V) {
        if (E2E) {
            for (Entry<Integer, List<Integer>> entry : map.E2E.entrySet()) {
                int c1 = entry.getKey();
                int o1 = this.o(c1);
                int tc1 = this.t(c1);
                int to1 = this.t(o1);
                Edge e1 = new Edge(this.v(this.n(o1)), this.v(this.p(o1)));
                EdgePoints edge1 = this.makeEdge(e1);
                List<Integer> mc = entry.getValue(); // matching corners
                for (Integer c2 : mc) {
                    int o2 = m2.o(c2);
                    int tc2 = m2.t(c2);
                    int to2 = m2.t(o2);
                    Edge e2 = new Edge(m2.v(m2.n(o2)), m2.v(m2.p(o2)));
                    EdgePoints edge2 = m2.makeEdge(e2);

                    fill(green);
                    beginShape();
                        vertex(P(edge1.v2, time, edge2.v2));
                        vertex(P(edge1.v1, time, edge2.v2));
                        vertex(P(edge1.v1, time, edge2.v1));
                        vertex(P(edge1.v2, time, edge2.v1));
                    endShape();
                }
            }
        }

        if (V2F) {
            for (int i = 0; i < nt(); i++) {
                List<Integer> vertices = map.F2V.get(i);
                for (Integer morphV : vertices) {
                    pt morphTo = m2.g(morphV);
                    fill(blue);
                    beginShape();
                        for (int j = 0; j < 3; j++) {
                            vertex(P(g(3 * i + j), time, morphTo));
                        }
                    endShape();
                }
            }
        }

        if (F2V) {
            for (int i = 0; i < nc(); i++) {
                List<Integer> faces = map.V2F.get(i);
                for (Integer face : faces) {
                    fill(red);
                    beginShape();
                        for (int j = 0; j < 3; j++) {
                            vertex(P(g(i), time, m2.g(3 * face + j)));
                        }
                    endShape();
                }
            }
        }
    }
};

pt IOrdered(int i1, pt A, int i2, pt B, int i3, pt C, int i4, pt D, float t, boolean bezier) {
    if (!bezier) {
        pt[] points = new pt[4];
        points[i1 % 4] = A;
        points[i2 % 4] = B;
        points[i3 % 4] = C;
        points[i4 % 4] = D;
        return I(0, points[0], 0.33, points[1], 0.66, points[2], 1, points[3], t);        
    } else {
        return P(pow(1 - t, 3), A, 3 * sq(1 - t) * t, B, 3 * (1-t) * sq(t), C, pow(t, 3), D);   
    }
}

void nevilleMorph(Mesh m1, Mesh m2, Mesh m3, Mesh m4, float time, List<List<MeshMap>> maps, boolean bezier, boolean E2E, boolean V2F, boolean F2V) {
    Mesh[] in = {m1, m2, m3, m4};
    Mesh M1, M2, M3, M4;

    for (int m = 0; m < 1; m++) {
        M1 = in[m];
        M2 = in[(m + 1) % 4];
        M3 = in[(m + 2) % 4];
        M4 = in[(m + 3) % 4];
        // ============== Face to Vertex
        if (F2V) {
            fill(blue);
            for (int i = 0; i < M1.nt(); i++) {
                List<Integer> vertices2 = maps.get(m).get(0).F2V.get(i);
                for (Integer morphV2 : vertices2) {
                    List<Integer> vertices3 = maps.get(m).get(1).F2V.get(i);
                    pt morphTo2 = M2.g(morphV2);
                    for (Integer morphV3 : vertices3) {
                        List<Integer> vertices4 = maps.get(m).get(2).F2V.get(i);
                        pt morphTo3 = M3.g(morphV3);
                        for (Integer morphV4 : vertices4) {
                            pt morphTo4 = M4.g(morphV4);
                            beginShape();
                            for (int c = 0; c < 3; c++) {
                                vertex(IOrdered(m, M1.g(3 * i + c), m + 1, morphTo2, m + 2, morphTo3, m + 3, morphTo4, time, bezier));    
                            }
                            endShape();
                        }
                    }
                }
            }
        }

        // ============== Vertex to Face
        if (V2F) {
            fill(red);
            for (int i = 0; i < M1.nc(); i++) {
                List<Integer> faces2 = maps.get(m).get(0).V2F.get(i);
                for (Integer face2 : faces2) {
                    List<Integer> faces3 = maps.get(m).get(1).V2F.get(i);
                    for (Integer face3 : faces3) {
                        List<Integer> faces4 = maps.get(m).get(2).V2F.get(i);
                        for (Integer face4 : faces4) {
                            beginShape();
                                for (int c = 0; c < 3; c++) {
                                    vertex(IOrdered(m, M1.g(i), m + 1, M2.g(3 * face2 + c), m + 2, M3.g(3 * face3 + c), m + 3, M4.g(3 * face4 + c), time, bezier));
                                }
                            endShape();
                        }
                    }
                }
            }
        }

        // ============== Edge to Edge
        if (E2E) {
            fill(green);
            for (int c1 = 0; c1 < M1.nc(); c1++) {
                int o1 = M1.o(c1);
                int tc1 = M1.t(c1);
                int to1 = M1.t(o1);
                Edge e1 = new Edge(M1.v(M1.n(o1)), M1.v(M1.p(o1)));
                EdgePoints edge1 = M1.makeEdge(e1);
                List<Integer> mc2 = maps.get(m).get(0).E2E.get(c1); // matching corners
                if (mc2 == null) continue;
                for (Integer c2 : mc2) {
                    int o2 = M2.o(c2);
                    int tc2 = M2.t(c2);
                    int to2 = M2.t(o2);
                    Edge e2 = new Edge(M2.v(M2.n(o2)), M2.v(M2.p(o2)));
                    EdgePoints edge2 = M2.makeEdge(e2);
                    List<Integer> mc3 = maps.get(m).get(1).E2E.get(c1);
                    if (mc3 == null) continue;
                    for (Integer c3 : mc3) {
                        int o3 = M3.o(c3);
                        int tc3 = M3.t(c3);
                        int to3 = M3.t(o3);
                        Edge e3 = new Edge(M3.v(M3.n(o3)), M3.v(M3.p(o3)));
                        EdgePoints edge3 = M3.makeEdge(e3);
                        List<Integer> mc4 = maps.get(m).get(2).E2E.get(c1);
                        if (mc4 == null) continue;
                        for (Integer c4 : mc4) {
                            int o4 = M4.o(c4);
                            int tc4 = M4.t(c4);
                            int to4 = M4.t(o4);
                            Edge e4 = new Edge(M4.v(M4.n(o4)), M4.v(M4.p(o4)));
                            EdgePoints edge4 = M4.makeEdge(e4);
                            beginShape();
                                vertex(IOrdered(m, edge1.v2, m + 1, edge2.v2, m + 2, edge3.v2, m + 3, edge4.v2, time, bezier));
                                vertex(IOrdered(m, edge1.v1, m + 1, edge2.v2, m + 2, edge3.v2, m + 3, edge4.v2, time, bezier));
                                vertex(IOrdered(m, edge1.v1, m + 1, edge2.v1, m + 2, edge3.v1, m + 3, edge4.v1, time, bezier));
                                vertex(IOrdered(m, edge1.v2, m + 1, edge2.v1, m + 2, edge3.v1, m + 3, edge4.v1, time, bezier));
                            endShape();
                        }
                    }
                }
            }
        }
    }
}