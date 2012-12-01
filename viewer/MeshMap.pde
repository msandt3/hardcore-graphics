class StartEnd {
    int start;
    int end;
    StartEnd(int start, int end) {
        this.start = start;
        this.end = end;
    }
    public int hashCode() {
        return 31 * start + 37 * end;
    }
};

class MeshMap {
    Mesh m1, m2;
    Map<Integer, List<Integer>> V2F;
    Map<Integer, List<Integer>> F2V;
    Map<Integer, List<Integer>> E2E;
    Set<StartEnd> startEnd;

    MeshMap(Mesh A, Mesh B) {
        this.m1 = A;
        this.m2 = B;
        V2F = new HashMap<Integer, List<Integer>>();
        F2V = new HashMap<Integer, List<Integer>>();
        E2E = new HashMap<Integer, List<Integer>>();
        startEnd = new HashSet<StartEnd>();
        faceToVertex();
        vertexToFace();
        edgeToEdge();
    }

    void faceToVertex() {
        for (int f = 0; f < m1.nt(); f++) {
            ArrayList<Integer> list = new ArrayList<Integer>();
            for (int v = 0; v < m2.V.size(); v++) {
                if (LSD(m1.Nt(f), m2, m2.v(v))) {
                    /*for (int i = 0; i < 3; i++) {
                        int start = 3*f+i;
                        //StartEnd pair = new StartEnd(start, v);
                        //if (!startEnd.contains(pair)) list.add(v);

                        //startEnd.add(pair);

                    }*/
                    list.add(v);
                }
            }
            
            F2V.put(f, list);
        }
    }

    void vertexToFace() {
        for (int i = 0; i < m1.nc(); i++) {
            ArrayList<Integer> list = new ArrayList<Integer>();
            for (int f = 0; f < m2.nt(); f++) {
                if (LSD(m2.Nt(f), m1, m1.v(i))) {
                    list.add(f);
                }
                V2F.put(i, list);
            }
        }
    }

    void edgeToEdge() {
        for (Entry<Integer, List<Integer>> entry1 : m1.edgeTriangles.entrySet()) {
            int e1 = entry1.getKey();
            EdgePoints edge1 = m1.makeEdge(m1.edges.get(e1));
            List<Integer> t1 = entry1.getValue();

            for (Entry<Integer, List<Integer>> entry2 : m2.edgeTriangles.entrySet()) {
                int e2 = entry2.getKey();
                EdgePoints edge2 = m2.makeEdge(m2.edges.get(e2));
                List<Integer> t2 = entry2.getValue();

                List<vec> tangents = new ArrayList<vec>();

                for (Integer t : t1) {
                    tangents.add(N(V(edge1), m1.Nt(t)));
                }

                for (Integer t : t2) {
                    tangents.add(N(V(edge2), m2.Nt(t)));
                }

                vec N = N(V(edge1), V(edge2));

                boolean oneTested = true,
                        sign = false,
                        result = false;

                for (vec v : tangents) {
                    if (d(N, v) == 0) {
                        result = false;
                        break;
                    }

                    if (!oneTested) {
                        oneTested = true;
                        sign = d(N, v) < 0;
                    } else {
                        if ((d(N, v) < 0) != sign) break;
                        result = true;
                    }
                }

                if (result) {
                    if (!E2E.containsKey(e1)) E2E.put(e1, new ArrayList<Integer>());
                    E2E.get(e1).add(e2);
                }
            }
        }


        for (int i = 0; i < m1.edgeTriangles.size(); i++) {
            for (int j = 0; j < m2.edges.size(); j++) {
                EdgePoints e1 = m1.makeEdge(m1.edges.get(i));
                EdgePoints e2 = m2.makeEdge(m2.edges.get(j));
                vec normal = N(V(e1), V(e2));

            }
        }
    }

    boolean LSD(vec N, Mesh m, int v) {
        List<Integer> edges = m.vertexEdges.get(v);
        for (Integer e : edges) {
            EdgePoints edge = m.makeEdge(m.edges.get(e));
            if (d(N, V(edge)) >= 0) return false;
        }
        return true;
    }
};
