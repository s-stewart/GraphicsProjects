// GLOBAL VARIABLES
int showSkeletOnly=1;
int rings=1;                               // number of rings for colorcoding
int r=100;                                // radius of spheres for displaying vertices

class Mesh {
int w=2;                                   // size of initial Tmesh-grid made in setup
int NULL = -9999;

//  ==================================== INIT, CREATE, COPY MESH ====================================
 Mesh() {}
 void declare() {
   for (int i=0; i<maxnv; i++) {G[i]=new pt(0,0,0); Nv[i]=new vec(0,0,0);};   // init vertices and normals
   for (int i=0; i<maxnt; i++) {Nt[i]=new vec(0,0,0);  };       // init triangle normals and skeleton lab els
   }
 void init() { 
   for (int i=0; i<maxnt; i++) {Nt[i]=new vec(0,0,0); visible[i]=true;};  
   //computeO(); 
   computeValenceAndResetNormals(); 
   computeTriNormals(); 
   computeVertexNormals(); 
   c=0; sc=0;  
  }
  

//  ==========================================================  VERTICES ===========================================
 int maxnv = 20000;                              //  max number of vertices
 int nv = 0;                                     // current  number of vertices
 pt[] G = new pt [maxnv];                        // geometry table (vertices)
 vec[] Nv = new vec [maxnv];                     // vertex normals or laplace vectors
 int[] Mv = new int[maxnv];                      // vertex markers
 int [] Valence = new int [maxnv];               // vertex valence (count of incident triangles)
 boolean [] Border = new boolean [maxnv];        // vertex is border
 boolean [] VisitedV = new boolean [maxnv];      // vertex visited


void computeVertexNormals() {                            // computes the vertex normals as sums of the normal vectors of incident tirangles scaled by area/2
  for (int i=0; i<nv; i++) {Nv[i].setTo(0,0,0);};        // resets the valences to 0
  for (int i=0; i<3*nt; i++) {Nv[v(i)].add(Nt[t(i)]);};
  for (int i=0; i<nv; i++) {Nv[i].makeUnit();}; 
  };
  
  
int addVertex(pt P) { G[nv].setTo(P); nv++; return nv-1;};
int addVertex(float x, float y, float z) { G[nv].x=x; G[nv].y=y; G[nv].z=z; nv++; return nv-1;};


//  ==========================================================  TRIANGLES ===========================================
 int maxnt = maxnv*2;                       // max number of triangles
 int nt = 0;                                // current and max number of triangles
 vec[] Nt = new vec [maxnt];                // vtriangles normals
 boolean[] visible = new boolean[maxnt];    // set if triangle visible
 int[] Mt = new int[maxnt];                 // triangle markers for distance and other things   
 boolean [] VisitedT = new boolean [maxnt];  // triangle visited
 
pt triCenter(int i) {return(triCenterFromPts( G[v(3*i)], G[v(3*i+1)], G[v(3*i+2)] )); };  pt triCenter() {return triCenter(t());}  // computes center of triangle t(i) 
vec triNormal(int i) { return(triNormalFromPts(G[v(3*i)], G[v(3*i+1)], G[v(3*i+2)])); };  vec triNormal() {return triNormal(t());} // computes triangle t(i) normal * area / 2
void computeTriNormals() {for (int i=0; i<nt; i++) {Nt[i].setToVec(triNormal(i)); }; };             // caches normals of all tirangles
void writeTri (int i) {println("T"+i+": V = ("+v(i)+":"+v(i+1)+","+v(i+2)+":"); };//+v(o(3*i+1))+","+V[3*i+2]+":"+v(o(3*i+2))+")"); };
void hitTriangle() {
  prevc = c;       // save for geodesic 
  float smallestDepth=10000000;
  boolean hit=false;
  for (int t=0; t<nt; t++) {
    if (rayHitTri(eye,mark,g(3*t),g(3*t+1),g(3*t+2)))
      {
        hit=true;
        float depth = rayDistTriPlane(eye,mark,g(3*t),g(3*t+1),g(3*t+2));
        if ((depth>0)&&(depth<smallestDepth)) {smallestDepth=depth;  c=3*t;};
      }; 
    };
  if (hit) {
    pt X = eye.make(); X.addScaledVec(smallestDepth,eye.vecTo(mark));
    mark.setToPoint(X);
    float distance=X.disTo(g(c));
    int b=c;
    if (X.disTo(g(n(c)))<distance) {b=n(c); distance=X.disTo(g(b)); };
    if (X.disTo(g(p(c)))<distance) {b=p(c);};
    c=b;
    println("c="+c+", pc="+prevc+", t(pc)="+t(prevc));
    };
}
  
  
void addTriangle(int i, int j, int k) {V[nc++]=i; V[nc++]=j; V[nc++]=k; nt++;};
  
  
  
  
// ============================================= MY TABLES =======================================
  
int[] C = new int[maxnv];                     // C(orner) table. 3 corners per triangle. One per vertex?
int[] S = new int[3*maxnt];                // S(wing) table.  
  
  
  
// ============================================= DISPLAY =======================================
pt Cbox = new pt(width/2,height/2,0);                   // mini-max box center
float Rbox=1000;                                        // Radius of enclosing ball
boolean showEdges=false;
boolean showDistance=false;
boolean showNormals=false;
boolean showPath=false;
boolean showVertices=false;
boolean showEBrec=false;

void computeBox() {
  pt Lbox =  G[0].make();  pt Hbox =  G[0].make();
  for (int i=1; i<nv; i++) { 
    Lbox.x=min(Lbox.x,G[i].x); Lbox.y=min(Lbox.y,G[i].y); Lbox.z=min(Lbox.z,G[i].z);
    Hbox.x=max(Hbox.x,G[i].x); Hbox.y=max(Hbox.y,G[i].y); Hbox.z=max(Hbox.z,G[i].z); 
    };
  Cbox.setToPoint(midPt(Lbox,Hbox));  Rbox=Cbox.disTo(Hbox);
  println("Box r="+Rbox); print("C="); Cbox.write(); print("L="); Lbox.write(); print("H="); Hbox.write();
  };
  
  
pt cg(int c) {pt cPt = midPt(g(c),midPt(g(c),triCenter(t(c))));  return(cPt); };   // computes point at corner
void showCorner(int c, int r) {pt cPt = midPt(g(c),midPt(g(c),triCenter(t(c))));  cPt.show(r); };   // renders corner c as small ball
void showCornerAndNormal(int c, int r) {pt cPt = midPt(g(c),midPt(g(c),triCenter(t(c))));  noStroke(); cPt.show(r); 
                     stroke(magenta); vec N = Nt[t(c)].make(); N.makeUnit();  N.mul(10*r);  N.show(cPt);};   // renders corner c as small ball
void drawEdge(int c) {
                        //print ("c: " + c + "\n");
                        //print ("p(c): " + p(c) + "\n");
                        line(g(p(c)).x,g(p(c)).y, g(p(c)).z,  g(n(c)).x,g(n(c)).y,g(n(c)).z); 
                     };  // draws edge of t(c) opposite to corner c
void showBorder() {for (int i=0; i<nc; i++) {if (visible[t(i)]&&border(i)) {drawEdge(i);}; }; };         // draws all border edges
void shade(int i) 
      {
        if(visible[i]) 
        {
        beginShape(TRIANGLES); 
        G[v(3*i)].vert();
        G[v(3*i+1)].vert();
        G[v(3*i+2)].vert();
        endShape();
      };
    }; // shade tris
void showTriNormals() {vec N= new vec(0,0,0); for (int i=0; i<nt; i++) { N.setToVec(Nt[i]); N.makeUnit();  N.mul(5*r);  N.show(triCenter(i)); };  };
void showVertexNormals() {vec N= new vec(0,0,0); for (int i=0; i<nv; i++) {N.setToVec(Nv[i]); N.makeUnit(); N.mul(5*r);  N.show(G[i]); };  };
void show() {
  int col=60;
  noSmooth(); noStroke();
  if(showDistance) for(int t=0; t<nt; t++) {fill(60,120,(rings-Mt[t])*120/rings); shade(t);};   
  if(!showEB&&!showDistance) {fill(cyan); for(int t=0; t<nt; t++)  shade(t); };  
  smooth();
  if (showEdges) {stroke(red); for(int i=0; i<nc; i++) if(visible[t(i)]) drawEdge(i);};  
  //stroke(dblue); showBorder();
  if (showVertices) {noStroke(); noSmooth();
    for (int v=0; v<nv; v++) {if (Tv[v]==0) fill(blue); if (Tv[v]==1) fill(red); if (Tv[v]==2) fill(green); G[v].show(r); };
    };
  if (showLabels) { fill(black); for (int i=0; i<nv; i++) {G[i].label(str(i),labelD); }; };
  if (showNormals) {stroke(blue); showTriNormals(); stroke(magenta); showVertexNormals(); };                // show triangle normals
  if (showSelectedTriangle) {
    noStroke(); fill(green);  /*print(t(c) + "\n");*/ shade(t(c));
    fill(blue); stroke(dblue); showCornerAndNormal(c,r);  fill(cyan); noStroke(); showCornerAndNormal(prevc,r);  
 
    }; 
  fill(dred); mark.show(r); // stroke(red); line(eye.x,eye.y,eye.z,mark.x,mark.y,mark.z);
  noFill(); stroke(orange); vec nH = holeNormal.make(); nH.mul(100); nH.show(holeCenter);
  }




// ============================================= CORNER OPERATORS =======================================
 int nc = nt*3;                             // current number of corners (3 per triangle)
 int c = 0;                                 // current corner shown in image and manipulated with keys: n, p, o, l, r
 int sc=0;                                  // saved value of c
 int[] V = new int [3*maxnt];               // V table (triangle/vertex indices)
 //int[] O = new int [3*maxnt];               // O table (opposite corner indices)
 int[] W = new int [3*maxnt];               // mid-edge vertex indices for subdivision (associated with corner opposite to edge)
 int[] Tc = new int[3*maxnt];               // corner type

int t (int c) { int r=int(c/3); return(r); };                  
    int t() {return t(c);}                             
int n (int c) { int r=3*int(c/3)+(c+1)%3; return(r); };      
    int n() {return n(c);}                               
int p (int c) { int r=3*int(c/3)+(c+2)%3; return(r);};             
    int p() {return p(c);}                              
int v (int c) { while(S[c] > 0) c = S[c];  return abs(S[c]+1);};  
    int v() {return v(c);}                           
int o (int c) { return n(s(n(c)));};                      
    int o() {return o(c);}
int l (int c) { return(o(n(c)));};  
    int l() {return l(c);}
int s (int c) {
    if ( S[c] > 0 ) //if swing isn't a vertex
    {
     if  ( visible[ t(S[c]) ] ) //and it's visible
       return S[c];//it's simply the swing
     else  //search for the next visible and non-vertex swing
     {
       while (S[c] < 0 || !visible[ t(S[c]) ]) // if it's a vertex or invislbe, get the next
       {
         if (S[c] < 0) c = C[v(c)]; //if it's a vertex, get the first corner
         else c = S[c]; //otherwise, just get the next corner
       }
       return c; //return the first non-vertex, visible corner swung to
     }
    }
    
    else if ( S[c] < 0 ) //if swing is a vertex
    {
     if (visible [ t(C[v(c)]) ] ) // and the first corner is visible
       return C[v(c)]; //return the first corner
     else  //search for the next visible and non-vertex swing
     {
       while (S[c] < 0 || !visible[ t(S[c]) ]) // if it's a vertex or invislbe, get the next
       {
         if (S[c] < 0) c = C[v(c)]; //if it's a vertex, get the first corner
         else c = S[c]; //otherwise, just get the next corner
          
       }
       return c; //return the first non-vertex, visible corner swung to
     }
    }
    
    else
    {
     println("No swing found");
     noLoop();
     exit() ;
     return 1;
      
    }
  
    //if      ( S[c] < 0 && !visible[t(C[v(c)])] ) { return S[C[v(c)]]; }
    //else if ( S[c] < 0 &&  visible[t(C[v(c)])] ) { return  C[v(c)];}
    //else if ( S[c] > 0 && !visible[t(S[c])] ) 
    //{ 
    // while ( S[c] < 0 || !visible[t(S[c])] )
    // {
    //   if (S[c] > 0) { c = S[c]; continue; }
    //   c = C[v(c)];
    // }  
    // return S[c];
    //}
    
    //else { return S[c]; } 
}
      int s() {return s(c);}
int u (int c) {int temp = C[v(c)]; while(s(temp) != c){ temp = s(temp); } return temp; } 
    int u() {return u(c);}
pt g (int c) {return ( G[v(c)] );}  
    pt g() {return g(c);}                     // shortcut to get the point of the vertex v(c) of corner c
    
int w (int c) {return(W[c]);};               // temporary indices to mid-edge vertices associated with corners during subdivision
boolean nb(int c) {  return n(c) == s(n(s(c))); }
    boolean nb() {return nb(c);}     // not border
boolean border (int c) { if (visible[s(n(s(c)))])return p(c) != s(n(s(c))); else {return false;}};  // returns true if corner is a border
  
void previous() {c=p();};
void next() {c=n();};
void unswing() {c=u();};
void opposite() {if(nb()) { p(s(c)); };};
void left() {next(); opposite();};
void swing() {c=s();};
void right() {previous(); opposite();};
void back() {opposite();};
void turn() {left(); next(); };

void writeCorner (int c) {println("c="+c+", n="+n(c)+", p="+p(c)+", v="+v(c)+", t="+t(c)+"."); }; 
void writeCorner () {writeCorner (c);}
void writeCorners () {for (int c=0; c<nc; c++) {println("T["+c+"]="+t(c)+", visible="+visible[t(c)]+", v="+v(c));};}

// ============================================= S TABLE RECONSTRUCTION =========================================
void fixS ()
{
  //int nIC [] = new int [maxnv];                   // number of incident corners
  //int maxValence=0;
  //for (int v=0; v<nv; v++) {nIC[v]=0; };
  //for (int c=0; c<nc; c++) {nIC[v(c)]++;}
  //for (int v=0; v<nv; v++) {if(nIC[v]>maxValence) {maxValence=nIC[v]; };};
  //println(" Max valence = "+maxValence+". ");
  //for (int i=0; i<nv; i++) //for every vertex
  //{
  //  int temp = C[v(i)]; //start at the first corner
  //  for (int ic=0; ic < nIC[i]; ic++)//up to the number of incident verticies
  //    {
  //      if (v(p(temp)) == v(n(S[temp]))) continue; //if it's natural swing is correct, go to next corner
  //      if (v(p(temp)) != v(n(S[temp]))) //if the swing of the corner is not a natural swing...
  //      {
  //        if (s(temp) > 0) //go until we find the natural swing
  //        {
  //          if (v(p(temp)) == v(n(S[temp])))  //if we find it found it
  //          {
  //            S[temp] = temp ;
  //          }
  //          temp = s(temp);
  //        }
  //        if(S[temp] > 0) {temp = S[temp];} else{ temp = C[v(i)]; } //otherwise, check the next corner
  //      }
  //    }
  //}
}

boolean nat(int c){
  if (p(c) == n(s(c))) return true;
  else return false;
}

int findnatswing(int c, int cc, int nat)
{
  if (nat == cc)
  {
    return nat;
  }
  return findnatswing(c, s(cc), nat);
}




                    // ============================================= O TABLE CONSTRUCTION =========================================
                    //void computeOnaive() {                         // sets the O table from the V table, assumes consistent orientation of triangles
                    //  for (int i=0; i<3*nt; i++) {O[i]=-1;};  // init O table to -1: has no opposite (i.e. is a border corner)
                    //  for (int i=0; i<3*nt; i++) {  for (int j=i+1; j<3*nt; j++) {       // for each corner i, for each other corner j
                    //      if( (v(n(i))==v(p(j))) && (v(p(i))==v(n(j))) ) {O[i]=j; O[j]=i;};};}; // make i and j opposite if they match         
                    //  };
                    
                    //void computeO() { 
                    //  int nIC [] = new int [maxnv];                   // number of incident corners
                    //  int maxValence=0;
                    //  for (int c=0; c<nc; c++) {O[c]=-1;};  // init O table to -1: has no opposite (i.e. is a border corner)
                    //  for (int v=0; v<nv; v++) {nIC[v]=0; };
                    //  for (int c=0; c<nc; c++) {nIC[v(c)]++;}
                    //  for (int v=0; v<nv; v++) {if(nIC[v]>maxValence) {maxValence=nIC[v]; };};
                    //  println(" Max valence = "+maxValence+". ");
                    //  int IC [][] = new int [maxnv][maxValence];                   // incident corners
                    //  for (int v=0; v<nv; v++) {nIC[v]=0; };
                    //  for (int c=0; c<nc; c++) {IC[v(c)][nIC[v(c)]++]=c;}
                    //  for (int c=0; c<nc; c++) {
                    //    for (int i=0; i<nIC[v(p(c))]; i++) {
                    //      int a = IC[v(p(c))][i];
                    //      for (int j=0; j<nIC[v(n(c))]; j++) {
                    //         int b = IC[v(n(c))][j];
                    //         if ((b==n(a))&&(c!=n(b))) {O[c]=n(b); O[n(b)]=c; };
                    //         };
                    //      };
                    //    };
                    //  }
                    
                    
                    //  ==========================================================  SIMPLIFICATION ===========================================
                    
                    //void flip() {flip(c);}
                    //void flip(int c) {      // fip edge opposite to corner c
                    //    V[n(o(c))]=v(c); V[n(c)]=v(o(c));
                    //    int co=o(c); O[co]=r(c); O[r(c)]=co; O[c]=r(co); O[r(co)]=c; O[p(c)]=p(co); O[p(co)]=p(c);
                    //  }
                      
                    //void doFlips() {  for (int c=0; c<3*nt; c++) {
                    //  if (nb(c)) {if (g(n(c)).disTo(g(p(c)))>g(c).disTo(g(o(c)))) {flip(c);}; }; };
                    //  } // assumes manifold
                    
                    //void collapse() {collapse(c);}
                    //void collapse(int c) {      // collapse edge opposite to corner c
                    //   int b=p(c), oc=o(c), vnc=v(n(c));
                    //   visible[t(c)]=false; visible[t(oc)]=false;
                    //   if (true) return;
                    //   for (int a=b; a!=n(oc); a=p(r(a))) {V[a]=vnc;}; V[p(c)]=vnc; V[n(oc)]=vnc; 
                    //    O[l(c)]=r(c); O[r(c)]=l(c);     O[l(oc)]=r(oc); O[r(oc)]=l(oc); 
                    //  }
                    
                    ////  ==========================================================  HOLES ===========================================
                    pt holeCenter = new pt (0,0,0);
                    vec holeNormal = new vec(0,0,1);
                    pt  centerOfHole() {pt C=new pt(0,0,0); int nb=0; for (int i=0; i<nc; i++) {if (visible[t(i)]&&border(i)) {nb++; C.addPt(g(p(i)));}; }; C.mul(1./nb); return C;};         // draws all border edges
                    vec  normalOfHole(pt C) {vec N=new vec(0,0,0); for (int i=0; i<nc; i++) {if (visible[t(i)]&&border(i)) N.add(cross(C.vecTo(g(p(i))),C.vecTo(g(n(i))))); }; N.makeUnit(); return N;};         // draws all border edges
                    //void excludeInvisibleTriangles () {for (int b=0; b<nc; b++) {if (!visible[t(o(b))]) {O[b]=-1;};};}
                    //void hole() {holeCenter.setTo(centerOfHole()); holeNormal.setTo(normalOfHole(holeCenter)); };
                    //void fanHoles() {
                    // println("FANHOLES: nv="+nv +", nt="+nt +", nc="+nc );
                    // for (int t=0; t<nt; t++) {VisitedT[t]=false;};
                    // int lnt=nt;
                    // int L=0;
                    // for (int cc=0; cc<nc; cc++) {
                    //  if (visible[t(cc)]&&(!VisitedT[t(cc)]) && (!nb(cc) )) {L++;
                    //     print("<"); G[nv].setTo(0,0,0); int hl=fanHole(cc,L); G[nv].mul(1.0/float(hl)); nv++; println("> hl="+hl);
                    //    };
                    //  };
                    //  for (int t=lnt; t<nt; t++) {visible[t]=true;};
                    //  nc=3*nt;
                    //  println("Filled "+L+" holes");
                    // }
                      
                    //int fanHole(int cc, int L) {
                    //int hl=0; int o=0;  int f=cc;
                    //VisitedT[t(f)]=true; hl++; o=3*nt; V[o]=nv; V[n(o)]=v(p(f)); V[p(o)]=v(n(f)); O[o]=f; O[f]=o; nt++; G[nv].addPt(g(p(f)));
                    //int lc=p(o); 
                    //f=n(f);  while(nb(f)) {f=n(o(f)); }; 
                    //while (f!=cc) {    
                    //      print("."); VisitedT[t(f)]=true; hl++; o=3*nt; V[o]=nv; V[n(o)]=v(p(f)); V[p(o)]=v(n(f)); O[o]=f; O[f]=o; nt++; G[nv].addPt(g(p(f)));
                    //     O[n(o)]=lc; O[lc]=n(o); lc=p(o);
                    //     f=n(f);  while(nb(f)&&(f!=cc)) {f=n(o(f)); }; 
                    //     }; 
                    // O[lc]=n(o(cc)); O[n(o(cc))]=lc; c=lc;
                    // return(hl);
                    // }
                      
                    //void compactVO() {  
                    //  println("COMPACT TRIANGLES: nv="+nv +", nt="+nt +", nc="+nc );
                    //  int[] U = new int [nc];
                    //  int lc=-1; for (int c=0; c<nc; c++) {if (visible[t(c)]) {U[c]=++lc; }; };
                    //  for (int c=0; c<nc; c++) {if (nb(c)) {O[c]=U[o(c)];} else {O[c]=-1;}; };
                    //  int lt=0;
                    //  for (int t=0; t<nt; t++) {
                    //    if (visible[t]) {
                    //      V[3*lt]=V[3*t]; V[3*lt+1]=V[3*t+1]; V[3*lt+2]=V[3*t+2]; 
                    //      O[3*lt]=O[3*t]; O[3*lt+1]=O[3*t+1]; O[3*lt+2]=O[3*t+2]; 
                    //      visible[lt]=true; 
                    //      lt++;
                    //      };
                    //    };
                    //nt=lt; nc=3*nt;    
                    //  println("      ...  NOW: nv="+nv +", nt="+nt +", nc="+nc );
                    //  }
                    
                    //void compactV() {  
                    //  println("COMPACT VERTICES: nv="+nv +", nt="+nt +", nc="+nc );
                    //  int[] U = new int [nv];
                    //  boolean[] deleted = new boolean [nv];
                    //  for (int v=0; v<nv; v++) {deleted[v]=true;};
                    //  for (int c=0; c<nc; c++) {deleted[v(c)]=false;};
                    //  int lv=-1; for (int v=0; v<nv; v++) {if (!deleted[v]) {U[v]=++lv; }; };
                    //  for (int c=0; c<nc; c++) {V[c]=U[v(c)]; };
                    //  lv=0;
                    //  for (int v=0; v<nv; v++) {
                    //    if (!deleted[v]) {G[lv].setToPoint(G[v]);  deleted[lv]=false; 
                    //      lv++;
                    //      };
                    //    };
                    // nv=lv;
                    // println("      ...  NOW: nv="+nv +", nt="+nt +", nc="+nc );
                    //  }
                    
                    void fanLakes() {for (int t=0; t<nt; t++) visible[t]=true; };  
                    
                    // =========================================== GEODESIC MEASURES, DISTANCES =============================
                    int[] Distance = new int[maxnt];           // triangle markers for distance fields 
                    int[] SMt = new int[maxnt];                // sum of triangle markers for isolation
                    int prevc = 0;                             // previously selected corner
                    
                    void computeDistance(int maxr) {
                     int tc=0;
                     int r=1;
                     for(int i=0; i<nt; i++) {Mt[i]=0;};  Mt[t(c)]=1; tc++;
                     for(int i=0; i<nv; i++) {Mv[i]=0;};
                     while ((tc<nt)&&(r<=maxr)) {
                         for(int i=0; i<nc; i++) {if ((Mv[v(i)]==0)&&(Mt[t(i)]==r)) {Mv[v(i)]=r;};};
                        for(int i=0; i<nc; i++) {if ((Mt[t(i)]==0)&&(Mv[v(i)]==r)) {Mt[t(i)]=r+1; tc++;};};
                        r++;
                        };
                     rings=r;
                     }
                      
                    //void computeIsolation() {
                    //  println("Starting isolation computation for "+nt+" triangles");
                    //  for(int i=0; i<nt; i++) {SMt[i]=0;}; 
                    //  for(c=0; c<nc; c+=3) {println("  triangle "+t(c)+"/"+nt); computeDistance(1000); for(int j=0; j<nt; j++) {SMt[j]+=Mt[j];}; };
                    //  int L=SMt[0], H=SMt[0];  for(int i=0; i<nt; i++) { H=max(H,SMt[i]); L=min(L,SMt[i]);}; if (H==L) {H++;};
                    //  c=0; for(int i=0; i<nt; i++) {Mt[i]=(SMt[i]-L)*255/(H-L); if(Mt[i]>Mt[t(c)]) {c=3*i;};}; rings=255;
                    //  for(int i=0; i<nv; i++) {Mv[i]=0;};  for(int i=0; i<nc; i++) {Mv[v(i)]=max(Mv[v(i)],Mt[t(i)]);};
                    //  println("finished isolation");
                    //  }
                      
                    //void computePath() {
                    //  for(int i=0; i<nt; i++) {Mt[i]=0;}; Mt[t(prevc)]=1; // Mt[0]=1;
                    //  for(int i=0; i<nc; i++) {P[i]=false;};
                    //  int r=1;
                    //  boolean searching=true;
                    //  while (searching) {
                    //     for(int i=0; i<nc; i++) {
                    //       if (searching&&(Mt[t(i)]==0)&&(o(i)!=-1)) {
                    //         if(Mt[t(o(i))]==r) {
                    //           Mt[t(i)]=r+1; 
                    //           P[i]=true; 
                    //           if(t(i)==t(c)){searching=false;};
                    //           };
                    //         };
                    //       };
                    //     r++;
                    //     };
                    //  for(int i=0; i<nt; i++) {Mt[i]=0;};
                    //  rings=1;
                    //  int b=c;
                    //  int k=0;
                    //   while (t(b)!=t(prevc)) {rings++;  
                    //   if (P[b]) {b=o(b); print(".o");} else {if (P[p(b)]) {b=r(b);print(".r");} else {b=l(b);print(".l");};}; Mt[t(b)]=rings; };
                    //  }
                    
                    //// ============================================================= SMOOTHING ============================================================
                    void computeValenceAndResetNormals() {      // caches valence of each vertex
                     for (int i=0; i<nv; i++) {Nv[i].setTo(0,0,0); Valence[i]=0;};  // resets the valences to 0
                     for (int i=0; i<nc; i++) { Valence[v(i) ]++; };
                     }
                    
                    void computeLaplaceVectors() {  // computes the vertex normals as sums of the normal vectors of incident tirangles scaled by area/2
                     computeValenceAndResetNormals();
                     for (int i=0; i<3*nt; i++) {Nv[v(p(i))].add(g(p(i)).vecTo(g(n(i))));};
                     for (int i=0; i<nv; i++) {Nv[i].div(Valence[i]);}; 
                     };
                      
                    //void tuck(float s) {for (int i=0; i<nv; i++) {G[i].addScaledVec(s,Nv[i]);}; };  // displaces each vertex by a fraction s of its normal
                    
                    //// ============================================================= SUBDIVISION ============================================================
                    //void splitEdges() {            // creates a new vertex for each edge and stores its ID in the W of the corner (and of its opposite if any)
                    // for (int i=0; i<3*nt; i++) {  // for each corner i
                    //   if(border(i)) {G[nv]=midPt(g(n(i)),g(p(i))); W[i]=nv++;}
                    //   else {if(i<o(i)) {G[nv]=midPt(g(n(i)),g(p(i))); W[o(i)]=nv; W[i]=nv++; }; };  // if this corner is the first to see the edge
                    //   };
                    // };
                      
                    //void bulge() {              // tweaks the new mid-edge vertices according to the Butterfly mask
                    // for (int i=0; i<3*nt; i++) {
                    //   if((nb(i))&&(i<o(i))) {    // no tweak for mid-vertices of border edges
                    //    if (nb(p(i))&&nb(n(i))&&nb(p(o(i)))&&nb(n(o(i))))
                    //     {G[W[i]].addScaledVec(0.25,midPt(midPt(g(l(i)),g(r(i))),midPt(g(l(o(i))),g(r(o(i))))).vecTo(midPt(g(i),g(o(i))))); };
                    //     }; 
                    //   };
                    // };
                      
                    void splitTriangles() {    // splits each tirangle into 4
                     for (int i=0; i<3*nt; i=i+3) {
                       V[3*nt+i]=v(i); V[n(3*nt+i)]=w(p(i)); V[p(3*nt+i)]=w(n(i));
                       V[6*nt+i]=v(n(i)); V[n(6*nt+i)]=w(i); V[p(6*nt+i)]=w(p(i));
                       V[9*nt+i]=v(p(i)); V[n(9*nt+i)]=w(n(i)); V[p(9*nt+i)]=w(i);
                       V[i]=w(i); V[n(i)]=w(n(i)); V[p(i)]=w(p(i));
                       };
                     nt=4*nt; nc=3*nt;
                     };
                    
                    ////// ============================================================= SKELETON ============================================================
                     int[] skeleton = new int [maxnt];          // 0 = water, 1=bridge, 2=skeleton
                     int[] Tv = new int[maxnv];                 // vertex type: 0=water, 1=border, 2=land
                     boolean[] P = new boolean [3*maxnt];       // marker of corners in a path to parent triangle

// ============================================================= ARCHIVAL ============================================================
 boolean flipOrientation=false;            // if set, save will flip all triangles

void saveMesh() {
  String [] inppts = new String [nv+1+nt+1];
  int s=0;
  inppts[s++]=str(nv);
  for (int i=0; i<nv; i++) {inppts[s++]=str(G[i].x)+","+str(G[i].y)+","+str(G[i].z);};
  inppts[s++]=str(nt);
  if (flipOrientation) {for (int i=0; i<nt; i++) {inppts[s++]=str(V[3*i])+","+str(V[3*i+2])+","+str(V[3*i+1]);};}
    else {for (int i=0; i<nt; i++) {inppts[s++]=str(V[3*i])+","+str(V[3*i+1])+","+str(V[3*i+2]);};};
  saveStrings("mesh.vts",inppts);  println("saved on file");
  };

void loadMesh() {
  println("loading fn["+fni+"]: "+fn[fni]); 
  String [] ss = loadStrings(fn[fni]);
  String subpts;
  int s=0;   int comma1, comma2;   float x, y, z;   int a, b, c;
  nv = int(ss[s++]);
    print("nv="+nv+"\n");
    for(int k=0; k<nv; k++) {int i=k+s; 
      comma1=ss[i].indexOf(',');   
      x=float(ss[i].substring(0, comma1));
      String rest = ss[i].substring(comma1+1, ss[i].length());
      comma2=rest.indexOf(',');    y=float(rest.substring(0, comma2)); z=float(rest.substring(comma2+1, rest.length()));
      G[k].setTo(x,y,z);
      print("vertex: " + x +", " + y + ", "+ z+ "\n");
    };
  s=nv+1;
  nt = int(ss[s]); 
  nc=3*nt;
  println(", \n nt="+nt);
  s++;
  
  int cc = 0;
  for(int i=0; i<nv; i++){
      C[i] = NULL; //NULL = -9999
  }
  
  for(int i=0; i<3*nt; i++){
    S[i] = NULL;
  }
    
  //int[] sortArray = new int[3];
  
  for(int k=0; k < nt; k++) {int i=k+s;
      comma1=ss[i].indexOf(',');   a=int(ss[i].substring(0, comma1));  
      String rest = ss[i].substring(comma1+1, ss[i].length()); comma2=rest.indexOf(',');  
      b=int(rest.substring(0, comma2)); c=int(rest.substring(comma2+1, rest.length()));
      print("triangle: " + a +", " + b + ", "+ c+ "\n");
      //sortArray[0]=a;sortArray[1]=b;sortArray[2]=c;
      //sortArray = sort(sortArray);
      //a = sortArray[0]; b = sortArray[1]; c = sortArray[2]; 
      if (C[a] == NULL){ C[a]=cc; S[C[a]] = -a-1; cc++; } 
          else if (S[C[a]] < 0 && S[C[a]] != NULL) {   S[cc] = -a-1; S[C[a]] = cc;  cc++;} 
          else 
          { 
            int temp = S[C[a]]; 
            while(S[temp] > 0) { temp = S[temp];} 
            S[temp] = cc; 
            S[cc] = -a-1;
            cc++;
           // break;
          } 
          
     if (C[b] == NULL){ C[b]=cc; S[C[b]] = -b-1; cc++; } 
          else if (S[C[b]] < 0 && S[C[a]] != NULL) {  S[cc] = -b-1; S[C[b]] = cc; cc++; } 
          else 
          { 
            int temp = S[C[b]]; 
            while(S[temp] > 0) { temp = S[temp];} 
            S[temp] = cc; 
            S[cc] = -b-1;
            cc++;
          } 
          
     if (C[c] == NULL){ C[c]=cc; S[C[c]] = -c-1; cc++; } 
          else if (S[C[c]] < 0 && S[C[a]] != NULL) {  S[cc] = -c-1; S[C[c]] = cc; cc++; } 
          else 
          { 
            int temp = S[C[c]]; 
            while(S[temp] > 0) { temp = S[temp];} 
            S[temp] = cc;
            S[cc] = -c-1;
            cc++;
          } 
    }
    
    for(int i=0; i<nv; i++){
    print("C[" + i + "] = " + C[i] + "\n");
    }
    print("\n");
    for(int i=0; i<3*nt; i++){
     print("S[" + i + "] = " + S[i]+ "\n");
    }
    
  };
  
} // ==== END OF MESH CLASS
  
  
  
float log2(float x) {float r=0; if (x>0.00001) { r=log(x) / log(2);} ; return(r);}
vec labelD=new vec(-10,-10, 2);           // offset vector for drawing labels
int maxr=1;