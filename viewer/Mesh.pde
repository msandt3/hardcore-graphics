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

    void drawFace(int c) {
        vertex(g(c));
        vertex(g(n(c)));
        vertex(g(n(n(c))));
    }

    void drawDummy(float time, Mesh m2) {
        MeshMap map = new MeshMap(this, m2);
        Set<StartEnd> startEnd = new HashSet<StartEnd>();
    }

    void draw(float time, Mesh m2, MeshMap map) {
        Set<StartEnd> startEnd = new HashSet<StartEnd>();
        for (int i = 0; i < nt(); i++) {
            List<Integer> vertices = map.F2V.get(i);
            for (Integer morphV : vertices) {
                pt morphTo = m2.g(morphV);
                println(morphV);
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

pt IOrdered(int i1, pt A, int i2, pt B, int i3, pt C, int i4, pt D, float time) {
    pt[] points = new pt[4];
    points[i1] = A;
    points[i2] = B;
    points[i3] = C;
    points[i4] = D;
    return I(0, points[0], 0.33, points[1], 0.66, points[2], 1, points[3], time);
}

void nevilleMorph(Mesh m1, Mesh m2, Mesh m3, Mesh m4, float time, List<List<MeshMap>> maps) {
    Deque<Mesh> in = new LinkedList<Mesh>();
    Queue<Mesh> out = new LinkedList<Mesh>();
    Deque<Integer> inIndex = new LinkedList<Integer>();
    Queue<Integer> outIndex = new LinkedList<Integer>();
    in.addLast(m1);
    in.addLast(m2);
    in.addLast(m3);
    in.addLast(m4);
    inIndex.add(0);
    inIndex.add(1);
    inIndex.add(2);
    inIndex.add(3);

    for (int m = 0; m < 4; m++) {
        Mesh M1 = in.removeFirst();
        int X1 = inIndex.removeFirst();
        out.clear();
        out.addAll(in);
        outIndex.clear();
        outIndex.addAll(inIndex);

        Mesh M2 = out.remove(),
             M3 = out.remove(),
             M4 = out.remove();

        int X2 = outIndex.remove(),
            X3 = outIndex.remove(),
            X4 = outIndex.remove();

        // ============== Vertex to Face
        fill(green);
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
                            vertex(IOrdered(X1, M1.g(3 * i + c), X2, morphTo2, X3, morphTo3, X4, morphTo4, time));    
                        }
                        endShape();
                    }
                }
            }
        }

        // ============== Vertex to Face
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
                                vertex(IOrdered(X1, M1.g(i), X2, M2.g(3 * face2 + c), X3, M3.g(3 * face3 + c), X4, M4.g(3 * face4 + c), time));
                            }
                        endShape();
                    }
                }
            }
        }

        // ============== Edge to edge
        /*fill(blue);
        for (Entry<Integer, List<Integer>> entry2 : maps.get(m).get(0).E2E.entrySet()) {
            int e1 = entry2.getKey();
            EdgePoints edge1 = M1.makeEdge(M1.edges.get(e1));
            List<Integer> edges2 = entry2.getValue();
            for (Integer e2 : edges2) {
                EdgePoints edge2 = M2.makeEdge(M2.edges.get(e2));
                for (Entry<Integer, List<Integer>> entry3 : maps.get(m).get(1).E2E.entrySet()) {
                    List<Integer> edges3 = entry3.getValue();
                    for (Integer e3 : edges3) {
                        EdgePoints edge3 = M3.makeEdge(M3.edges.get(e3));
                        for (Entry<Integer, List<Integer>> entry4 : maps.get(m).get(2).E2E.entrySet()) {
                            List<Integer> edges4 = entry4.getValue();
                            for (Integer e4 : edges4) {
                                EdgePoints edge4 = M4.makeEdge(M4.edges.get(e4));
                                beginShape();
                                    vertex(IOrdered(X1, edge1.v2, X2, edge2.v2, X3, edge3.v2, X4, edge4.v2, time));
                                    vertex(IOrdered(X1, edge1.v1, X2, edge2.v2, X3, edge3.v2, X4, edge4.v2, time));
                                    vertex(IOrdered(X1, edge1.v1, X2, edge2.v1, X3, edge3.v1, X4, edge4.v1, time));
                                    vertex(IOrdered(X1, edge1.v2, X2, edge2.v1, X3, edge3.v1, X4, edge4.v1, time));
                                endShape();
                            }
                        }
                    }
                }
            }
        }*/

        in.addLast(M1);
        inIndex.addLast(X1);
    }

    /*maps.add(new LinkedList<MeshMap>());
    maps.add(new LinkedList<MeshMap>());
    maps.add(new LinkedList<MeshMap>());
    maps.add(new LinkedList<MeshMap>());

    maps.get(0).add(new MeshMap(m1, m2));
    maps.get(0).add(new MeshMap(m1, m3));
    maps.get(0).add(new MeshMap(m1, m4));*/

    /*for (int m = 0; m < 4; m++) {
        for (int i = 0; i < m1.nt(); i++) {
            List<Integer> vertices2 = maps.get(m).get(0).F2V.get(i);
            for (Integer morphV2 : vertices2) {
                List<Integer> vertices3 = maps.get(m).get(1).F2V.get(i);
                pt morphTo2 = m2.g(morphV2);
                for (Integer morphV3 : vertices3) {
                    List<Integer> vertices4 = maps.get(m).get(2).F2V.get(i);
                    pt morphTo3 = m3.g(morphV3);
                    for (Integer morphV4 : vertices4) {
                        pt morphTo4 = m4.g(morphV4);
                        beginShape();
                        for (int c = 0; c < 3; c++) {
                            vertex(I(0, m1.g(3 * 1 + c), 0.33, morphTo2, 0.66, morphTo3, 1, morphTo4, time));    
                        }
                        endShape();
                    }
                }
            }
        }

        for (int i = 0; i < m1.nc(); i++) {
            List<Integer> faces2 = maps.get(m).get(0).V2F.get(i);
            for (Integer face2 : faces2) {
                List<Integer> faces3 = maps.get(m).get(1).V2F.get(i);
                for (Integer face3 : faces3) {
                    List<Integer> faces4 = maps.get(m).get(2).V2F.get(i);
                    for (Integer face4 : faces4) {
                        beginShape();
                            for (int c = 0; c < 3; c++) {
                                vertex(I(0, m1.g(i), 0.33, m2.g(3 * face2 + c), 0.66, m3.g(3 * face3 + c), 1, m4.g(3 * face4 + c), time));
                            }
                        endShape();
                    }
                }
            }
        }
    }*/

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
}