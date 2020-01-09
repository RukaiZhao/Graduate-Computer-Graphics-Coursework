//*****************************************************************************
// TITLE:         Point sequence for editing polylines and polyloops  
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  September 2012
// EDITS:         Last revised August 10, 2017
//*****************************************************************************
class Mesh{

int maxnv = 100*2*2*2*2*2*2*2*2;
pt[] G = new pt [maxnv]; //geometry(vertices)
int[] V =new int [maxnv]; //corner/vertex incidence
int[] F = new int[maxnv];//face
int[] N = new int[maxnv];//next
int[] S = new int[maxnv];//swing
boolean[] I = new boolean[maxnv];//check is good face
int nf = 0;   //number of f
int nc = 0; //number of corners
int nv = 0;  // number of vertices

ArrayList <Integer> start = new ArrayList<Integer> ();

Mesh(){}

void start(){
pt intersect1 = intersection(P.G[2],P.G[3],P.G[0],P.G[1]);
pt intersect2 = intersection(P.G[4],P.G[5],P.G[2],P.G[3]);
pt intersect3 = intersection(P.G[6],P.G[7],P.G[4],P.G[5]);
pt intersect4 = intersection(P.G[7],P.G[6],P.G[1],P.G[0]);
G[0]=P(intersect1);
G[1]=P(intersect2);
G[2]=P(intersect3);
G[3]=P(intersect4);

nv = 4;
nc = 4;
nf = 1;

V[0] = 0;//c0's vertex is V0
V[1] = 1;
V[2] = 2;
V[3] = 3;

F[0] = 0;//c0's FACE is f0
F[1] = 0;
F[2] = 0;
F[3] = 0;

S[0] = -1;//c0's FACE is f0
S[1] = -1;
S[2] = -1;
S[3] = -1;

N[0] = 1;//c0's next corner is c1
N[1] = 2;
N[2] = 3;
N[3] = 0;

I[0] = true;//c0's next corner is c1
I[1] = true;
I[2] = true;
I[3] = true;
fill(red);show(G[0],6);show(G[1],6);show(G[2],6);show(G[3],6);

}
void add_arrow(){
//for (int a=4; a<P.nv/2; a++) //traverse arrow
//{ //fill(blue); arrow(P.G[2*a],P.G[2*a+1]);
  //int a = 4;
int P_size = (int)P.nv/2;
for (int a=4; a<P_size; a++) {
  float distance = 10000;
  pt best_x = P();
  int best_a = 0;
  for(int i=0;i<nc;i++){//traverse corners
      if(split(P.G[2*a],P.G[2*a+1],G[V[i]],G[V[N[i]]],i)){
          pt intersect = intersection(P.G[2*a],P.G[2*a+1],G[V[i]],G[V[N[i]]]);
          if(d(intersect,P.G[2*a])<distance){
            distance = d(intersect,P.G[2*a]);
            best_x = P(intersect);
            best_a = i;
          }
          
      }
   }
   
   
  float distance1 = 10000;
  pt best_x1 = P();
  int best_b = 0;
  for(int i=0;i<nc;i++){//traverse corners
      if(split(P.G[2*a+1],P.G[2*a],G[V[i]],G[V[N[i]]],i)){
          pt intersect = intersection(P.G[2*a+1],P.G[2*a],G[V[i]],G[V[N[i]]]);
          if(d(intersect,P.G[2*a+1])<distance1){
            distance1 = d(intersect,P.G[2*a+1]);
            best_x1 = P(intersect);
            best_b = i;
          }
          
      }
   }
   
  //nf = nf+1; 
 // nv = nv+2;
 G[nv] = best_x;
 G[nv+1] = best_x1;
 //nv+=2;
 /*print("arrow: "+ a+" ");
 print("a:"+best_a+" next_a:"+N[best_a]+" swing next a:"+ S[N[best_a]]);
 print(" b:"+best_b+" next_b:"+N[best_b]+" swing next b:"+ S[N[best_b]]);
 print("\n");*/
 //fill(red);show(best_x,6);
 //fill(red);show(best_x1,6);
 int a_choose =0;
 
 
 if(S[N[best_a]]==-1){
   a_choose = 2;
   V[nc] = nv;//c0's vertex is V0
   V[nc+1] = nv;
   
  // F[nc] = 0;//c0's FACE is f0
  // F[nc+1] = 0;
   
   S[nc] = -1;//c0's FACE is f0
   S[nc+1] = nc;
   
  // N[nc] = 1;//c0's next corner is c1
   N[nc+1] = N[best_a];
     
  }
  else if( S[N[best_a]]!=-1){
  a_choose = 3;
  
  V[nc] = nv;//c0's vertex is V0
  V[nc+1] = nv;
  V[nc+2] = nv;
  
  I[nc+2] = false;
  // F[nc] = 0;//c0's FACE is f0
  // F[nc+1] = 0;
   
  S[nc] = nc+2;//c0's FACE is f0
  S[nc+1] = nc;
  S[nc+2] = nc+1;
   
  // N[nc] = 1;//c0's next corner is c1
  N[nc+1] = N[best_a];
  N[nc+2] = N[S[N[best_a]]];
  N[S[N[best_a]]] = nc+2;
  }
  
  int b_choose = 0;
  if(S[N[best_b]]==-1){
    b_choose = 2;
   V[nc+a_choose] = nv+1;//c0's vertex is V0
   V[nc+a_choose+1] = nv+1;
   
  // F[nc] = 0;//c0's FACE is f0
  // F[nc+1] = 0;
   
   S[nc+a_choose] = nc+a_choose+1;//c0's FACE is f0
   S[nc+a_choose+1] = -1;
   
  // N[nc] = 1;//c0's next corner is c1
   N[nc] =nc+a_choose ;
   N[nc+a_choose] = N[best_b];
   N[nc+a_choose+1] = nc+1;
     
 }
  else if( S[N[best_b]]!=-1){
  b_choose =3;
  
  V[nc+a_choose] = nv+1;//c0's vertex is V0
  V[nc+a_choose+1] = nv+1;
  V[nc+a_choose+2] = nv+1;
  
  I[nc+a_choose+2]=false;
   
  // F[nc] = 0;//c0's FACE is f0
  // F[nc+1] = 0;
   
   S[nc+a_choose] = nc+a_choose+1;//c0's FACE is f0
   S[nc+a_choose+1] = nc+a_choose+2;
   S[nc+a_choose+2] = nc+a_choose;
   
  // N[nc] = 1;//c0's next corner is c1
   N[nc] =nc+a_choose ;
   N[nc+a_choose] = N[best_b];
   N[nc+a_choose+1] = nc+1;
   N[nc+a_choose+2] = N[S[N[best_b]]];
   N[S[N[best_b]]] = nc+a_choose+2;   
   
  // N[nc+2] = N[S[N[best_a]]];
 // N[S[N[best_a]]] = nc+2;
  }
   
  N[best_a]=nc;
  N[best_b]=nc+a_choose+1;
  
  //Updating good or bad corner
  int count = nc;
  int start_good = nc;
  start.add(start_good);
  while(N[count]!=nc){
  I[count] = true;
 // print("count:"+count+"\n");
  count = N[count];
  }
  I[count] = true;
 // print("count:"+count+"\n");
  
 int count1 = nc+1;
  while(N[count1]!=nc+1){
  I[count1] = false;
  count1 = N[count1];
  }
  I[count1] = false;
  
  if(a_choose ==3){
  if(I[N[nc+2]]){
  I[nc+2] = true;
  }
  else I[nc+2] = false;
  }
  
  if(b_choose ==3){
  if(I[N[nc+a_choose+2]]){
  I[nc+a_choose+2] = true;
  }
  else I[nc+a_choose+2] = false;
  }
  
  if(show_face){
 fill(yellow);
  beginShape();
  int count3 = nc;
  while(N[count3]!=nc){
  vertex(G[V[count3]].x,G[V[count3]].y);
  count3=N[count3];
  }
  vertex(G[V[count3]].x,G[V[count3]].y);
  endShape();
  
  fill(white);
  beginShape();
  int count4 = nc+1;
  while(N[count4]!=nc+1){
  vertex(G[V[count4]].x,G[V[count4]].y);
  count4=N[count4];
  }
  vertex(G[V[count4]].x,G[V[count4]].y);
  endShape();
  
  }
 
  
  nc = nc+b_choose+a_choose;
  nf = nf+1;
  nv=nv+2;
  
 /*print("after arrow: "+ a+" ");
 print("a:"+best_a+" next_a:"+N[best_a]);
 print(" b:"+best_b+" next_b:"+N[best_b]);
 print("\n");*/
  
  
   
   
       
}

}
void show_redline(){
for(int index =0;index<start.size();index++){
if(I[index]){
draw_redline(index);
}
}



}
void draw_redline(int start_good){
 int c = start_good;
 
 if(S[c] !=-1&& S[S[c]]!=-1){
 if(I[S[S[c]]] && I[S[c]]==false)
  c = S[S[c]];
 if(!(I[S[c]]==true && I[S[S[c]]]==true)){
 strokeWeight(4);
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);}}
 else{
  strokeWeight(4);
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);
 }
 int count1 = 0;
 c = N[c];
 while(G[V[c]]!=G[V[start_good]]){
   if(count1>nc){
 break;
 }
 if(S[c] !=-1 && S[S[c]]!=-1){
 if(I[S[S[c]]]  && I[S[c]]==false)
  c = S[S[c]];
 if(!(I[S[c]]==true && I[S[S[c]]]==true)){
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);}}
 else{
  strokeWeight(4);
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);
 }
 
 c = N[c];
 count1++;
 }
 
// print(" next good: " +N[c]);
 
 int count = 0;
int next_start_good = N[c];
 c = N[c];
 if(S[c] !=-1&& S[S[c]]!=-1){
 if(I[S[S[c]]]  && I[S[c]]==false)
  c = S[S[c]];
  if(!(I[S[c]]==true && I[S[S[c]]]==true)){
 strokeWeight(4);
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);}}
 else{
  strokeWeight(4);
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);
 }
 
 c = N[c];
 
 while(G[V[c]]!=G[V[next_start_good]]){
   if(count>nc){
 break;
 }
 if(S[c] !=-1&& S[S[c]]!=-1){
 if(I[S[S[c]]]  && I[S[c]]==false)
  c = S[S[c]];
  if(!(I[S[c]]==true && I[S[S[c]]]==true)){
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);}}
 else{
  strokeWeight(4);
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);
 }
 
 c = N[c];
 count++;

 }
 
strokeWeight(1);
 stroke(black);



}

void show_corner(){
//print("here\n");
for(int i=0;i<nc;i++){
pt next = G[V[N[i]]];
int prev_no = N[i];
while(N[prev_no] != i){
prev_no = N[prev_no];
//print("i:"+i+" prev_no: "+prev_no +"\n");
}
//print("show_corner :"+i+" prev_no: "+prev_no+" next_no:"+N[i]+"\n");
pt prev = G[V[prev_no]];
vec t = U(G[V[i]],next);
vec u = U(G[V[i]],prev);
vec adding =t.add(u);
pt cor = P();
//if(det(t,u)!= 0)
cor = P(G[V[i]],20,adding);
//else 
//cor = P(G[V[i]],20,R(u));
/*if(I[i])
print(i+": True\n");
else
print(i+": False\n");*/
if(I[i]){
fill(115,194,251); show(cor,3);}
else{
fill(green); show(cor,3);}
/*
if(start_good == i){
fill(cyan);show(cor,6);
}*/
for(int index = 0;index<start.size();index++)
{
  if(start.get(index) == i&& I[i]){
  fill(cyan);show(cor,6);
  break;
  
  }
}
fill(black);label(cor,V(-15,0),str(i)); 

}
}

void show_corner_1(int i){
pt next = G[V[N[i]]];
int prev_no = N[i];
while(N[prev_no] != i){
prev_no = N[prev_no];
}
//print("prev_no"+prev_no+"\n");
pt prev = G[V[prev_no]];
vec t = U(G[V[i]],next);
vec u = U(G[V[i]],prev);
vec adding =t.add(u); 
pt cor = P(G[V[i]],20,adding);

fill(magenta); show(cor,6);
//fill(black);label(cor,V(-7,0),str(i)); 


}

void show_flat_non_flat(){
for(int i=0;i<nc;i++){
if(i+2<nc){
if(G[V[i]] == G[V[i+1]]&& G[V[i]] ==G[V[i+2]]){
if(I[i+2] == false && I[i]==true && I[i+1]==true){//flat (black)
 fill(black); show(G[V[i]],6);
}
else if((I[i+2] == true && I[i]==false && I[i+1]==true) ||(I[i+2] == true && I[i]==true && I[i+1]==false)){//concave non_flat (silver)
 fill(192,192,192); show(G[V[i]],6);
}
else if((I[i+2] == false && I[i]==false && I[i+1]==true) ||(I[i+2] == false && I[i]==true && I[i+1]==false)){//convex non_flat (red)
 fill(red); show(G[V[i]],6);
}
  
  
}
}
}

}
void containment(int start_good){
int c = start_good;
 
 if(S[c] !=-1&& S[S[c]]!=-1){
 if(I[S[S[c]]] && I[S[c]]==false)
  c = S[S[c]];
 if(!(I[S[c]]==true && I[S[S[c]]]==true)){
 strokeWeight(4);
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);}}
 else{
  strokeWeight(4);
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);
 }
 int count1 = 0;
 c = N[c];
 while(G[V[c]]!=G[V[start_good]]){
   if(count1>nc){
 break;
 }
 if(S[c] !=-1 && S[S[c]]!=-1){
 if(I[S[S[c]]]  && I[S[c]]==false)
  c = S[S[c]];
 if(!(I[S[c]]==true && I[S[S[c]]]==true)){
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);}}
 else{
  strokeWeight(4);
 stroke(red);line(G[V[c]].x,G[V[c]].y,G[V[N[c]]].x,G[V[N[c]]].y);
 }
 
 c = N[c];
 count1++;
 }

}

boolean split(pt A, pt B, pt a, pt an,int corner){
vec T = U(B,A);
vec Ba = V(B,a);
vec Ban = V(B,an);
if((det(T,Ba)>0 && det(T,Ban)<0) || (det(T,Ba)<0 && det(T,Ban)>0)){
  // return true;
  pt ann = G[V[N[N[N[corner]]]]];
  vec Aan = V(A,ann);
  vec a_an = V(a,an);
  vec AB = V(A,B);
  if((det(a_an,Aan)>0 && det(a_an,AB)>0) ||(det(a_an,Aan)<0 && det(a_an,AB)<0)){
     return true;
  }
  else
    return false;
}
else
return false;

}

pt intersection(pt A, pt B, pt a, pt an){//AB intersect with a,an
vec T = U(B,A);
vec aan = U(an,a);
vec N = R(aan);
float t = -(dot(V(a,B),N))/dot(T,N);
pt x = P(B,t,T);

return x;

}
}



class Node{
int index = 0;
Node left;
Node right;
Node(){}
Node(int i){index = i;};
}

class pts 
  {
  int nv=0;                                // number of vertices in the sequence
  int pv = 0;                              // picked vertex 
  int iv = 0;                              // insertion index 
  int maxnv = 100*2*2*2*2*2*2*2*2;         //  max number of vertices
  Boolean loop=true;                       // is a closed loop

  pt[] G = new pt [maxnv];                 // geometry table (vertices)

 // CREATE


  pts() {}
  
  void declare() {for (int i=0; i<maxnv; i++) G[i]=P(); }               // creates all points, MUST BE DONE AT INITALIZATION

  void empty() {nv=0; pv=0; }                                                 // empties this object
  
  void addPt(pt P) { G[nv].setTo(P); pv=nv; nv++;  }                    // appends a point at position P
  
  void addPt(float x,float y) { G[nv].x=x; G[nv].y=y; pv=nv; nv++; }    // appends a point at position (x,y)
  
  void insertPt(pt P)  // inserts new point after point pv
    { 
    for(int v=nv-1; v>pv; v--) G[v+1].setTo(G[v]); 
    pv++; 
    G[pv].setTo(P);
    nv++; 
    }
     
  void insertClosestProjection(pt M) // inserts point that is the closest to M on the curve
    {
    insertPt(closestProjectionOf(M));
    }
  
  void resetOnCircle(int k)                                                         // init the points to be on a well framed circle
    {
    empty();
    pt C = ScreenCenter(); 
    for (int i=0; i<k; i++)
      addPt(R(P(C,V(0,-width/3)),2.*PI*i/k,C));
    } 
  
  void makeGrid (int w) // make a 2D grid of w x w vertices
   {
   empty();
   for (int i=0; i<w; i++) 
     for (int j=0; j<w; j++) 
       addPt(P(.7*height*j/(w-1)+.1*height,.7*height*i/(w-1)+.1*height));
   }    


  // PICK AND EDIT INDIVIDUAL POINT
  
  void pickClosest(pt M) 
    {
    pv=0; 
    for (int i=1; i<nv; i++) 
      if (d(M,G[i])<d(M,G[pv])) pv=i;
    }

  void dragPicked()  // moves selected point (index pv) by the amount by which the mouse moved recently
    { 
    G[pv].moveWithMouse(); 
    }     
  
  void deletePickedPt() {
    if(pv%2==1) pv--;
    for(int i=pv; i<nv; i++) G[i].setTo(G[i+2]);
    pv=max(0,pv-1);       // reset index of picked point to previous
    nv=nv-2;  
    }
  
  void setPt(pt P, int i) 
    { 
    G[i].setTo(P); 
    }
  
  
  // DISPLAY
  
  void IDs() 
    {
    for (int v=0; v<nv; v++) 
      { 
      fill(white); 
      show(G[v],13); 
      fill(black); 
      if(v<10) label(G[v],str(v));  
      else label(G[v],V(-5,0),str(v)); 
      }
    noFill();
    }
  
  void drawArrows() 
    {
    stroke(blue); 
    for (int a=0; a<nv/2; a++) 
      { 
      fill(blue); arrow(G[2*a],G[2*a+1]);
      fill(white); 
      show(G[2*a],13); 
      fill(black); 
      if(a<10) label(G[2*a],str(a));  
      else label(G[2*a],V(-5,0),str(a)); 
      }
    noFill();
    }
  
  void showPicked() 
    {
    show(G[pv],13); 
    }
  
  void drawVertices(color c) 
    {
    fill(c); 
    drawVertices();
    }
  
  void drawVertices()
    {
    for (int v=0; v<nv; v++) show(G[v],13); 
    }
   
  void drawCurve() 
    {
    if(loop) drawClosedCurve(); 
    else drawOpenCurve(); 
    }
    
  void drawOpenCurve() 
    {
    beginShape(); 
      for (int v=0; v<nv; v++) G[v].v(); 
    endShape(); 
    }
    
  void drawClosedCurve()   
    {
    beginShape(); 
      for (int v=0; v<nv; v++) G[v].v(); 
    endShape(CLOSE); 
    }

  // EDIT ALL POINTS TRANSALTE, ROTATE, ZOOM, FIT TO CANVAS
  
  void dragAll() // moves all points to mimick mouse motion
    { 
    for (int i=0; i<nv; i++) G[i].moveWithMouse(); 
    }      
  
  void moveAll(vec V) // moves all points by V
    {
    for (int i=0; i<nv; i++) G[i].add(V); 
    }   

  void rotateAll(float a, pt C) // rotates all points around pt G by angle a
    {
    for (int i=0; i<nv; i++) G[i].rotate(a,C); 
    } 
  
  void rotateAllAroundCentroid(float a) // rotates points around their center of mass by angle a
    {
    rotateAll(a,Centroid()); 
    }
    
  void rotateAllAroundCentroid(pt P, pt Q) // rotates all points around their center of mass G by angle <GP,GQ>
    {
    pt G = Centroid();
    rotateAll(angle(V(G,P),V(G,Q)),G); 
    }

  void scaleAll(float s, pt C) // scales all pts by s wrt C
    {
    for (int i=0; i<nv; i++) G[i].translateTowards(s,C); 
    }  
  
  void scaleAllAroundCentroid(float s) 
    {
    scaleAll(s,Centroid()); 
    }
  
  void scaleAllAroundCentroid(pt M, pt P) // scales all points wrt centroid G using distance change |GP| to |GM|
    {
    pt C=Centroid(); 
    float m=d(C,M),p=d(C,P); 
    scaleAll((p-m)/p,C); 
    }

  void fitToCanvas()   // translates and scales mesh to fit canvas
     {
     float sx=100000; float sy=10000; float bx=0.0; float by=0.0; 
     for (int i=0; i<nv; i++) {
       if (G[i].x>bx) {bx=G[i].x;}; if (G[i].x<sx) {sx=G[i].x;}; 
       if (G[i].y>by) {by=G[i].y;}; if (G[i].y<sy) {sy=G[i].y;}; 
       }
     for (int i=0; i<nv; i++) {
       G[i].x=0.93*(G[i].x-sx)*(width)/(bx-sx)+23;  
       G[i].y=0.90*(G[i].y-sy)*(height-100)/(by-sy)+100;
       } 
     }   
     
  // MEASURES 
  float length () // length of perimeter
    {
    float L=0; 
    for (int i=nv-1, j=0; j<nv; i=j++) L+=d(G[i],G[j]); 
    return L; 
    }
    
  float area()  // area enclosed
    {
    pt O=P(); 
    float a=0; 
    for (int i=nv-1, j=0; j<nv; i=j++) a+=det(V(O,G[i]),V(O,G[j])); 
    return a/2;
    }   
    
  pt CentroidOfVertices() 
    {
    pt C=P(); // will collect sum of points before division
    for (int i=0; i<nv; i++) C.add(G[i]); 
    return P(1./nv,C); // returns divided sum
    }
  
  //pt Centroid() // temporary, should be updated to return centroid of area
  //  {
  //  return CentroidOfVertices();
  //  }

  
  pt closestProjectionOf(pt M) 
    {
    int c=0; pt C = P(G[0]); float d=d(M,C);       
    for (int i=1; i<nv; i++) if (d(M,G[i])<d) {c=i; C=P(G[i]); d=d(M,C); }  
    for (int i=nv-1, j=0; j<nv; i=j++) 
      { 
      pt A = G[i], B = G[j];
      if(projectsBetween(M,A,B) && disToLine(M,A,B)<d) 
        {
        d=disToLine(M,A,B); 
        c=i; 
        C=projectionOnLine(M,A,B);
        }
      } 
     pv=c;    
     return C;    
     }  

  Boolean contains(pt Q) {
    Boolean in=true;
    // provide code here
    return in;
    }
  
  pt Centroid () 
      {
      pt C=P(); 
      pt O=P(); 
      float area=0;
      for (int i=nv-1, j=0; j<nv; i=j, j++) 
        {
        float a = triangleArea(O,G[i],G[j]); 
        area+=a; 
        C.add(a,P(O,G[i],G[j])); 
        }
      C.scale(1./area); 
      return C; 
      }
        
  float alignentAngle(pt C) { // of the perimeter
    float xx=0, xy=0, yy=0, px=0, py=0, mx=0, my=0;
    for (int i=0; i<nv; i++) {xx+=(G[i].x-C.x)*(G[i].x-C.x); xy+=(G[i].x-C.x)*(G[i].y-C.y); yy+=(G[i].y-C.y)*(G[i].y-C.y);};
    return atan2(2*xy,xx-yy)/2.;
    }


  // FILE I/O   
     
  void savePts(String fn) 
    {
    String [] inppts = new String [nv+1];
    int s=0;
    inppts[s++]=str(nv);
    for (int i=0; i<nv; i++) {inppts[s++]=str(G[i].x)+","+str(G[i].y);}
    saveStrings(fn,inppts);
    };
  

  void loadPts(String fn) 
    {
    println("loading: "+fn); 
    String [] ss = loadStrings(fn);
    String subpts;
    int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
    nv = int(ss[s++]); print("nv="+nv);
    for(int k=0; k<nv; k++) {
      int i=k+s; 
      comma=ss[i].indexOf(',');   
      x=float(ss[i].substring(0, comma));
      y=float(ss[i].substring(comma+1, ss[i].length()));
      G[k].setTo(x,y);
      };
    pv=0;
    }; 
  
  }  // end class pts
  
  
 Node build_bsp(ArrayList<Integer> input){
  
  if(input.size()==0)
    {//print("()");
    return null;}
  else{
  ArrayList<Integer> left = new ArrayList<Integer>();
  ArrayList<Integer> right = new ArrayList<Integer>();
  int root = input.get(0);
  for(int i = 0;i<input.size();i++){
  vec root_line = V(P(P.G[2*root]),P(P.G[2*root+1]));
  vec next_line = V(P(P.G[2*root]),P.G[2*input.get(i)]);
  //print(i+" ");
  //print(det(root_line,next_line)+" ");
  //print("\n");
  if(det(root_line,next_line)>0)
    right.add(input.get(i));
  else if(det(root_line,next_line)<0){
    left.add(input.get(i));
  }
  }
  Node node = new Node();
  node.left = new Node();
  node.right = new Node();
  node.index = root;
  node.left = build_bsp(left);
  node.right = build_bsp(right);
  
 /* print("right:"); //<>//
 for(int i=0;i<right.size();i++)
  print(right.get(i)+" ");
  print("\n");
  
  print("left:");
 for(int i=0;i<left.size();i++)
  print(left.get(i)+" ");
  print("\n");*/
  //print("("+node.index+")");
  return node;
 }

 

}
