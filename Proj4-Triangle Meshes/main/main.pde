// Triangle mesh viewer + corner table + subdivision + smoothing + compression + simplificatioin + geodesics + isolation
// Written by Jarek Rossignac June 2006. Modified Septmber 2007
import processing.opengl.*;                // load OpenGL
String [] fn=  {"test.txt", "bunny.vts","horse.vts","torus.vts","tet.vts","fandisk.vts","squirrel.vts","venus.vts"};
int fni=1; int fniMax=fn.length;  
Mesh M = new Mesh();                       // creates a triangle mesh
boolean showNormals=false, showVertices=false, showEdges=false, showTriangles=true,  showSelectedTriangle=true, showLabels=false, showPath=false;  // flags for rendering
boolean showSkeleton=true, showSelectedLake=true, showOtherLakes=true, showDistance=false, showEB=false, showEBrec=false, showClusters=true;
int radio=1;

// ** SETUP **
void setup() { size(800, 800, OPENGL); setColors(); sphereDetail(6); //smooth();
  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12);  // font for writing labels on screen
  M.declare(); 
  //M.makeGrid(3); 
  M.loadMesh();
  M.init();
  initView(M);
  M.fixS();
  } 
 
// ** DRAW **
void draw() {
  background(white); 
  perspective(PI/2.0,width/height,1.0,6.0*Rbox); 
  if (showHelpText) {camera(); translate(-290,-290,0); scale(1.7,1.7,1.0); showHelp(); showColors();  return; };
  lights(); directionalLight(0,0,128,0,1,0); directionalLight(0,0,128,0,0,1);
  translate(float(height)/2, float(height)/2, 0.0);     // center view wrt window  
  if ((!keyPressed)&&(mousePressed)) {C.pan(); C.pullE(); };
  if ((keyPressed)&&(mousePressed)) {updateView();}; 
  //C1.track(C); C2.track(C1);   C2.apply();
  C.apply();
  M.show();
  }

//***      KEY ACTIONS (details in keys tab)
void keyPressed() { keys(); };
void mousePressed() {C.anchor(); C.pose();  };   //   where the cursor was when the mouse was pressed
void mouseReleased() {C.anchor(); C.pose(); };  // reset the view if any key was pressed when mouse was released 