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

    /*void edgeToEdge() {
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

                boolean oneTested = false,
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
                        if ((d(N, v) < 0) != sign) {
                            result = false;
                            break;
                        } else {
                            result = true;
                        }
                    }
                }

                if (result) {
                    if (!E2E.containsKey(e1)) E2E.put(e1, new ArrayList<Integer>());
                    E2E.get(e1).add(e2);
                }
            }
        }
    }*/

    void edgeToEdge() {
        List<Integer> visited1 = new ArrayList<Integer>();
        for (int c1 = 0; c1 < m1.nc(); c1++) {
            int o1 = m1.o(c1);
            int tc1 = m1.t(c1);
            int to1 = m1.t(o1);
            Edge e1 = new Edge(m1.v(m1.n(o1)), m1.v(m1.p(o1)));
            EdgePoints edge1 = m1.makeEdge(e1);

            // prevent duplicates
            /*if (visited.contains(c1)) continue;
            else {
                visited.add(c1);
                visited.add(o1);
            }*/

            List<Integer> visited2 = new ArrayList<Integer>();
            for (int c2 = 0; c2 < m2.nc(); c2++) {
                List<vec> tangents = new ArrayList<vec>();

                int o2 = m2.o(c2);
                int tc2 = m2.t(c2);
                int to2 = m2.t(o2);
                Edge e2 = new Edge(m2.v(m2.n(o2)), m2.v(m2.p(o2)));
                EdgePoints edge2 = m2.makeEdge(e2);

                tangents.add(N(V(edge1), m1.Nt(tc1)));
                tangents.add(N(M(V(edge1)), m1.Nt(to1)));
                tangents.add(N(V(edge2), m2.Nt(tc2)));
                tangents.add(N(M(V(edge2)), m2.Nt(to2)));

                vec N = N(V(edge1), V(edge2));

                boolean oneTested = false,
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
                        if ((d(N, v) < 0) != sign) {
                            result = false;
                            break;
                        } else {
                            result = true;
                        }
                    }
                }

                if (result) {
                    if (!E2E.containsKey(c1)) E2E.put(c1, new ArrayList<Integer>());
                    E2E.get(c1).add(c2);
                }
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
}