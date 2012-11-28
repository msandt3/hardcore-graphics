class MeshMap {
	Mesh A;
	Mesh B;
	Map<Integer, List<Integer>> V2F;
	Map<Integer, List<pt>> F2V;
	Map<Integer, List<Integer>> E2E;

	MeshMap(Mesh A, Mesh B) {
		this.A = A;
		this.B = B;
		V2F = new HashMap<Integer, List<Integer>>();
		F2V = new HashMap<Integer, List<pt>>();
		E2E = new HashMap<Integer, List<Integer>>();
		faceToVertex();
		vertexToFace();
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

	}

	pt getBVertex(int v) {
		return B.G[B.V[v]];
	}

	boolean LSD(vec N, Mesh m, int v) {
		List<vec> edges = m.edgeMap.get(v);
		for (vec edge : edges) {
			if (d(N, edge) >= 0) return false;
		}
		return true;
	}
};