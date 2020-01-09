// Template for 2D projects
// Author: Jarek ROSSIGNAC
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!
import java.lang.Math;

//**************************** global variables ****************************
pts P = new pts(); // class containing array of points, used to standardize GUI
float t=0, f=0;
boolean animate=true, fill=false, timing=false;
boolean showArrow=true; // toggles to display vector interpoations
int ms=0, me=0; // milli seconds start and end for timing
int npts=20000; // number of points 
ArrayList <pt> vertice_pos = new ArrayList<pt> ();
ArrayList <Integer> face = new ArrayList<Integer> (); //ID of face of corner C
ArrayList <Integer> vertices = new ArrayList<Integer> ();//ID of vertex of corner C
ArrayList<vec> added_arrows = new ArrayList<vec>();
Mesh face_mesh = new Mesh();
int swing = 0;
int next = 0;
boolean iswing = false;
boolean isnext = false;
boolean show_red = false;
boolean show_face = false;
boolean add_arrow = false;

//**************************** initialization ****************************
void setup()               // executed once at the begining 
  {
  //size(1200, 1200);            // window size
  size(800, 800);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  myFace = loadImage("data/me.jpeg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  P.declare(); // declares all points in P. MUST BE DONE BEFORE ADDING POINTS 
  // P.resetOnCircle(4); // sets P to have 4 points and places them in a circle on the canvas
  P.loadPts("data/pts");  // loads points form file saved with this program
  
  } // end of setup

//**************************** display current frame ****************************
void draw()      // executed at each frame
  {
  if(recordingPDF) startRecordingPDF(); // starts recording graphics to make a PDF
  
    background(white); // clear screen and paints white background
     

    if(showArrow) P.drawArrows(); // draws all control arrows

  if(recordingPDF) endRecordingPDF();  // end saving a .pdf file with the image of the canvas

  fill(black); displayHeader(); // displays header
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  
 
  ArrayList<Integer> inputlist = new ArrayList<Integer> ();
  for(int i=0;i<P.nv/2;i++)
   inputlist.add(i);
  
  /*for(int i=0;i<inputlist.size();i++)
  print(inputlist.get(i)+" ");
  print("\n");*/
  Node bsp_first_node = new Node();
  bsp_first_node = build_bsp(inputlist);
  //print(bsp_first_node.left.index+" "+bsp_first_node.index+" "+bsp_first_node.right.index+"\n");
  //print(bsp_first_node.left.index+" ");
 // print(bsp_first_node.right.right.right.right.right.right.index+" ");
  //build_bsp(inputlist);
  
  
  String bsp = show_bsp(bsp_first_node);
  text("BSP-tree: "+bsp,150,20);
  face_mesh.start();
  if(add_arrow){
 face_mesh.add_arrow();
  if(show_red)
  face_mesh.show_redline();
 // print("corner 7 next:"+face_mesh.N[7]+"\n");
  face_mesh.show_corner();
  face_mesh.show_flat_non_flat();
 face_mesh.show_corner_1(next);
// face_mesh.containment();
 }
 
   

  if(filming && (animating || change)) snapFrameToTIF(); // saves image on canvas as movie frame 
  if(snapTIF) snapPictureToTIF();   
  if(snapJPG) snapPictureToJPG();   
  change=false; // to avoid capturing movie frames when nothing happens
  }  // end of draw
  
 
String show_bsp(Node node){
  if(node == null){
   return " ";
  }
  else{
   String left = show_bsp(node.left);
   String right = show_bsp(node.right);
   if(right == " " && left == " ")
      return Integer.toString(node.index);
   else return "(" + left +") " +node.index+ " ("+right+")";


  }
}
