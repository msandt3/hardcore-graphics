void writeHelp () {fill(dblue);
    int i=0;
    scribe("CONTROLS: ",i++);
    scribe("Edit Solid by pressing 1,2,3,4 for the respective solid ",i++);
    scribe("Control Curve: e: pick and drag points, i: insert point at click, C: make convex, s: subdivide ",i++);
    scribe("Control Curve: d: delet point at click",i++);
    scribe("Solid: ,: increase number of rotations, ,: decrease number of rotations",i++);
    scribe("Solid: p: rotate solid on it's I axis, o: rotate solid on K axis with mouse, q: spin solid on its J axis",i++);
    scribe("Misc: a: stop animation, d: neville/single, t: move timestep, g:Gouraud/flat, W: save solid data to file",i++);
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
