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
			float max = 0;
			int maxKey = 0;
			for (int j = 0; j < B.nv; j++) {
				float dot = d(A.Nt[i], B.Nv[j]);
				if (dot > max) {
					max = dot;
					maxKey = j;
				}
			}
			ArrayList<pt> list = new ArrayList<pt>();
			list.add(B.G[B.V[maxKey]]);
			F2V.put(i, list);
		}
	}

	void vertexToFace() {
		for (int i = 0; i < A.nt; i++) {
			float max = 0;
			int maxKey = 0;
			for (int j = 0; j < B.nv; j++) {
				float dot = d(A.Nv[i], B.Nt[j]);
				if (dot > max) {
					max = dot;
					maxKey = j;
				}
			}
			V2F.put(i, new ArrayList<Integer>(maxKey));
		}
	}

	void edgeToEdge() {
            //  for(int i=0;)
	}

	pt getBVertex(int v) {
		return B.G[B.V[v]];
	}
};
