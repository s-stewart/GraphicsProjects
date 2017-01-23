FR F0 = F(), F1 = F(), F1rF0, E0, E0rF0, cF, E, Ft, Et, Fk;
int k=7;
FR F() {return new FR();}
FR F(pt A, pt B, pt C) {return new FR(A,B,C);}
FR F(vec I, vec J, vec K, pt O) {return new FR(I,J,K, O);}
FR F(FR F) {return F(F.I,F.J,F.K,F.O);}
FR F(FR Fa, float t, FR Fb) {
  
   ///////////////////////////////////////////////////////////////
   //Compute axis of rotation   
   vec N = rAxis(Fa, Fb);
   //stroke(red); show(P(),100,N);  
    
   
   ///////////////////////////////////////////////////////////////
   // Compute angle and scale of rotation   
   vec FaIp = projPlane(Fa.I, P(), N);
   //stroke(black); show(P(),FaIp);
   
   vec FbIp = projPlane(Fb.I, P(), N);
   //stroke(black); show(P(),FbIp);
   
   float alpha = angle(FaIp,FbIp);
   float m = FbIp.norm()/FaIp.norm();
   
   print("\n alpha" + alpha*180/PI);
   //print("\n scale" + m);
   
   ////////////////////////////////////////////////////////////////
   // Assert correct angle   
    vec F1Ip = projPlane(F1.I, P(), N);
    float theta = angle(F1Ip,FaIp);
    
    print("\n theta: " + theta *180/PI + "\t k*theta: " + k*theta*180/PI);
    
    int loops = int(k*theta/PI);
    if(loops%2 == 0) alpha =  alpha+loops*PI;
    else alpha = alpha-(loops+1)*PI;
    print("\n new-alpha" + alpha*180.0/PI);
    
    print("\n loops: " + loops);
   
   
   
   ////////////////////////////////////////////////////////////////
   // Assert correct orientation of rotation axis   
   if(dot(N,N(FaIp,FbIp))<0) N=M(N);
   
      
   ////////////////////////////////////////////////////////////////
   // compute center
   
   //float c = cos(alpha), s=sin(alpha), t1=1-c, x=N.x,y=N.y,z=N.z;
   
   //PMatrix3D R = new PMatrix3D(  t1*x*x+c, t1*x*y-z*c, t1*x*z+y*s, 0,
   //                    t1*x*y+z*s, t1*y*y+c, t1*y*z-x*s, 0,
   //                    t1*x*z-y*s, t1*y*z+x*s, t1*z*z+c, 0,
   //                    0,0,0,1);
                                  
   PMatrix3D R  = new PMatrix3D();
   R.rotate(alpha,N.x,N.y,N.z);  
   R.scale(m);   
   PMatrix3D A  = new PMatrix3D( 1-R.m00, -R.m01, -R.m02, 0,
                                 -R.m10, 1-R.m11, -R.m12, 0,
                                 -R.m20, -R.m21, 1-R.m22, 0,
                                  0,0,0,1);
   A.invert();
   
   float[] p0 = {Fa.O.x, Fa.O.y, Fa.O.z};
   float[] p0r = new float[3];
   R.mult(p0,p0r);
   
 
   float[] b = {Fb.O.x-p0r[0], Fb.O.y-p0r[1], Fb.O.z-p0r[2]};
   float[] f = new float[3];
   A.mult(b,f);
   
   
   pt center = P(f[0],f[1],f[2]);
   //stroke(red); show(center,4); show(center,100,N); 
   
   /////////////////////////////////////////////////////////////
   /////// Now interpolate
   
   PMatrix3D Rt  = new PMatrix3D();
   Rt.rotate(alpha*t,N.x,N.y,N.z);
   Rt.scale(pow(m,t));
   
   float[] I ={Fa.I.x, Fa.I.y, Fa.I.z};
   float[] J ={Fa.J.x, Fa.J.y, Fa.J.z};
   float[] Ir = new float[3];
   float[] Jr = new float[3];
   
   Rt.mult(I,Ir); Rt.mult(J,Jr);
   vec It = V(Ir[0],Ir[1],Ir[2]);
   vec Jt = V(Jr[0],Jr[1],Jr[2]);
   vec Kt = V(It.norm(),U(N(It,Jt)));
   
   float[] FP0 = {Fa.O.x-center.x, Fa.O.y-center.y, Fa.O.z-center.z};
   float[] FP0r = new float[3];
   Rt.mult(FP0,FP0r);
   
   pt Ot = P(center.x+FP0r[0], center.y+FP0r[1], center.z+FP0r[2]);
   return F(It, Jt, Kt, Ot);
 }
 
vec rAxis(FR Fa, FR Fb)
{
  vec V1=U(M(U(Fa.I),U(Fb.I))); vec V2=U(M(U(Fa.J),U(Fb.J))); vec V3=U(M(U(Fa.K),U(Fb.K)));
  vec N = U(V(1.0/3.0,U(N(V1,V2)),1.0/3.0,U(N(V2,V3)),1.0/3.0,U(N(V3,V1))));
  return N;
}


pt projPlane(pt P, pt O, vec N)
{
  float a=N.x, b=N.y, c=N.z, x=P.x, y=P.y, z=P.z, d=O.x, e=O.y, f=O.z;
  float t = (a*d-a*x+b*e-b*y+c*f-c*z)/(a*a+b*b+c*c);
  return new pt(x+t*a, y+t*b, z+t*c);
}

vec projPlane(vec V, pt O, vec N)
{
 vec U = V(d(V,N),U(N));
 return M(V,U);
}

void showArrow(FR F) {F.showArrow();}
void showArrows(FR F) {F.showArrows();}

class FR { 
   pt O; vec I; vec J; vec K; 
   FR () {O=P(); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1);}
   FR(vec II, vec JJ, vec KK, pt OO) {I=V(II); J=V(JJ); K=V(KK); O=P(OO);}
   FR(pt A, pt B, pt C) {O=P(A); I=V(A,B); J=V(A,C); K=V(I.norm(),U(N(I,J)));}
   vec of(vec V) {return V(V.x,I,V.y,J,V.z,K);}
   pt of(pt P) {return P(O,V(P.x,I,P.y,J,P.z,K));}
   FR of(FR F) {return F(of(F.I),of(F.J),of(F.K),of(F.O));}
   vec invertedOf(vec V) {return V(dot(V,I)/dot(I,I), dot(V,J)/dot(J,J), dot(V,K)/dot(K,K));}
   pt invertedOf(pt P) {vec V = V(O,P); return P(dot(V,I)/dot(I,I), dot(V,J)/dot(J,J), dot(V,K)/dot(K,K));}
   FR invertedOf(FR F) {return F(invertedOf(F.I),invertedOf(F.J),invertedOf(F.K),invertedOf(F.O));}
   FR showArrow() {show(O,3); show(O,I); return this;}
   FR showArrows() {show(O,3); show(O,I); show(O,J); show(O,K); return this; }
 }