//////////////////////////////////////////////////////////////////////////////
// Functions to compute medial axis of two 3d line segments

pt midPt(pt p0, vec u, pt q0, vec v)
{
  vec w0 = V(q0,p0);
  vec uv = M(u,v);
  float s = n2(uv)>0.000000000001 ? -dot(w0,uv)/n2(uv) : 0.0;  //time at which two points travelling on the line are closest
  
  pt ps = P(p0,s,u);
  pt qs = P(q0,s,v);
  
  return P(ps,qs);
}

void mApt(pts c1, pts c2, pt p, pt pp, vec ppv, pt cpp1, pt cpp2)
{
  /////////////////////////////////////////////////////////////////////////////
  // Compute closet/foot pt on curves c1 and c2

  int c1_i = 0, c2_i = 0;
  pt cp1=null, cp2=null; 
  
  float min_dist = 1000000;
  for(int i=0; i<c1.nv; i++)
  {
    float d = d(p,c1.G[i]);
    if(d<min_dist){ min_dist = d; c1_i = i;}
  }
  
  //print("\n c1_i: " + c1_i);
  
  min_dist = 1000000;  
  for(int i=0; i<c2.nv; i++)
  {
    float d = d(p,c2.G[i]);
    if(d<min_dist){min_dist = d; c2_i = i;}
  }
  
  //print("\n c2_i: " + c2_i);
  
  cp1 = P(c1.G[c1_i]);
  cp2 = P(c2.G[c2_i]);
  
 
  //show(p,cp1); // show connection to closest pt on c1
  //show(p,cp2); // show connection to closest pt on c2
  
  ////////////////////////////////////////////////////////////////////////////////
  // compute medial axis of tangents at foot pts
  
  //stroke(black); strokeWeight(2);
  //show(G[1],G[3]); show(R[1],R[3]);
  
  vec AB = c1_i>0? V(c1.G[c1_i-1], c1.G[c1_i]) : V(c2.G[1], c1.G[0]);
  vec BC = c1_i<c1.nv-1? V(c1.G[c1_i], c1.G[c1_i+1]) : V(c1.G[c1.nv-1], c2.G[c2.nv-2]);
  
  pt p0 = cp1; vec u = V(AB,BC);
  
  AB = c2_i>0? V(c2.G[c2_i-1], c2.G[c2_i]) : V(c1.G[1], c2.G[0]);
  BC = c2_i<c2.nv-1? V(c2.G[c2_i], c2.G[c2_i+1]) : V(c2.G[c2.nv-1], c1.G[c1.nv-2]);
  
  pt q0 = cp2; vec v = V(AB,BC);  
  
  if(c1_i > 0 && projectsBetween(p,c1.G[c1_i-1], c1.G[c1_i])==true){ p0 = projectionOnLine(p,c1.G[c1_i-1], c1.G[c1_i]);  u = V(c1.G[c1_i-1], c1.G[c1_i]);}
  if(c1_i < c1.nv-1 && projectsBetween(p,c1.G[c1_i], c1.G[c1_i+1])==true){ p0 = projectionOnLine(p,c1.G[c1_i], c1.G[c1_i+1]); u = V(c1.G[c1_i], c1.G[c1_i+1]); }

  if(c2_i > 0 && projectsBetween(p,c2.G[c2_i-1], c2.G[c2_i])==true){ q0 = projectionOnLine(p,c2.G[c2_i-1], c2.G[c2_i]); v = V(c2.G[c2_i-1], c2.G[c2_i]); }
  if(c2_i < c2.nv-1 && projectsBetween(p,c2.G[c2_i], c2.G[c2_i+1])==true){ q0 = projectionOnLine(p,c2.G[c2_i], c2.G[c2_i+1]); v = V(c2.G[c2_i], c2.G[c2_i+1]);}  
  
  u=U(u);
  v=U(v);
  
  pt mid = midPt(p0,u,q0,v); 
  //show(mid,4);
  //show(mid,10, V(u,v));
  
  pt A = mid;
  pt B = P(mid, V(u,v));
  
  pp.set(projectionOnLine(p, A, B));
  ppv.set(U(V(u,v)));
  cpp1.set(p0);
  cpp2.set(q0);
  
  if(V(u,v).norm() == 0.0) { print("\n" + u.x + "\t" + u.y + "\t" +u.z); print("\n" + v.x + "\t" + v.y + "\t" +v.z);}
}

void myShowQuads(pt[] C,float[] rC, int ne, color col, float theta) // based on Na = xU+yNb => x=Na.U/U.U =>Nb = (Na-x.U).normalized
{
  //print("\nlength:" + C.length);
  int nC = C.length;
  vec [] L = new vec[nC];
  L[0] = U(N(V(C[0],C[1]),V(0,0,1))); 
  pt [][] P = new pt [2][ne];
  int p=0; boolean dark=true;
  float [] c = new float [ne]; float [] s = new float [ne];
  for (int j=0; j<ne; j++) {c[j]=rC[0]*cos(theta*j/ne); s[j]=rC[0]*sin(theta*j/ne); }; 
  for (int j=0; j<ne; j++) P[p][j]=P(C[0],c[j],U(L[0]),s[j],U(N(U(L[0]),U(V(C[0],C[1])))));
  p=1-p;
  for (int i=1; i<nC-1; i++) 
  {   
    for (int j=0; j<ne; j++) {c[j]=rC[i]*cos(theta*j/ne); s[j]=rC[i]*sin(theta*j/ne); }
    dark=!dark;
    
    vec I=U(V(C[i-1],C[i])); vec Ip=U(V(C[i],C[i+1])); vec N=N(I,Ip); vec myU = U(C[i-1],C[i+1]);
    if (n(N)<0.001) L[i]=V(L[i-1]);
    else
    {
      float myX = dot(L[i-1],myU); 
      L[i] = U(V(L[i-1],-myX,myU));
    }    

    I=U(L[i]);
    vec J=U(N(I,myU));

    for (int j=0; j<ne; j++) P[p][j]=P(C[i],c[j],I,s[j],J); p=1-p;
    if(i>0)
    {
      for (int j=0; j<ne; j++) 
      {
          if(dark) fill(200,200,200); else fill(col); dark=!dark; strokeWeight(1); if(col==white) { stroke(magenta);strokeWeight(2); noFill();}
          int jp=(j+ne-1)%ne; beginShape(QUADS); v(P[p][jp]); v(P[p][j]); v(P[1-p][j]); v(P[1-p][jp]); endShape(CLOSE);
      }
    }
  }
}

void jarekShowQuads(pt[] C,float[] rC, int ne, color col, float theta) 
{
  //print("\nlength:" + C.length);
  int nC = C.length;
  vec [] L = new vec[nC];
  L[0] = U(N(V(C[0],C[1]),V(0,0,1))); 
  pt [][] P = new pt [2][ne];
  int p=0; boolean dark=true;
  float [] c = new float [ne]; float [] s = new float [ne];
  for (int j=0; j<ne; j++) {c[j]=0.5*(rC[0]+rC[1])*cos(theta*j/ne); s[j]=0.5*(rC[0]+rC[1])*sin(theta*j/ne); }; 
  for (int j=0; j<ne; j++) P[p][j]=P(P(C[0],C[1]),c[j],U(L[0]),s[j],U(N(U(L[0]),U(V(C[0],C[1])))));
  p=1-p;
  for (int i=1; i<nC-1; i++) 
  {   
    for (int j=0; j<ne; j++) {c[j]=0.5*(rC[i]+rC[i+1])*cos(theta*j/ne); s[j]=0.5*(rC[i]+rC[i+1])*sin(theta*j/ne); } 
    dark=!dark; 
    vec I=U(V(C[i-1],C[i])); vec Ip=U(V(C[i],C[i+1])); vec N=N(I,Ip); 
    if (n(N)<0.001) L[i]=V(L[i-1]);
    else L[i] = V( L[i-1] , m(L[i-1],U(N),I) , N(U(N),M(Ip,I)) );
    //print("\nLi" + L[i].x +"\t"+ L[i].y +"\t"+ L[i].z);
    //print("\nN(U(N),M(Ip,I))" + N(U(N),M(Ip,I)).x +"\t"+ N(U(N),M(Ip,I)).y +"\t"+ N(U(N),M(Ip,I)).z);
    L[i]=U(L[i]);
    I=U(L[i]);
    
    //print("\nLi" + L[i].x +"\t"+ L[i].y +"\t"+ L[i].z + "norm: " + sqrt(sq(L[i].x)+sq(L[i].y)+sq(L[i].z)) );
    //print("\nLinorm:" + sqrt(sq(L[i].x)+sq(L[i].y)+sq(L[i].z)));
    
    //print("\nI" + I.x +"\t"+ I.y +"\t"+ I.z);
    vec J=U(N(I,Ip));
    
    //print("\nI" + I.x +"\t"+ I.y +"\t"+ I.z);
    //print("\nJ" + J.x +"\t"+ J.y +"\t"+ J.z);
    for (int j=0; j<ne; j++) P[p][j]=P(P(C[i],C[i+1]),c[j],I,s[j],J); p=1-p;
    if(i>0)
    {
      for (int j=0; j<ne; j++) 
      {
          if(dark) fill(200,200,200); else fill(col); dark=!dark; strokeWeight(1); if(col==white) { stroke(black); noFill();}
          int jp=(j+ne-1)%ne; beginShape(QUADS); v(P[p][jp]); v(P[p][j]); v(P[1-p][j]); v(P[1-p][jp]); endShape(CLOSE);
      }
    }
  }
}

void ShowEquiArcLengthSampledTube(pts C, float l, float r, color col)
{
   //////////////////////////////////////////////////
   // Sample curve
   
   float min_dAlongArc = l;
   float dAlongArc = 0;
   pts sampledC = new pts(); sampledC.declare();     
   
   for(int i=1; i<C.nv; i++)
   {
     dAlongArc += d(C.G[i-1],C.G[i]);
     if(dAlongArc>min_dAlongArc)
     {
       sampledC.addPt(C.G[i]);
       dAlongArc = 0.0;
     }
   }   
   sampledC.addPt(C.G[C.nv-1]);
   
   ///////////////////////////////////////////////////
   // extract pts
   
   pt[] Cp = new pt[sampledC.nv];
   float[] rC = new float[sampledC.nv];
   
   for(int i=0; i<sampledC.nv; i++)
   {
     Cp[i] = P(sampledC.G[i]);
     rC[i] = r;
   }
   
   myShowQuads(Cp,rC,6,col,TWO_PI); 
}


void drawVarRadTube(pts ma, pts fp1, pts fp2, float theta, color col)
{
  pt[] mid_pts = new pt[ma.nv];
  float[] radii = new float[ma.nv];
  
  for(int i=0; i<ma.nv; i++)
  {
    //show(fp1.G[i],1); show(fp2.G[i],1);
  
    mid_pts[i] = P(fp1.G[i],fp2.G[i]);
    radii[i] = d(mid_pts[i],fp1.G[i]);
  }
  myShowQuads(mid_pts,radii,12,col,theta);  
}

void drawMorphs(pts ma, pts fp1, pts fp2)
{
  for(float i=0; i<=1.001; i+=0.1)
  {
    drawMorph(ma,fp1,fp2,i,black);
  }
}

void drawMorph(pts ma, pts fp1, pts fp2, float s, color col)
{
  pt[] ctrlPts1 = new pt[]{fp1.G[0],ma.G[0],ma.G[0],fp2.G[0]};
  pt arcPt1 = bezierPoint(ctrlPts1, s);
  pt arcPt2 = new pt();
  for(int i=1; i<ma.nv; i++)
  {
     pt[] ctrlPts2 = new pt[]{fp1.G[i],ma.G[i],ma.G[i],fp2.G[i]};
       
     arcPt2 = bezierPoint(ctrlPts2, s);
     stroke(black); strokeWeight(2); 
     
     stroke(col);
     show(arcPt1,arcPt2);
     arcPt1.set(arcPt2);              
  }
}