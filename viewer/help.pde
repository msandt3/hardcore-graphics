void writeHelp () {fill(dblue);
    int i=0;
    scribe("3D VIEWER 2012 (Brian Edmonds)",i++);
    scribe("CURVE t:show, s:move XY, a:move XZ , v:move all XY, b:move all XZ, A;archive, C.load",i++);
    scribe("MESH L:load, .:pick corner, Y:subdivide, E:smoothen, W:write, N:next, S.swing ",i++);
    scribe("VIEW space:pick focus, [:reset, ;:on mouse, E:save, e:restore ",i++);
    scribe("SHOW ):silhouette, B:backfaces, |:normals, -:edges, c:curvature, g:Gouraud/flat, =:translucent",i++);
    scribe("",i++);

   }
void writeFooterHelp () {fill(dbrown);
    scribeFooter("Brian Edmonds, Mike Sandt, Patrick Stoica Press ?:help",1);
  }
void scribeHeader(String S) {text(S,10,20);} // writes on screen at line i
void scribeHeaderRight(String S) {text(S,width-S.length()*15,20);} // writes on screen at line i
void scribeFooter(String S) {text(S,10,height-10);} // writes on screen at line i
void scribeFooter(String S, int i) {text(S,10,height-10-i*20);} // writes on screen at line i from bottom
void scribe(String S, int i) {text(S,10,i*30+20);} // writes on screen at line i
void scribeAtMouse(String S) {text(S,mouseX,mouseY);} // writes on screen near mouse
void scribeAt(String S, int x, int y) {text(S,x,y);} // writes on screen pixels at (x,y)
void scribe(String S, float x, float y) {text(S,x,y);} // writes at (x,y)
void scribe(String S, float x, float y, color c) {fill(c); text(S,x,y); noFill();}
;
