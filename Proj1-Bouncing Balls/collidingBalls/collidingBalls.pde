// balls colliding in 3D
float dz=0; // distance to camera. Manipulated with wheel or when 
float rx=-0.06*TWO_PI, ry=-0.04*TWO_PI;    // view angles manipulated when space pressed but not mouse
Boolean animating=true, tracking=false, center=true, showNormals=false;
float t=0, s=0;
float w=400; // half-size of the cube
pt F = P(0, 0, 0);  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
pt Of=P(100, 100, 0), Ob=P(110, 110, 0); // red point controlled by the user via mouseDrag : used for inserting vertices ...
int nbs = 2; // number of balls = nbs*nbs*nbs
//int nbs = 10; // number of balls = nbs*nbs*nbs
float br = 20; // ball radius
int Frate=20;
float u = 1./Frate; // time between consecutive frames
float mv=1; // magnifier of max initial speed of the balls
//float mv=1./u; // magnifier of max initial speed of the balls
boolean stop=false; // stops animation if computation took  more than u
boolean individual=false, showV=false;
float t0=0, t1=0, t2=0, t3=0, t4=0, dt01=0, dt12=0, dt23=0, dt34=0, t_compute; // ti = lap times per frame, and durations in % of u
int collisions=0;

float SimTime = 0;

float firstColTime = 0.0;
float eps = (float)(1e-6);
boolean stoppedForFirstCollision = false;

int MaxCollisionBufferSize = 100000;

CollisionBuffer buffer = new CollisionBuffer();

void setup() {
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  textureMode(NORMAL);
  size(600, 600, P3D); // p3D means that we will do 3D graphics
  P.declare(); 
  Q.declare(); 
  PtQ.declare(); // declare 3 sets of balls (we advect and animate P, othres used for copy
  // P.loadBALLS("data/BALLS");  // loads saved model from file
  // Q.loadBALLS("data/BALLS2");  // loads saved model from file 
  br=w/(nbs*pow(PI*120/4, 1./3));
  restart();
  F = P();
  sphereDetail(6);
  frameRate(Frate);
  noSmooth();
}

void restart() {
  P.initPointsOnGrid(nbs, w, br, cyan);
  SimTime = 0.0;
  buffer.initialize();
  firstColTime = buffer.queue.getFirst().time;
  System.out.println("First Collision Time: "+firstColTime+" | Between ("+buffer.queue.getFirst().index[0]+") and ("+buffer.queue.getFirst().index[1]+")");
  
  stoppedForFirstCollision = false;
}

void draw() {

  //if(animating && !stop) {
    
  //  if(SimTime >= firstColTime) {
  //    SimTime += mv/1000.0;
  //  }
  //  else {
  //    SimTime += mv;
  //  }
    
  //  if(SimTime > firstColTime && !stoppedForFirstCollision) {
  //    SimTime = firstColTime + eps;
  //    stoppedForFirstCollision = true;
  //  }
  //}
  
  if(animating && !stop) {
    SimTime += mv;
  }

  t0 = millis();
  background(255);
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas

  camera();       // sets a standard perspective
  translate(width/2, height/2, dz); // puts origin of model at screen center and moves forward/away by dz
  lights();  // turns on view-dependent lighting
  rotateX(rx); 
  rotateY(ry); // rotates the model around the new origin (center of screen)
  rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
  if (center) translate(-F.x, -F.y, -F.z);
  noStroke(); // if you use stroke, the weight (width) of it will be scaled with you scaleing factor
  showFrame(50); // X-red, Y-green, Z-blue arrows
  fill(yellow); 
  pushMatrix(); 
  translate(0, 0, -w/2-1.5); 
  box(w, w, 1); 
  popMatrix(); // draws floor as thin plate
  noFill(); 
  stroke(black); 
  showBlock(w, w, w, 0, 0, 0, 0);
  fill(magenta); 
  show(F, 4); // magenta focus point (stays at center of screen)
  fill(magenta, 100); 
  showShadow(F, 5); // magenta translucent shadow of focus point (after moving it up with 'F'

  fill(magenta); noStroke(); show(pick(mouseX,mouseY),10);
  computeProjectedVectors(); // computes screen projections I, J, K of basis vectors (see bottom of pv3D): used for dragging in viewer's frame    
  pp=P.idOfVertexWithClosestScreenProjectionTo(Mouse()); // id of vertex of P with closest screen projection to mouse (us in keyPressed 'x'...

  t1 = millis();
  t_compute = t2;
  // your physics module that compute future events goes here
  //while(t_compute - t2 < u - dt01 - dt23 - dt34 || buffer.queue.isEmpty()) {
    buffer.computeFutureCollision();
  //  if(buffer.queue.size() >= MaxCollisionBufferSize)
  //    break;
  //  t_compute = millis();
  //}
  collisions=0;

  t2 = millis();
  // your animation module that simulates ball motion between framesgoes here
  buffer.updateP(SimTime);
  
  if(animating && !stop) {
    for(int i=0; i < P.nv ; ++i) {
      P.G[i].set(P.G0[i]);
      P.G[i].add(SimTime, P.V[i]);
    }
  }
  
  if(animating && !stop) { P.resetColors(cyan); /*P.bounceBalls(w);*/} // advection
  //if(animating && !stop) {P.advectBalls(mv); P.resetColors(cyan); P.bounceBalls(w);} // advection

  t3 = millis();
  P.showBalls();
  //if(showV) P.showVelocities(30); 
  //pt Picked = pick( mouseX, mouseY);
  //if(picking) {P.pickClosestTo(Picked); picking=false;}
  //P.showPickedBall();

  //fill(blue); show(Picked,3); fill(red,100); showShadow(Picked,5,-w/2);  // show picked point and its shadow

  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas

  // for demos: shows the mouse and the key pressed (but it may be hidden by the 3D model)
  //  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX,mouseY,26,26); fill(red); text(key,mouseX-5,mouseY+4);}

  if (scribeText) {
    fill(black); 
    displayHeader();
  } // dispalys header on canvas, including my face
  if (scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if (animating) { 
    t+=PI/180/2; 
    if (t>=TWO_PI) t=0; 
    s=(cos(t)+1.)/2;
  } // periodic change of time 
  t4 = millis();
  if (!stop) {
    dt01=(t1-t0)/10/u; 
    dt12=(t2-t1)/10/u; 
    dt23=(t3-t2)/10/u; 
    dt34=(t4-t3)/10/u;
  }
  scribe("nbs = "+nbs+", "+(nbs*nbs*nbs)+" balls, "+nf(collisions, 3, 0)+" collisions per frame", 10, 40); 
  scribe("First Collision Time: "+firstColTime+" | SimTime: "+SimTime+" | dt01 = "+nf(dt01, 2, 1)+"%, dt12 = "+nf(dt12, 2, 1)+"%, dt23 = "+nf(dt23, 2, 1)+"%, dt34 = "+nf(dt34, 2, 1)+"%", 10, 60); 
  if (filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++, 4)+".png");  // save next frame to make a movie

  //if(SimTime >= firstColTime) stop = true;

  if ((t4-t0)/10/u>99 || stop) {
    scribe("First Collision Time: "+firstColTime+" | SimTime: "+SimTime+" | dt01 = "+nf(dt01, 2, 1)+"%, dt12 = "+nf(dt12, 2, 1)+"%, dt23 = "+nf(dt23, 2, 1)+"%, dt34 = "+nf(dt34, 2, 1)+"%. STOPPED !", 10, 80); 
    stop=true;
  }
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
}

void keyPressed() {
  if (key=='`') picking=true; 
  if (key=='?') scribeText=!scribeText;
  if (key=='!') snapPicture();
  if (key=='~') filming=!filming;
  if (key=='/') stop=!stop;
  if (key=='v') showV=!showV;
  if (key=='I') individual=!individual;
  if (key=='i') {
    restart(); 
    stop=false;
  }
  if (key=='a') animating=!animating; // toggle animation
  if (key=='h') {
    F = P();
  }  // "home": reserts Focus point F
  if (key=='+') {
    nbs++; 
    br=w/(nbs*pow(PI*120/4, 1./3)); 
    restart(); 
    stop=true;
  }
  if (key=='-') {
    nbs=max(1, nbs-1); 
    br=w/(nbs*pow(PI*120/4, 1./3)); 
    restart(); 
    stop=true;
  }
  if (key=='r') {
    br=w/(nbs*pow(PI*120/4, 1./3)); 
    restart(); 
    stop=true;
  }
  if (key=='4') sphereDetail(4);
  if (key=='5') sphereDetail(5);
  if (key=='6') sphereDetail(6);
  if (key=='7') sphereDetail(7);
  if (key=='8') sphereDetail(8);
  if (key=='9') sphereDetail(9);
  if (key=='0') sphereDetail(10);
  if (key=='1') sphereDetail(11);
  if (key=='2') sphereDetail(12);
  if (key=='|') ;
  if (key=='G') ;
  if (key=='q') Q.copyFrom(P); // to save current configuration
  if (key=='p') P.copyFrom(Q); // to restore it
  if (key=='e') {
    PtQ.copyFrom(Q);
    Q.copyFrom(P);
    P.copyFrom(PtQ);
  }
  // if(key=='=') {bu=fu; bv=fv;}
  // if(key=='.') F=P.Picked(); // snaps focus F to the selected point of P (easier to rotate and zoom while keeping it in center)
  if (key=='c') center=!center; // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if (key=='t') tracking=!tracking; // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if (key=='x' || key=='z' || key=='d') P.setPickedTo(pp); // picks the vertex of P that has closest projeciton to mouse
  if (key=='d') P.deletePicked();
  if (key=='W') {
    P.saveBALLS("data/BALLS"); 
    Q.saveBALLS("data/BALLS2");
  }  // save vertices to BALLS2
  if (key=='L') {
    P.loadBALLS("data/BALLS"); 
    Q.loadBALLS("data/BALLS2");
  }   // loads saved model
  if (key=='w') P.saveBALLS("data/BALLS");   // save vertices to BALLS
  if (key=='l') P.loadBALLS("data/BALLS");
  if (key=='#') exit();
  change=true;
}

void mouseWheel(MouseEvent event) {
  dz += event.getAmount(); 
  change=true;
}

void mousePressed() {
  if (!keyPressed) picking=true;
}

void mouseMoved() {
  if (keyPressed && key==' ') {
    rx-=PI*(mouseY-pmouseY)/height; 
    ry+=PI*(mouseX-pmouseX)/width;
  };
  if (keyPressed && key=='s') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
  // if (keyPressed && key=='v') { //**<01 
  //     u+=(float)(mouseX-pmouseX)/width;  u=max(min(u,1),0);
  //     v+=(float)(mouseY-pmouseY)/height; v=max(min(v,1),0); 
  //     }
}
void mouseDragged() {
  if (!keyPressed) {
    Of.add(ToIJ(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0)));
  }
  if (keyPressed && key==CODED && keyCode==SHIFT) {
    Of.add(ToK(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0)));
  };
  if (keyPressed && key=='x') P.movePicked(ToIJ(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0))); 
  if (keyPressed && key=='z') P.movePicked(ToK(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0))); 
  if (keyPressed && key=='X') P.moveAll(ToIJ(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0))); 
  if (keyPressed && key=='Z') P.moveAll(ToK(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0))); 
  if (keyPressed && key=='f') { // move focus point on plane
    if (center) F.sub(ToIJ(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0))); 
    else F.add(ToIJ(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0)));
  }
  if (keyPressed && key=='F') { // move focus point vertically
    if (center) F.sub(ToK(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0))); 
    else F.add(ToK(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0)));
  }
  if (keyPressed && key=='m') {
    mv+=(float)(mouseX-pmouseX)/width;
  } // adjust animation speed
  if (keyPressed && key=='b') {
    br+=10.*(float)(mouseX-pmouseX)/width; 
    restart(); 
    stop=true;
  } // adjust animation speed
}  

// **** Header, footer, help text on canvas
void displayHeader() { // Displays title and authors face on screen
  scribeHeader(title, 0); 
  scribeHeaderRight(name); 
  fill(white); 
  image(myFace, width-myFace.width/2, 25, myFace.width/2, myFace.height/2);
}
void displayFooter() { // Displays help text at the bottom
  scribeFooter(guide, 1); 
  scribeFooter(menu, 0);
}

String title ="6491-2015-P1: Animation of colliding balls", name ="Michael X. Grey", 
  menu="?:help, !:picture, ~:videotape, space:rotate, s/wheel:closer, f/F:refocus, a:anim, #:quit", 
  guide="i:reinitialize, a:animate, v:show Vs, +/-: # balls. DRAG b:radius, m:faster"; 
// user's guide