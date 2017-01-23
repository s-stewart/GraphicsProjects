boolean showHelpText=true;
  void showHelp() {
    fill(yellow,50); rect(0,0,height,height); pushMatrix(); translate(20,20); fill(0);
        text("                    CURVE EDITOR written by Jarek Rossignac in March 2007",0,0); translate(0,20);
       translate(0,20);
        text("Click in this window. Press SPACE to show/hide this help text  ",0,0); translate(0,20);
        text("CORNER OPS: c_orner_pick, p_reious, n_ext, o_pposite, l_eft, e_ight,t_urn-around_vertex, w_rite",0,0); translate(0,20);
        text("TRIANGLE OPS: 'f' flip edge, 'm' merge vertices', 'k' hide/rveal triangle  ",0,0); translate(0,20);
        text("MESH OPS: 'R' refine, 'S' smooth, 'M' mnimize, 'F' fill holes  ",0,0); translate(0,20);
        text("EDGEBREAKER: 'i' init, 'a' advance, 'b' compress, 'B' show colors   ",0,0); translate(0,20);
        text("DISTANCE: 'D' show, 'I' isolation, 'P' path, 'd' distance, ',' smaller, '.' larger, '0' zero   ",0,0); translate(0,20);
        text("FILES: 'g' next file. 'G' read from file, 'A' archive.",0,0); translate(0,20);
        text("VIEW: 'z' zoom, 'H home, 'j' jump, 'J' jumping,   ",0,0); translate(0,20);
        text("DISPLAY: 'E' edges, 'V' vertices, 'N' normals, ",0,0); translate(0,20);
        text("   ",0,0); translate(0,20);
        text("If running local: 'W' to save points and 'X' to save a picture (DO NOT USE IN WEB BROWSER!).",0,0); translate(0,20);
 
     popMatrix(); noFill();
        }
  void keys() {
  if (key==' ') {showHelpText=!showHelpText;};
  if (key==',') {maxr--; if (maxr<1) maxr=1; M.computeDistance(maxr);};
  if (key=='.') {maxr++; M.computeDistance(maxr);};
  if (key=='0') {maxr=0; M.computeDistance(maxr);};
  if (key=='a') ;   
  if (key=='b') ;   
  if (key=='c') {C.setMark(); M.hitTriangle(); C.F.setToPoint(mark); C.pullE(); C.pose();  M.writeCorner(); };  
  if (key=='d') {M.computeDistance(maxr);}; 
  //if (key=='f') {M.flip();}; 
  if (key=='g') {fni=(fni+1)%fniMax; println("Will read model "+fn[fni]);};
  if (key=='i') ;   
  //if (key=='h') {M.hole();};   
  if (key=='j') ;
  if (key=='k') {C.setMark(); M.hitTriangle();  M.visible[M.t(M.c)] = !M.visible[M.t(M.c)]; };  
  if (key=='l') {M.left(); if (jumps) C.jump(M);};
  //if (key=='m') {M.collapse(); M.left();};   
  if (key=='n') {print("Next:");M.next();M.writeCorner();};  
  //if (key=='o') {M.opposite(); if (jumps) C.jump(M); };  
  if (key=='p') {print("Previous:");M.previous();M.writeCorner();};  
  if (key=='r') {M.right(); if (jumps) C.jump(M);}; 
  if (key=='s') {print("Swing:");M.swing();M.writeCorner();}; 
  if (key=='u') {print("Unswing:");M.unswing();M.writeCorner();};  
  if (key=='t') {M.turn();};  
  if (key=='w') {M.writeCorner();};  

  if (key=='A') {M.saveMesh(); };  
  if (key=='B') ; 
  //if (key=='C') {M.excludeInvisibleTriangles();  M.compactVO(); M.compactV();  println("...DONE removing triangles");  }; 
  if (key=='D') {M.showDistance=!M.showDistance;}; 
  if (key=='E') {M.showEdges=!M.showEdges; };  
  //if (key=='F') {M.excludeInvisibleTriangles(); M.fanHoles(); M.compactVO(); M.compactV();  println("...DONE filling holes");  }; 
  if (key=='G') {println("loading fn["+fni+"]: "+fn[fni]); M.loadMesh(); println("Loaded. "); M.init(); println("Initialized. "); initView(M);  };  
  if (key=='H') {C.F.setToPoint(Cbox); C.D=Rbox*2; C.U.setTo(0,1,0); C.E.setToPoint(C.F); C.E.addVec(new vec(0,0,1)); C.pullE(); C.pose();};
  //if (key=='I') {M.computeIsolation(); }; 
  if (key=='J') {jumps=!jumps; }; 
  //if (key=='M') {M.doFlips();}; 
  if (key=='N') {M.showNormals=!M.showNormals; };  
  //if (key=='P') {M.computePath(); M.showDistance=true;};
  //if (key=='R') {print("Subdividing..."); M.splitEdges(); M.bulge(); M.splitTriangles(); M.init(); println("done");};   // refine mesh
  //if (key=='S') {M.computeLaplaceVectors(); M.tuck(0.6); M.computeLaplaceVectors(); M.tuck(-0.6); };  
  if (key=='V') {M.showVertices=!M.showVertices; };  
  if (key=='X') {String S="mesh"+"-####.tif"; saveFrame(S);};   ;

  //if (key == BACKSPACE) { //remove triangle };
  if (keyCode==LEFT) {M.left(); M.right(); M.left(); if (jumps) {C.jump(M);};};
  if (keyCode==RIGHT) {M.right(); M.left(); M.right(); if (jumps) {C.jump(M);};};
  if (keyCode==DOWN) {M.back(); M.left(); M.right(); M.right(); M.left(); M.back(); if (jumps) {C.jump(M);}; };
  if (keyCode==UP) {M.left(); M.right(); M.right(); M.left(); if (jumps) {C.jump(M);};};
  }
  
  
void updateView() {
  if (keyCode==SHIFT) {C.Pan(); C.pullE(); };
  if (keyCode==CONTROL) {C.turn(); C.pullE(); };  
  if (key=='z') {C.pose(); C.zoom(); C.pullE(); };
   if (key=='1') {C.pose(); C.fly(1.0); C.pullE(); };  
   if (key=='2') {C.pose(); C.Pan(); C.pullE(); };
   if (key=='3') {C.pose(); C.fly(-1.0); C.pullE();  };
   if (key=='4') {C.pose(); C.Turn(); C.pullE(); };
   if (key=='5') {C.pan(); C.pullE(); }; 
  }

pt Mouse = new pt(0,0,0);                 // current mouse position
float xr, yr = 0;                         // mouse coordinates relative to center of window
int px=0, py=0;                           // coordinats of mouse when it was last pressed