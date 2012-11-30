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
			for (int j = 0; j < B.nc; j++) {
				if (LSD(A.Nt[i], B, B.V[j])) {
					list.add(B.G[B.V[j]]);
				}
			}
			
			F2V.put(i, list);
		}
	}

	void vertexToFace() {
		for (int i = 0; i < A.nc; i++) {
			ArrayList<Integer> list = new ArrayList<Integer>();
			for (int j = 0; j < B.nt; j++) {
				if (LSD(B.Nt[j], A, A.V[i])) {
					//println("i: " + i + " j: " + j);
					//println("i: " + i + " j: " + j);
					list.add(j);
					//print(j);
				}
				V2F.put(i, list);
			}
		}
	}
	// ==================== UTILITY FUNCTIONS FOR E2E MAPS ==================
	//get the tangents for a particular edge e in mesh m
	ArrayList<vec> getTangents(Edge e, Mesh m){
    	ArrayList<vec> tangents = new ArrayList<vec>();
    	for(int tri : e.triangles){
      		tangents.add(getTangent(e,m.Nt[tri]));
    	}
    	return tangents;
  	}
  	//get the tangents for a particular edge triangleNorm combination
  	vec getTangent(Edge e, vec faceNorm){
    	return N(V(e),faceNorm);
  	}
  	//get the average of the triangle normals for an edge in mesh m
  	vec getNormal(Edge e, Mesh m){
    	return V(m.Nt[e.triangles.get(0)],m.Nt[e.triangles.get(1)]);
  	}
  	vec getNormal(Edge e1, Edge e2){
  		return N(V(e1),V(e2));
  	}
  	boolean shouldMap(Edge e1, Mesh m1, Edge e2, Mesh m2){
  		vec norm = getNormal(e1,e2);
  		ArrayList<vec> e1tangents = getTangents(e1,m1);
  		ArrayList<vec> e2tangents = getTangents(e2,m2);
  		println("Number of tangents for edge 1 - "+e1tangents.size());
  		println("Number of tangents for edge 2 - "+e2tangents.size());

  		for (vec e1tangent : e1tangents){
  			if ( d(norm,e1tangent) >= 0 ){
  				println("Should not map edge - "+e1+" to edge "+e2);
  				return false;
  			}
  		}
  		for(vec e2tangent : e2tangents){
  			if ( d(norm,e2tangent) >= 0){
  				println("Should not map edge - "+e1+" to edge "+e2);
  				return false;
  			}
  		}
  		return true;
  	}
  	boolean shouldMap(Edge e, Mesh m){
  		vec norm = getNormal(e,m);
  		ArrayList<vec> tangents = getTangents(e,m);
  		for (vec tangent : tangents){
  			if( d(norm,tangent) > 0)
  				return false;
  		}
  		return true;
  	}
  	// =================== END E2E UTILITY FUNCTIONS =====================
	void edgeToEdge() {
		/*for (int i = 0; i < A.nv; i++) {
			ArrayList<vec> list = new ArrayList<vec>();
			for (int j = i + 0; j < B.nv; j++) {
				list.add(B.edgeMap.get(j));
			}

			E2E.put(i, list);
		}*/
		for (Edge e : A.edges) {
			ArrayList<Edge> list = new ArrayList<Edge>();
			for (Edge e2 : B.edges) {
				println(e2.triangles.size());
				//this is the check for positive dot products (not working)
				//if(shouldMap(e,A,e2,B))
					list.add(e2);
			}
			E2E.put(e, list);
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
