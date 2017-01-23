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
  
  //find the closest discritized point on curve 1
  float min_dist = 1000000;
  for(int i=0; i<c1.nv; i++)
  {
    float d = d(p,c1.G[i]);
    if(d<min_dist){ min_dist = d; c1_i = i;}
  }
  
  //print("\n c1_i: " + c1_i);
  
  //find the closest discritized point on curve 2
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
  
  if(c1_i > 0 && projectsBetween(p,c1.G[c1_i-1], c1.G[c1_i])){ p0 = projectionOnLine(p,c1.G[c1_i-1], c1.G[c1_i]);  u = V(c1.G[c1_i-1], c1.G[c1_i]);}
  if(c1_i < c1.nv-1 && projectsBetween(p,c1.G[c1_i], c1.G[c1_i+1])){ p0 = projectionOnLine(p,c1.G[c1_i], c1.G[c1_i+1]); u = V(c1.G[c1_i], c1.G[c1_i+1]); }

  if(c2_i > 0 && projectsBetween(p,c2.G[c2_i-1], c2.G[c2_i])){ q0 = projectionOnLine(p,c2.G[c2_i-1], c2.G[c2_i]); v = V(c2.G[c2_i-1], c2.G[c2_i]); }
  if(c2_i < c2.nv-1 && projectsBetween(p,c2.G[c2_i], c2.G[c2_i+1])){ q0 = projectionOnLine(p,c2.G[c2_i], c2.G[c2_i+1]); v = V(c2.G[c2_i], c2.G[c2_i+1]);}  
  
  u=U(u);
  v=U(v);
  
  pt mid = midPt(p0,u,q0,v);
  
  //show(mid,4);
  //show(mid,10, V(u,v));
  
  pt A = mid;
  pt B = P(mid, V(u,v));
  
  pp.set(projectionOnLine(p, A, B));
  ppv.set(U(V(u,v)));
  cpp1.set(cp1);
  cpp2.set(cp2);
  
  if(V(u,v).norm() == 0.0) { print("\n" + u.x + "\t" + u.y + "\t" +u.z); print("\n" + v.x + "\t" + v.y + "\t" +v.z);}
  
  
  //if(d(pp,p) <= 0.0001) drawArc(cp1, cp2, pp);
}

void drawArc(pt a, pt b, /*vec A, vec B, */pt m/*, pt c*/)
{
  
  noFill(); strokeWeight(1);
  beginShape();
  vertex(a.x, a.y, a.z);
  quadraticVertex(m.x, m.y, m.z, b.x, b.y, b.z);
  endShape();
  
  /*/Find the normal to the tangent vectors 
  //vec normal_N= U(N( a, b, c ));
  vec Normal = B(A,B);
  //Compute the angle between the curves in that plane
  vec b_trans = V(B, V(B,A));
  float ang = angle(b_trans, A);
  //draw the arc between the closest points on the curve
  */
}