// Skate dancer on moving terrain
float dz=0; // distance to camera. Manipulated with wheel or when 
//float rx=-0.06*TWO_PI, ry=-0.04*TWO_PI;    // view angles manipulated when space pressed but not mouse
float rx=0, ry=0;    // view angles manipulated when space pressed but not mouse
Boolean twistFree=false, animating=true, tracking=false, center=true, gouraud=true, showControlPolygon=false, showNormals=false;
float t=0, s=0;
boolean viewpoint=false;
pt Viewer = P();
pt F = P(0,0,0);  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
pt Of=P(100,100,0), Ob=P(110,110,0); // red point controlled by the user via mouseDrag : used for inserting vertices ...
pt Vf=P(0,0,0), Vb=P(0,0,0);
boolean flip=false;

boolean show_crude_ma = false;
boolean show_curves = false,show_tubes = false, show_ma = false, show_tcurves = false; 
boolean show_morph = false, show_net = false, show_inflation = false, show_net_inflation = false;


void setup() {
  myFace = loadImage("data/team.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  textureMode(NORMAL);          
  size(600, 600, P3D); // p3D means that we will do 3D graphics
  P.declare(); Q.declare(); PtQ.declare(); // P is a polyloop in 3D: declared in pts
  P.resetOnCircle(8,100); // used to get started if no model exists on file 
  P.loadPts("data/pts - intersecting and good tube");  // loads saved model from file
  //Q.loadPts("data/pts2");  // loads saved model from file
  noSmooth();
  }

void draw() {
  background(255);
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas

    float fov = PI/3.0;
    float cameraZ = (height/2.0) / tan(fov/2.0);
    camera(0,0,cameraZ,0,0,0,0,1,0  );       // sets a standard perspective
    perspective(fov, 1.0, 0.1, 10000);
    
    translate(0,0,dz); // puts origin of model at screen center and moves forward/away by dz
    lights();  // turns on view-dependent lighting
    rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
    rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
    if(center) translate(-F.x,-F.y,-F.z);
    noStroke(); // if you use stroke, the weight (width) of it will be scaled with you scaleing factor
    showFrame(50); // X-red, Y-green, Z-blue arrows
    fill(cyan); pushMatrix(); translate(0,0,-1.5); box(50,50,1); popMatrix(); // draws floor as thin plate
    fill(magenta); show(F,4); // magenta focus point (stays at center of screen)
    fill(magenta,100); showShadow(F,5); // magenta translucent shadow of focus point (after moving it up with 'F'

   computeProjectedVectors(); // computes screen projections I, J, K of basis vectors (see bottom of pv3D): used for dragging in viewer's frame    
   pp=P.idOfVertexWithClosestScreenProjectionTo(Mouse()); // id of vertex of P with closest screen projection to mouse (us in keyPressed 'x'...
   
   
   
   //////////////////////////////////////////////////////////////////////////////////////////
   // My Medial Axis code starts
    
   //////////////////////////////////////////////////////////////////////////////////////////
   // Assign control pts
   
   stroke(black); strokeWeight(2); 
   
   
   pt[] G = {P.G[0], P.G[1], P.G[2], P.G[3], P.G[4]};
   pt[] R = {P.G[0], P.G[7], P.G[6], P.G[5], P.G[4]};
   
   for(int i=0; i<5; i++)
   {
     stroke(green); fill(green); show(G[i], 4);
     stroke(red); fill(red); show(R[i], 4);
   }
   
   stroke(green); fill(green); show(G[0],5); //start
   stroke(red); fill(red); show(R[4],5); //end
       
   //////////////////////////////////////////////////////////////////////////////////////////
   // Compute and Draw curves
   
   pts C1 = new pts(), C2 = new pts();
   C1.declare(); C2.declare();
   
   float a=0, b=0.25, c=0.5, d=0.75, e=1.0;

   
   for(float s=0; s<=1.0001; s+=0.01)
   {
     C1.addPt(N(a, G[0], b, G[1], c, G[2], d, G[3], e, G[4], s));
     C2.addPt(N(a, R[0], b, R[1], c, R[2], d, R[3], e, R[4], s));
   }
   
   
   if(show_curves)
   {
     stroke(green); strokeWeight(2); 
     for(int i=0; i<C1.nv-1; i++)
     {
       show(C1.G[i], C1.G[i+1]); 
     }
   
     stroke(red); strokeWeight(2); 
     for(int i=0; i<C2.nv-1; i++)
     {
       show(C2.G[i], C2.G[i+1]); 
     }
   }
   
   if(C1.nv!= C2.nv) print("EXCEPTION: parameterization doesn't match");
   //print("\n number of points on C1: " + C1.nv + "\n");
   //print("\n number of points on C2: " + C2.nv + "\n");
   
   ///////////////////////////////////////////////////////////////////////////////////////////
   // Draw medial axis, inital attempt
   
   if(show_crude_ma)
   {
     pts mA1 = new pts(); mA1.declare(); mA1.addPt(C1.G[0]);   
     int num_vert = C1.nv;
     for(int i=0; i<num_vert-1; i++) // run loop for number of edges in a curve
     {
       vec V1 = V(C1.G[i], C1.G[i+1]);
       vec V2 = V(C2.G[i], C2.G[i+1]);
       
       mA1.addPt(P(mA1.G[i],V(V1,V2)));
     }   
  
     stroke(blue); strokeWeight(5);
     for(int i=0; i<mA1.nv-1; i++)
     {
      show(mA1.G[i], mA1.G[i+1]); 
     }
   }

   
   ///////////////////////////////////////////////////////////////////////////////////////
   // code to test medial axis of 3d line segments
   
   //stroke(black); strokeWeight(2);
   //show(G[1],G[3]); show(R[1],R[3]);
   //pt p0 = G[1]; vec u = V(G[1],G[3]);
   //pt q0 = R[1]; vec v = V(R[1],R[3]);
   //pt mid = midPt(p0,u,q0,v); 
   //show(mid,4);
   //show(mid, V(u,v)); 
   
   
   ////////////////////////////////////////////////////////////////////////////////////////
   // compute medial axis
   
   pts ma = new pts(); ma.declare(); // do draw inflation later
   pts fp1 = new pts(); fp1.declare(); // do draw inflation later
   pts fp2 = new pts(); fp2.declare(); // do draw inflation later
   
   pts mA2 = new pts(); mA2.declare(); mA2.addPt(C1.G[0]);
   
   vec v1 = V(C1.G[0], C1.G[1]);
   vec v2 = V(C2.G[0], C2.G[1]);
   float d_move = 10;
   pt seed = P(C1.G[0], d_move, U(V(v1,v2))); 
   
   pt p=new pt(), pp = new pt(), cpp1 = new pt(), cpp2 = new pt();
   p.set(seed);
    
   vec ppv = new vec();
   int iter_count = 0;
   float iter_sum = 0.0;
   while(d(mA2.G[mA2.nv-1],C1.G[C1.nv-1])>d_move && mA2.nv<1500)
   {
     iter_count++;
     mApt(C1,C2,p,pp,ppv,cpp1,cpp2);
     int count = 0;
     while(d(pp,p) > 0.0001 && count < 10)
     {
      p.set(pp);
      mApt(C1,C2,p,pp,ppv,cpp1,cpp2);
       
      count++;
     }
     
     iter_sum+=(float)count;
     
     //print("\n count: "+ count + "\t dist:" +d(pp,p));
     mA2.addPt(pp);
     p.set(P(pp,d_move,ppv)); 
     //print("\n" + ppv.x + "\t" + ppv.y + "\t" +ppv.z);
     
     ma.addPt(pp); fp1.addPt(cpp1); fp2.addPt(cpp2);
     
     /////////////////////////////////////////////////////////////////////////
     //draw parabolic transverse arcs
     
     
     pt[] arcPts = new pt[]{cpp1,pp,pp,cpp2};
     pt arcPt1 = bezierPoint(arcPts, 0);
     pt arcPt2 = new pt();
     stroke(black); strokeWeight(2); 
     for(float s=0.2; s<=1.001; s+=0.1)
     {
       arcPt2.set(bezierPoint(arcPts, s));
       if(show_tcurves || show_net || show_net_inflation) show(arcPt1,arcPt2);
       arcPt1.set(arcPt2);              
     }
     
     
   }   
   mA2.addPt(C1.G[C1.nv-1]);//add end pt
   print("\n avg iter count: " + iter_sum/iter_count);
   
   if(show_morph) { animating = true; drawMorph(ma, fp1, fp2, t, blue);}
   if(show_net || show_net_inflation) drawMorphs(ma, fp1, fp2);
   
   
   if(show_ma)
   {
     stroke(red); strokeWeight(5);
     for(int i=0; i<mA2.nv-1; i++)
     {
      show(mA2.G[i], mA2.G[i+1]); 
     }    
     print("\n number of points on mAxis: " + mA2.nv + "\n");
   }
   
   /////////////////////////////////////////////////////////////////////////////
   // Draw tubes equi arc length sampling
   
   float min_dAlongArc = 10.0, tube_radius = 5.0; 
  
   if(show_tubes)
   {
     ShowEquiArcLengthSampledTube(C1, min_dAlongArc, tube_radius, green);
     ShowEquiArcLengthSampledTube(C2, min_dAlongArc, tube_radius, red);
     
     if(show_ma)ShowEquiArcLengthSampledTube(mA2, min_dAlongArc, tube_radius, blue);
   }
   
   
   
   
   /////////////////////////////////////////////////////////////////////////////
   // Draw variable radius tube
   
   if(show_inflation) drawVarRadTube(ma, fp1, fp2, TWO_PI, magenta);
   if(show_net_inflation)drawVarRadTube(ma, fp1, fp2, PI*1.1, white);
 
   // My Medial Axis code ends
   //////////////////////////////////////////////////////////////////////////////////////////
 
 
 
 
   if(viewpoint) { 
     Viewer = viewPoint(); 
     viewpoint=false;
     }
   noFill(); stroke(red); strokeWeight(1); show(Viewer,P(200,200,0)); show(Viewer,P(200,-200,0)); show(Viewer,P(-200,200,0)); show(Viewer,P(-200,-200,0));
   noStroke(); fill(red,100); show(Viewer,5); noFill();

  
  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas

      // for demos: shows the mouse and the key pressed (but it may be hidden by the 3D model)
     //  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX,mouseY,26,26); fill(red); text(key,mouseX-5,mouseY+4);}
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if (animating) {t+=0.01; if(t>1) t=0.0; } // periodic change of time 
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif");  // save next frame to make a movie
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  }
  
void keyPressed() {
  if(key=='`') picking=true; 
  if(key=='?') scribeText=!scribeText;
  if(key=='!') snapPicture();
  if(key=='~') filming=!filming;
  if(key==']') showControlPolygon=!showControlPolygon;
  if(key=='|') showNormals=!showNormals;
  if(key=='G') gouraud=!gouraud;
  if(key=='q') Q.copyFrom(P);
  if(key=='p') P.copyFrom(Q);
  if(key=='e') {PtQ.copyFrom(Q);Q.copyFrom(P);P.copyFrom(PtQ);}
  if(key=='=') {bu=fu; bv=fv;}
  // if(key=='.') F=P.Picked(); // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if(key=='c') center=!center; // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if(key=='t') tracking=!tracking; // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if(key=='x' || key=='z' || key=='d') P.setPickedTo(pp); // picks the vertex of P that has closest projeciton to mouse
  if(key=='d') P.deletePicked();
  if(key=='i') P.insertClosestProjection(Of); // Inserts new vertex in P that is the closeset projection of O
  if(key=='W') {P.savePts("data/pts");}  // save  Q.savePts("data/pts2");vertices to pts2
  if(key=='L') {P.loadPts("data/pts");}   // load Q.loadPts("data/pts2");s saved model
  if(key=='w') P.savePts("data/pts");   // save vertices to pts
  if(key=='l') P.loadPts("data/pts"); 
  if(key=='a') {animating=!animating; t=0;} // toggle animation
  if(key==',') viewpoint=!viewpoint;
  if(key=='t') flip=!flip;
  if(key=='#') exit();
  
  if(key=='0') show_crude_ma = !show_crude_ma;
  if(key=='1') show_curves = !show_curves;
  if(key=='2') show_tubes = !show_tubes;
  if(key=='3') show_ma = !show_ma;
  if(key=='4') show_tcurves = !show_tcurves;
  if(key=='5') show_morph = !show_morph;
  if(key=='6') show_net = !show_net;
  if(key=='7') show_inflation = !show_inflation;
  if(key=='8') show_net_inflation = !show_net_inflation;
    
  
  change=true;
  }

void mouseWheel(MouseEvent event) {dz += event.getAmount(); change=true;}

void mousePressed() {
   if (!keyPressed) picking=true;
  }
  
void mouseMoved() {
  if (keyPressed && key==' ') {rx-=PI*(mouseY-pmouseY)/height; ry+=PI*(mouseX-pmouseX)/width;};
  if (keyPressed && key=='s') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
  if (keyPressed && key=='v') { //**<01 
      u+=(float)(mouseX-pmouseX)/width;  u=max(min(u,1),0);
      v+=(float)(mouseY-pmouseY)/height; v=max(min(v,1),0); 
      } 
  }
void mouseDragged() {
  if (!keyPressed) {Of.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); }
  if (keyPressed && key==CODED && keyCode==SHIFT) {Of.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));};
  if (keyPressed && key=='x') P.movePicked(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='z') P.movePicked(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='X') P.moveAll(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='Z') P.moveAll(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='f') { // move focus point on plane
    if(center) F.sub(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  if (keyPressed && key=='F') { // move focus point vertically
    if(center) F.sub(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  }  

// **** Header, footer, help text on canvas
void displayHeader() { // Displays title and authors face on screen
    scribeHeader(title,0); scribeHeaderRight(name); 
    fill(white); image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
    }
void displayFooter() { // Displays help text at the bottom
    scribeFooter(ma_guide,2);
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }

String title ="6491 P3 2015: Medial Axis", name ="Ashish and Seth",
       menu="?:help, !:picture, ~:(start/stop)capture, space:rotate, s/wheel:closer, f/F:refocus, a:anim, #:quit",
       guide="x/z:select&edit balls, l/L: load, w/W:write to file", // user's guide
       ma_guide="num keys, 1:curve, 2:tube, 3:mAxis, 4:trnsCur, 5:morph, 6:net, 7:infltion, 8:net+half-Infl, 0:crudeMA";