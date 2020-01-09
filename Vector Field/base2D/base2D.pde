// Template for 2D projects
// Author: Jarek ROSSIGNAC
// CS6497: Computational Aesthetics, Fall 2019, Project 3
// Student: Jack Ross
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.util.Random;

//**************************** global variables ****************************
pts P = new pts(); // class containing array of points, used to manipulate arrows
float t=0.5;
boolean animate=false, fill=false, timing=false;
boolean showArrow=true, showKeyArrow=true; // toggles to display vector interpoations
boolean showcentroidvec = false;
boolean tracetest = false;
boolean colortri = true;
boolean singletrace = false;
boolean showconstrain = true;
boolean linear_spiral = false;
boolean showdiscpoints = false;
boolean createnewmesh = false;
boolean showedge = false;
boolean classifyvector =true;
int ms=0, me=0; // milli seconds start and end for timing
int npts=20000; // number of points
boolean spiralAverage=true, quintic=true, cubic=true;
boolean tracesample = false;
ARROWRING Aring = new ARROWRING();
ARROWRING RefinedAring = new ARROWRING();
ARROWRING TempAring = new ARROWRING();
int refineCounter = 6;
int f=0, df=int(pow(2,refineCounter));
float ft=0;
PFont bigFont; // for showing large labels at corner
boolean showFine=false, showTraceFromMouse=false, showMesh=true, showFirstField=false, showTriangles=true;
int exitThrough=0;
MESH M = new MESH();

int cc=0; // current corner (saved, since we rebuild M at each frame)

pt[] new_MP = new pt [1000];

ArrayList<ArrayList<pt>> select_samples = new ArrayList<ArrayList<pt>>();
int new_nv = 0;




//**************************** initialization ****************************
void setup()               // executed once at the begining 
  {
  size(800, 800, P2D);            // window size
  //size(1200, 1200);            // window size
  //frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  P.declare(); // declares all points in P. MUST BE DONE BEFORE ADDING POINTS 
  // P.resetOnCircle(4); // sets P to have 4 points and places them in a circle on the canvas
  P.loadPts("data/pts");  // loads points form file saved with this program
  Aring.declare();
  RefinedAring.declare();
  TempAring.declare();
  //myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  myFace = loadImage("data/me.jpeg"); 
  textureMode(NORMAL);
  bigFont = createFont("AdobeFanHeitiStd-Bold-32", 20); 
  textFont(bigFont); 
  textAlign(CENTER, CENTER);
  } // end of setup

//**************************** display current frame ****************************
void draw()      // executed at each frame
  {
  if(recordingPDF) startRecordingPDF(); // starts recording graphics to make a PDF
  background(white); // clear screen and paints white background
  ArrayList<pt> new_P = new ArrayList<pt>();

  // ==================== MAKE ARROWS ====================   
  Aring.empty();
  for(int i=0; i<P.nv; i+=2) {Aring.addArrow(P.G[i],V(P.G[i],P.G[i+1]));}
   
  // ==================== ANIMATION ====================   
  int tm=120;
  if(animate) f=(f+1)%(tm);
  else f=(floor(ft)+tm)%(tm);
  float tt = float(f)/tm;
  t=(1.-cos(tt*TWO_PI))/2;
 
  // ==================== TRIANGLE MESH ====================   
  if(showMesh)
    {
    cc=M.c;
    M.reset(); 
    M.loadFromPTS(P); // loads vertices and field vectors from the sequence P of po=oints
   // pen(blue,2); M.drawArrows();
    M.triangulate();
    M.computeO();
    M.classifyVertices();
    noFill(); pen(black,2); M.showTriangles();
    stroke(red); M.showBorderEdges();
    M.c=cc;
    M.showCorners(3);
    noFill(); pen(black,2); M.showCurrentCorner(7);
    pt Ps=M.firstBorderEdgeMidPoint();  pen(green,2); fill(green); show(Ps,6);
    int fbc = M.firstBorderCorner();
    if(classifyvector){
    M.classify_vectors();
    M.tuck_untuck_span();}
    //pen(brown,3); 
    //M.tracePathFromMidEdgeFacingCorner(fbc);
    if(showcentroidvec)
    M.draw_field_on_centroids();
    M.set_visited();
    
   /* if(colortri){
    for(int i=0;i<M.nc-2;i+=3){
       if(M.visited[i]){
       fill(yellow);
       beginShape();
          vertex(M.G[M.V[i]].x,M.G[M.V[i]].y);
          vertex(M.G[M.V[i+1]].x,M.G[M.V[i+1]].y);
          vertex(M.G[M.V[i+2]].x,M.G[M.V[i+2]].y);
       endShape();
       
       
       }}
   
    }*/
    
    if(tracetest){
    pt A = M.G[M.V[0]];
    pt B = M.G[M.V[1]];
    pt C = M.G[M.V[2]];
    vec vA = M.F[M.V[0]];
    vec vB = M.F[M.V[1]];
    vec vC = M.F[M.V[2]];
    pt centroid = P(A,B,C);
    M.single_naive_trace(centroid, A, vA, B, vB, C, vC);
  }
    else{
    if(singletrace){
    pt pm = Mouse();
     if(M.find_in_tri(pm)){
     int corner = M.point_in_tri(pm);
     M.visited[corner]=true;
     M.visited[corner+1]=true;
     M.visited[corner+2]=true;
     
     if(colortri){
         fill(yellow);
            beginShape();
          vertex(M.G[M.V[corner]].x,M.G[M.V[corner]].y);
          vertex(M.G[M.V[corner+1]].x,M.G[M.V[corner+1]].y);
          vertex(M.G[M.V[corner+2]].x,M.G[M.V[corner+2]].y);
   endShape();}
     
      M.single_naive_trace(pm,M.G[M.V[corner]], M.F[M.V[corner]], M.G[M.V[corner+1]], M.F[M.V[corner+1]], M.G[M.V[corner+2]], M.F[M.V[corner+2]]);
     
     }

    }
    else if(tracesample){
    /*pt pm = Mouse();
     if(M.find_in_tri(pm)){
     int corner = M.point_in_tri(pm);
     M.visited[corner]=true;
     M.visited[corner+1]=true;
     M.visited[corner+2]=true;
     
      M.naive_trace(pm,M.G[M.V[corner]], M.F[M.V[corner]], M.G[M.V[corner+1]], M.F[M.V[corner+1]], M.G[M.V[corner+2]], M.F[M.V[corner+2]]);
     
     }*/
     new_nv = 0;
     for(int i=0;i<M.nc-2;i+=3){
       int before =new_nv;
       if(!M.visited[i]){
        M.visited[i] = true;
         M.visited[i+1] = true;
         M.visited[i+2] = true;
         
         if(colortri){
           stroke(black);
         fill(yellow);
            beginShape();
            vertex(M.G[M.V[i]].x,M.G[M.V[i]].y);
          vertex(M.G[M.V[i+1]].x,M.G[M.V[i+1]].y);
          vertex(M.G[M.V[i+2]].x,M.G[M.V[i+2]].y);
         endShape();}
         
         pt A = M.G[M.V[i]];
         pt B = M.G[M.V[i+1]];
         pt C = M.G[M.V[i+2]];
         vec vA = M.F[M.V[i]];
         vec vB = M.F[M.V[i+1]];
         vec vC = M.F[M.V[i+2]];
         pt centroid = P(A,B,C);
         //new_P.add(centroid);
         stroke(brown);
         /*fill(red);show(centroid,4);
         new_MP[new_nv]=centroid;
         new_nv++;*/
         M.opp_naive_trace(centroid, A, vA, B, vB, C, vC);
         int after_opp = new_nv;
         int new_add_opp = after_opp - before;
         M.naive_trace(centroid, A, vA, B, vB, C, vC);
         
         int new_added = new_nv - before;
         
         //print(i+": "+new_nv+"\n");
         if(showedge&&createnewmesh){
         if(new_add_opp<=1){
         for(int j = before;j<new_nv-1;j++){
            pen(magenta,4);
            line(new_MP[j].x,new_MP[j].y,new_MP[j+1].x,new_MP[j+1].y);
         }
       }else{
         for(int j = before;j<after_opp-1;j++){
           
            pen(magenta,4);
            line(new_MP[j].x,new_MP[j].y,new_MP[j+1].x,new_MP[j+1].y);
         }
         pen(magenta,4);
         line(new_MP[before].x,new_MP[before].y,new_MP[after_opp].x,new_MP[after_opp].y);
         for(int j = after_opp;j<new_nv-1;j++){
           //print("here ");
            pen(magenta,4);
            line(new_MP[j].x,new_MP[j].y,new_MP[j+1].x,new_MP[j+1].y);
         }
       
       }
       }
       
       ArrayList<pt> samples = new ArrayList<pt>();
       for(int j = before;j<new_nv;j++){
       samples.add(new_MP[j]);
       }
       
       select_samples.add(samples);
       
       
   
       }
     }
     
    /*for(int i=0;i<select_samples.size();i++){
     print(i+": ");
     for(int j=0;j<select_samples.get(i).size();j++){
     print("["+select_samples.get(i).get(j).x+","+select_samples.get(i).get(j).y+"],");
     
     }
     print("\n");
     }*/
    
    
    if(createnewmesh){
    MESH new_M = new MESH();
    new_M.loadVertices(new_MP,new_nv);
    new_M.modify_triangulate();
    noFill(); pen(lblue,2); new_M.showTriangles();
    
    }
    
    }
    
    }
    
    
    
    
    }


  // ==================== TRACING FIELD OF FIRST TRIANGLE ====================  
  if(showFirstField)
    {
    ARROW A0 = Aring.A[0], A1 = Aring.A[1], A2 = Aring.A[2]; //First 3 arrows used to test tracing
    pt Pa = A0.P; vec Va = A0.V;
    pt Pb = A1.P; vec Vb = A1.V;
    pt Pc = A2.P; vec Vc = A2.V;
    pen(grey,4); fill(yellow,100); show(Pa,Pb,Pc);
    noFill(); 
    
    pt Ps=P(Pa,Pb); show(Ps,6); // mid-edge point where trace starts
    if(showFine) // FOR ACCURACY COMPARISONS
      {
      pen(cyan,2); drawTraceFrom(Ps,Pa,Va,Pb,Vb,Pc,Vc,500,0.005);
      pen(green,2); drawTraceFrom(Ps,Pa,Va,Pb,Vb,Pc,Vc,50,0.05);
      }
    
    pen(green,6); fill(green); show(Ps,4); // start of trace
    noFill();
    pen(orange,1); drawCorrectedTraceFrom(Ps,Pa,Va,Pb,Vb,Pc,Vc,100,0.1);
    pt Q = P(); // exit point when exitThrough != 0
     pen(brown,3); noFill(); exitThrough = drawCorrectedTraceInTriangleFrom(Ps,Pa,Va,Pb,Vb,Pc,Vc,100,0.1,Q);
     pen(red,6); 
     if(exitThrough!=0) {fill(red); show(Q,4); noFill();}
     if(exitThrough==1) edge(Pb,Pc); 
     if(exitThrough==2) edge(Pc,Pa); 
     if(exitThrough==4) edge(Pa,Pb);
     if(exitThrough==3) show(Pc,20);  
     if(exitThrough==6) show(Pa,20); 
     if(exitThrough==5) show(Pb,20);
    
    if(showTraceFromMouse)
       {
       pt Pm = Mouse();
       pen(black,1); drawCorrectedTraceFrom(Pm,Pa,Va,Pb,Vb,Pc,Vc,50,0.2);
       fill(brown); pen(brown,2); 
       if(showArrow) 
         {
         vec Vm = VecAt(Pm,Pa,Va,Pb,Vb,Pc,Vc); // velocity at current mouse position
         arrow(Pm,Vm);
         }
       pen(brown,1); show(Pm,6); 
       if(showLabels) showId(Pm,"M"); 
       noFill();
       }
       
    if(showArrow) 
      {
      fill(red); stroke(red); arrow(Pa,Va);
      fill(dgreen); stroke(dgreen); arrow(Pb,Vb) ;
      fill(blue); pen(blue,1); arrow(Pc,Vc);
      }
   
    noStroke();
    fill(red); show(Pa,6); 
    fill(dgreen); show(Pb,6); 
    fill(blue); show(Pc,6); 

    if(showLabels) 
      {
      textAlign(CENTER, CENTER); 
      pen(red,1); showId(Pa,"A"); 
      pen(dgreen,1); showId(Pb,"B"); 
      pen(blue,1); showId(Pc,"C"); 
      }
  
    textAlign(LEFT, TOP); fill(black);
    scribeHeader("exitThrough code = "+exitThrough,1); 
    textAlign(CENTER, CENTER);
    
    }
    
   // ==================== DRAW ARROWS BETWEEN CONSECUTIVE POINTS OF P ====================   
  fill(black); stroke(black);
  //if(showKeyArrow) P.drawArrows(); // draws all control arrows
 if(classifyvector){
    for(int i=0;i<M.nv;i++){
    if(M.constrained[i]){
      stroke(red); 
      fill(red);
      arrow(M.G[i],M.F[i]);
    }
    else{
      stroke(dgreen); 
      fill(dgreen);
      arrow(M.G[i],M.F[i]);
    }
    
    }
  }
  else{
  P.drawArrows();
  }

  // ==================== SHOW POINTER AT MOUSE ====================   
  pt End = P(Mouse(),1,V(-2,3)), Start = P(End,20,V(-2,3)); // show semi-opaque grey arrow pointing to mouse location (useful for demos and videos)
  strokeWeight(5);  fill(grey,70); stroke(grey,70); arrow(Start,End); noFill(); 
  

  if(recordingPDF) endRecordingPDF();  // end saving a .pdf file with the image of the canvas

  fill(black); displayHeader(); // displays header
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 

  if(filming && (animate || change)) snapFrameToTIF(); // saves image on canvas as movie frame 
  if(snapTIF) snapPictureToTIF();   
  if(snapJPG) snapPictureToJPG();   
  if(scribeText) {background(255,255,200); displayMenu();}
  change=false; // to avoid capturing movie frames when nothing happens
  
  
  select_samples.clear();
  }  // end of draw
  
