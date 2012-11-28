class MeshMap {
	Mesh A;
	Mesh B;
	Map<Integer, List<Integer>> V2F;
	Map<Integer, List<pt>> F2V;
	Map<Edge, List<Edge>> E2E;

	MeshMap(Mesh A, Mesh B) {
		this.A = A;
		this.B = B;
		V2F = new HashMap<Integer, List<Integer>>();
		F2V = new HashMap<Integer, List<pt>>();
		E2E = new HashMap<Edge, List<Edge>>();
		faceToVertex();
		vertexToFace();
		edgeToEdge();
	}

	void clear() {
		A = null;
		B = null;
		V2F.clear();
		F2V.clear();
		E2E.clear();
	}

	void faceToVertex() {
		for (int i = 0; i < A.nt; i++) {
			ArrayList<pt> list = new ArrayList<pt>();
			for (int j = 0; j < B.nv; j++) {
				if (LSD(A.Nt[i], B, j)) {
					list.add(B.G[B.V[j]]);
				}
			}
			
			F2V.put(i, list);
		}
	}

	void vertexToFace() {
		for (int i = 0; i < A.nv; i++) {
			ArrayList<Integer> list = new ArrayList<Integer>();
			for (int j = 0; j < B.nt; j++) {
				if (LSD(B.Nt[j], A, i)) {
					//println("i: " + i + " j: " + j);
					list.add(j);
					//print(j);
				}
				V2F.put(i, list);
			}
		}
	}

	void edgeToEdge() {
		/*for (int i = 0; i < A.nv; i++) {
			ArrayList<vec> list = new ArrayList<vec>();
			for (int j = i + 0; j < B.nv; j++) {
				list.add(B.edgeMap.get(j));
			}

			E2E.put(i, list);
		}*/
		for (int i = 0; i < A.nv; i++) {
			for (Edge e : A.edgeMap.get(i)) {
				ArrayList<Edge> list = new ArrayList<Edge>();
				for (int j = 0; j < B.nv; j++) {
					for (Edge e2 : B.edgeMap.get(j)) {
						if (e != e2 && !E2E.containsKey(e2)) list.add(e2);
					}
				}
				E2E.put(e, list);
			}
		}
	}

	pt getBVertex(int v) {
		return B.G[B.V[v]];
	}

	boolean LSD(vec N, Mesh m, int v) {
		List<Edge> edges = m.edgeMap.get(v);
		for (Edge edge : edges) {
			if (d(N, V(edge)) >= 0) return false;
		}
		return true;
	}

	void remap() {
		V2F.clear();
		F2V.clear();
		E2E.clear();
		faceToVertex();
		vertexToFace();
		edgeToEdge();
	}
};