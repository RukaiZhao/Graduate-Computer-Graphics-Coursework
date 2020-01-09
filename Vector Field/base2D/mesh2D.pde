// PLANAR TRIANGLE MESH
// Jarek Rossignac, Nov 6, 2019

class MESH {
    // VERTICES
    int nv=0, maxnv = 1000;  
    pt[] G = new pt [maxnv];   // location of vertex
    vec[] F = new vec [maxnv]; // vector at vertex
    boolean[] constrained = new boolean[maxnv];
    
    // TRIANGLES 
    int nt = 0, maxnt = maxnv*2;                           
    boolean[] isInterior = new boolean[maxnv]; 
    
    // CORNERS 
    int c=0;    // current corner                                                              
    int nc = 0; // corner count
    boolean[] visited = new boolean[3*maxnt];
    int[] V = new int [3*maxnt];   // Corner table c.v
    int[] O = new int [3*maxnt];   // Corner table o.v
     
  MESH() {for (int i=0; i<maxnv; i++) {G[i]=P(); F[i]=V();}}; // declare all points and vectors
  void reset() {nv=0; nt=0; nc=0;}                                                  // removes all vertices and triangles
  void loadVertices(pt[] P, int n) {nv=0; for (int i=0; i<n; i++) addVertex(P[i]);}
  void writeVerticesTo(pts P) {for (int i=0; i<nv; i++) P.G[i].setTo(G[i]);}
  void addVertex(pt P) { G[nv++].setTo(P); }                                             // adds a vertex to vertex table G
  void addTriangle(int i, int j, int k) {V[nc++]=i; V[nc++]=j; V[nc++]=k; nt=nc/3; }     // adds triangle (i,j,k) to V table
  void addVertexPVfromPP(pt A, pt B) {G[nv].setTo(A); F[nv++].setTo(V(A,B));}                                             // adds a vertex to vertex table G
  void loadFromPTS(pts P) {
  int n=P.nv; 
   nv=0; 
   for (int i=0; i<n; i+=2) 
      addVertexPVfromPP(P.G[i],P.G[i+1]);}

  // CORNER OPERATORS
  int t (int c) {int r=int(c/3); return(r);}                   // triangle of corner c
  int n (int c) {int r=3*int(c/3)+(c+1)%3; return(r);}         // next corner
  int p (int c) {int r=3*int(c/3)+(c+2)%3; return(r);}         // previous corner
  int v (int c) {return V[c];}                                // vertex of c
  int o (int c) {return O[c];}                                // opposite corner
  int l (int c) {return o(n(c));}                             // left
  int s (int c) {return n(o(n(c)));}                             // left
  int u (int c) {return p(o(p(c)));}                             // left
  int r (int c) {return o(p(c));}                             // right
  pt g (int c) {return G[V[c]];}                             // shortcut to get the point where the vertex v(c) of corner c is located
  vec f (int c) {return F[V[c]];}                             // shortcut to get the vector of the vertex v(c) of corner c 
  pt cg(int c) {return P(0.8,g(c),0.1,g(p(c)),0.1,g(n(c)));}   // computes offset location of point at corner c

  boolean nb(int c) {return(O[c]!=c);};  // not a border corner
  boolean bord(int c) {return(O[c]==c);};  // not a border corner
  int firstBorderCorner() {int i=0; while(nb(i) && i<nc) i++; return i;}
  pt firstBorderEdgeMidPoint() {int fbc = M.firstBorderCorner(); return P(g(p(fbc)),g(n(fbc)));}
  void tracePathFromMidEdgeFacingCorner(int sc) // sc = start corner
    {
    pt P = P(g(p(sc)),g(n(sc))); // start at midpoint of edge facing sc
    int c = sc;
    pen(magenta,3); show(cg(c),8);
    for(int i=0; i<1; i++)
      {
      pt Q = P();
      pen(brown,3); noFill(); 
      int exitCode = drawCorrectedTraceInTriangleFrom(P,g(c),f(c),g(n(c)),f(n(c)),g(p(c)),f(p(c)),200,0.1,Q);
       // STUDENT: ADD CODE HERE
      pen(magenta,3); show(cg(c),8);
      P.setTo(Q);
      }
    }
  
  // CURRENT CORNER OPERATORS
  void next() {c=n(c);}
  void previous() {c=p(c);}
  void opposite() {c=o(c);}
  void left() {c=l(c);}
  void right() {c=r(c);}
  void swing() {c=s(c);} 
  void unswing() {c=u(c);} 
  void printCorner() {println("c = "+c);}
  
  // DISPLAY
  void showCurrentCorner(float r) { show(cg(c),r); };   // renders corner c 
  void showEdge(int c) {edge( g(p(c)),g(n(c))); };  // draws edge of t(c) opposite to corner c
  void showVertices(float r) {for (int v=0; v<nv; v++) show(G[v],r); }                          // shows all vertices 
  void showBorderVertices(float r) {for (int v=0; v<nv; v++) if(!isInterior[v]) show(G[v],r);} // shows only border vertices              
  void showInteriorVertices(float r) {for (int v=0; v<nv; v++) if(isInterior[v]) show(G[v],r); }   // shows interior vertices 
  void showTriangles() { for (int c=0; c<nc; c+=3) show(g(c), g(c+1), g(c+2)); }         // draws all triangles (edges, or filled)
  void showEdges() {for (int i=0; i<nc; i++) showEdge(i); };         // draws all edges of mesh twice
  void showBorderEdges() {for (int i=0; i<nc; i++) {if (bord(i)) {showEdge(i);}; }; };         // draws all border edges of mesh
  void showNonBorderEdges() {for (int i=0; i<nc; i++) {if (!bord(i)) {showEdge(i);}; }; };         // draws all border edges of mesh
  void showVerticesAndVectors(float r) {for (int v=0; v<nv; v++) {show(G[v],r); arrow(G[v],F[v]);}}                          // shows all vertices 
  void drawArrows() 
    {
    stroke(blue); 
    for (int v=0; v<nv; v++) 
      { 
      fill(blue); arrow(G[v],F[v]);
      fill(white); 
      show(G[v],13); 
      fill(black); 
      if(v<10) label(G[v],str(v));  
      else label(G[v],V(-1,0),str(v)); 
      }
    noFill();
    }
  void showCorner(int c, float r) { if(bord(c)) show(cg(c),1.5*r); else show(cg(c),r); };   // renders corner c 
  void showCorners(float r) 
    {
    noStroke(); 
    for (int c=0; c<nc; c+=3) 
      {
      fill(red); showCorner(c,r); 
      fill(dgreen); showCorner(c+1,r); 
      fill(blue); showCorner(c+2,r);
      } 
    }

  // DISPLAY
  void classifyVertices() 
    { 
    for (int v=0; v<nv; v++) isInterior[v]=true;
    for (int c=0; c<nc; c++) if(bord(c)) isInterior[v(n(c))]=false;
    }               

 void triangulate() {     // performs Delaunay triangulation using a quartic algorithm
   c=0;                   // to reset current corner
   pt X = new pt(0,0);
   float r=1;
   for (int i=0; i<nv-2; i++) for (int j=i+1; j<nv-1; j++) for (int k=j+1; k<nv; k++) {
      X=CircumCenter(G[i],G[j],G[k]);  r = d(X,G[i]);
      boolean found=false; 
      for (int m=0; m<nv; m++) if ((m!=i)&&(m!=j)&&(m!=k)&&(d(X,G[m])<=r)) found=true;  
     if (!found) {
     if (cw(G[i],G[j],G[k])) 
       addTriangle(i,j,k); 
     else addTriangle(i,k,j);
   };
     }; 
   }  

  void computeO() {   // slow method to set the O table from the V table, assumes consistent orientation of tirangles
    for (int i=0; i<3*nt; i++) {O[i]=i;};  // init O table to -1: has no opposite (i.e. is a border corner)
    for (int i=0; i<3*nt; i++) {  for (int j=i+1; j<3*nt; j++) {       // for each corner i, for each other corner j
      if( (v(n(i))==v(p(j))) && (v(p(i))==v(n(j))) ) {O[i]=j; O[j]=i;};};}; // make i and j opposite if they match 
   }
  
  void computeOfast() // faster method for computing O
    {                                          
    int nIC [] = new int [maxnv];                            // number of incident corners on each vertex
    println("COMPUTING O: nv="+nv +", nt="+nt +", nc="+nc );
    int maxValence=0;
    for (int c=0; c<nc; c++) {O[c]=c;};                      // init O table to -1: has no opposite (i.e. is a border corner)
    for (int v=0; v<nv; v++) {nIC[v]=0; };                    // init the valence value for each vertex to 0
    for (int c=0; c<nc; c++) {nIC[v(c)]++;}                   // computes vertex valences
    for (int v=0; v<nv; v++) {if(nIC[v]>maxValence) {maxValence=nIC[v]; };};  println(" Max valence = "+maxValence+". "); // computes and prints maximum valence 
    int IC [][] = new int [maxnv][maxValence];                 // declares 2D table to hold incident corners (htis can be folded into a 1D table !!!!!)
    for (int v=0; v<nv; v++) {nIC[v]=0; };                     // resets the valence of each vertex to 0 . It will be sued as a counter of incident corners.
    for (int c=0; c<nc; c++) {IC[v(c)][nIC[v(c)]++]=c;}        // appends incident corners to corresponding vertices     
    for (int c=0; c<nc; c++) {                                 // for each corner c
      for (int i=0; i<nIC[v(p(c))]; i++) {                     // for each incident corner a of the vertex of the previous corner of c
        int a = IC[v(p(c))][i];      
        for (int j=0; j<nIC[v(n(c))]; j++) {                   // for each other corner b in the list of incident corners to the previous corner of c
           int b = IC[v(n(c))][j];
           if ((b==n(a))&&(c!=n(b))) {O[c]=n(b); O[n(b)]=c; };  // if a and b have matching opposite edges, make them opposite
           };
        };
      };
    } // end computeO
  
  pt triCenter(int c) {return P(g(c),g(n(c)),g(p(c))); }  // returns center of mass of triangle of corner c
  pt triCircumcenter(int c) {return CircumCenter(g(c),g(n(c)),g(p(c))); }  // returns circumcenter of triangle of corner c

  void smoothenInterior() { // even interior vertiex locations
    pt[] Gn = new pt[nv];
    int[] sum = new int[nv];
    for (int v=0; v<nv; v++) sum[v]=0;
    for (int v=0; v<nv; v++) Gn[v]=P(0,0);
    for (int c=0; c<3*nt; c++) 
      {
      float d=d(g(n(c)),g(p(c))); 
      Gn[v(c)].add(d,P(g(n(c)),g(p(c)))); 
      sum[v(c)]+=d;
      }
    for (int v=0; v<nv; v++) Gn[v].scale(1./sum[v]);
    for (int v=0; v<nv; v++) if(isInterior[v]) G[v].translateTowards(.1,Gn[v]);
    }
    
void classify_vectors(){
  /*int rand1 = new Random().nextInt(nv);
  int rand2 = new Random().nextInt(nv);
  int rand3 = new Random().nextInt(nv);
  int rand4 = new Random().nextInt(nv); */
  
  int rand1 = 1;
  int rand2 = 3;
  int rand3 = 5;
  int rand4 = 6;
  
  //print(rand1+" "+rand2+" "+rand3+" "+rand4+" ");
  
  constrained[rand1] = true;
  constrained[rand2] = true;
  constrained[rand3] = true;
  constrained[rand4] = true;
  
  
  for(int i=0;i<nv;i++){
  if(i!=rand1 && i!=rand2 && i!=rand3 && i!=rand4)
    constrained[i]=false;
  
  }

  
  
}
    
    
vec vec_in_tri(pt P, pt A, vec vA, pt B, vec vB, pt C, vec vC){
  float ABC = triangleArea(A,B,C);
  float CAP = triangleArea(C,A,P);
  float ABP = triangleArea(A,B,P);
  float BCP = triangleArea(B,C,P);
  
  float u = CAP/ABC;
  float v = ABP/ABC;
  float w = BCP/ABC;
  
  //fill(yellow);show(P,6);
  vec result = W(w,vA,u,vB,v,vC);
  //result = U(result);
  //fill(yellow);
  //arrow(P,result);
  
  return result;
 
}
boolean bary_coord(pt P, pt A,  pt B,  pt C){
float ABC = triangleArea(A,B,C);
float CAP = triangleArea(C,A,P);
float ABP = triangleArea(A,B,P);
float BCP = triangleArea(B,C,P);
  
float u = CAP/ABC;
float v = ABP/ABC;
float w = BCP/ABC;

//pt result = P(w,A,u,B,v,C);
if((u<=1 && u>=0) && (v<=1 && v>=0) && (w<=1 && w>=0))
 return true;
else
 return false;
  
}

void draw_field_on_centroids(){

for(int i=0;i<nc-2;i+=3){
pt centroid = P(G[V[i]],G[V[i+1]],G[V[i+2]]);
fill(yellow);show(centroid,6);
vec result = vec_in_tri(centroid, G[V[i]], F[V[i]], G[V[i+1]], F[V[i+1]], G[V[i+2]], F[V[i+2]]);
fill(yellow);
arrow(centroid,result);

}

}
void single_naive_trace(pt P, pt A, vec vA, pt B, vec vB, pt C, vec vC){

float s = 0.2;
int count = 0;
pt point = P;
while(count<80){
// print("count:"+count+" ");

if(showdiscpoints){
fill(dgreen);show(point,2);}
vec tr = vec_in_tri(point,A,vA,B,vB,C,vC); 
pt next_p = P(point, s, tr);
if(showdiscpoints){
fill(dgreen);show(next_p,2);}
stroke(brown);
line(point.x,point.y,next_p.x,next_p.y);
if(split(A,B,point,next_p)||split(B,C,point,next_p)||split(A,C,point,next_p)){
  if(find_in_tri(next_p)){
   int corner = point_in_tri(next_p);
   
   if(!visited[corner]){
   visited[corner]=true;
   visited[corner+1]=true;
   visited[corner+2]=true;
   if(colortri){
      stroke(black);
         fill(yellow);
            beginShape();
          vertex(G[V[corner]].x,G[V[corner]].y);
          vertex(G[V[corner+1]].x,G[V[corner+1]].y);
          vertex(G[V[corner+2]].x,G[V[corner+2]].y);
   endShape();}
   
   single_naive_trace(next_p, G[V[corner]], F[V[corner]], G[V[corner+1]], F[V[corner+1]], G[V[corner+2]], F[V[corner+2]]);
   break;
   }
   else
     break;
   
  }
  else
    break;
   
}

point = next_p;
count++;
}


}

void naive_trace(pt P, pt A, vec vA, pt B, vec vB, pt C, vec vC){
float s = 0.2;
int count = 0;
pt point = P;
while(count<80){
// print("count:"+count+" ");

if(showdiscpoints){
fill(dgreen);show(point,2);}
vec tr = vec_in_tri(point,A,vA,B,vB,C,vC); 
pt next_p = P(point, s, tr);
if(showdiscpoints){
fill(dgreen);show(next_p,2);}
stroke(brown);
line(point.x,point.y,next_p.x,next_p.y);
if(split(A,B,point,next_p)||split(B,C,point,next_p)||split(A,C,point,next_p)){
  int half = count/2;
  pt pp = P;
  for(int i=0;i<half;i++){
  vec in_v = vec_in_tri(pp,A,vA,B,vB,C,vC); 
  pp = P(pp, s, in_v);
  }
  fill(red);show(pp,4);new_MP[new_nv]=pp;
  new_nv++;
  if(find_in_tri(next_p)){
   int corner = point_in_tri(next_p);
   
   if(!visited[corner]){
   visited[corner]=true;
   visited[corner+1]=true;
   visited[corner+2]=true;
   if(colortri){
      stroke(black);
         fill(yellow);
            beginShape();
          vertex(G[V[corner]].x,G[V[corner]].y);
          vertex(G[V[corner+1]].x,G[V[corner+1]].y);
          vertex(G[V[corner+2]].x,G[V[corner+2]].y);
   endShape();}
   
   naive_trace(next_p, G[V[corner]], F[V[corner]], G[V[corner+1]], F[V[corner+1]], G[V[corner+2]], F[V[corner+2]]);
   break;
   }
   else
     break;
   
  }
  else
    break;
   
}
/*if(count ==10){
fill(red);show(point,4);
new_MP[new_nv]=point;
new_nv++;
}*/
point = next_p;
count++;
}


}



pt intersection(pt A, pt B, pt a, pt an){//AB intersect with a,an
vec T = U(B,A);
vec aan = U(an,a);
vec N = R(aan);
float t = -(dot(V(a,B),N))/dot(T,N);
pt x = P(B,t,T);

return x;

}

void opp_naive_trace(pt P, pt A, vec vA, pt B, vec vB, pt C, vec vC){

float s = 0.2;
int count = 0;
pt point = P;
while(count<80){
if(showdiscpoints){
fill(dgreen);show(point,2);}
vec tr = vec_in_tri(point,A,vA,B,vB,C,vC); 
pt next_p = P(point, s, tr.reverse());
if(showdiscpoints){       
fill(dgreen);show(next_p,2);}
stroke(brown);
line(point.x,point.y,next_p.x,next_p.y);
if(split(A,B,point,next_p)||split(B,C,point,next_p)||split(A,C,point,next_p)){
int half = count/2;
  pt pp = P;
  for(int i=0;i<half;i++){
  vec in_v = vec_in_tri(pp,A,vA,B,vB,C,vC); 
  pp = P(pp, s, in_v.reverse());
  }
  fill(red);show(pp,4);new_MP[new_nv]=pp;
  new_nv++;

//break;
if(find_in_tri(next_p)){
   int corner = point_in_tri(next_p);
   
   if(!visited[corner]){
   visited[corner]=true;
   visited[corner+1]=true;
   visited[corner+2]=true;
   if(colortri){
      stroke(black);
         fill(yellow);
            beginShape();
          vertex(G[V[corner]].x,G[V[corner]].y);
          vertex(G[V[corner+1]].x,G[V[corner+1]].y);
          vertex(G[V[corner+2]].x,G[V[corner+2]].y);
   endShape();}
   
   opp_naive_trace(next_p, G[V[corner]], F[V[corner]], G[V[corner+1]], F[V[corner+1]], G[V[corner+2]], F[V[corner+2]]);
   break;
   }
   else
     break;
   
  }
  else
    break;


   
}
/*if(count ==10){
fill(red);show(point,4);
new_MP[new_nv]=point;
new_nv++;
}*/
point = next_p;
count++;
}


}

boolean split(pt A, pt B, pt a, pt an){
vec T = U(B,A);
vec Ba = V(B,a);
vec Ban = V(B,an);
if((det(T,Ba)>0 && det(T,Ban)<0) || (det(T,Ba)<0 && det(T,Ban)>0))
   return true;
else
return false;

}


int point_in_tri(pt P){
int corner = 0;
for(int i=0;i<nc-2;i+=3){
if(bary_coord(P,G[V[i]],G[V[i+1]],G[V[i+2]]))
   return i;
}
return corner;
}

boolean find_in_tri(pt P){
for(int i=0;i<nc-2;i+=3){
if(bary_coord(P,G[V[i]],G[V[i+1]],G[V[i+2]]))
   return true;
}
return false;
}

void set_visited(){
for(int i=0;i<nc;i++){
visited[i] = false;
}
}

vec find_vec(pt vertex, vec vec_v){
  ArrayList<vec> incident_tri = new ArrayList<vec>();
  
  for(int i=0;i<nc-2;i+=3){
  if((G[V[i]]==vertex) ||(G[V[i+1]]==vertex)||(G[V[i+2]]==vertex)){
  pt centroid = P(G[V[i]],G[V[i+1]],G[V[i+2]]);
  vec result = vec_in_tri(centroid, G[V[i]], F[V[i]], G[V[i+1]], F[V[i+1]], G[V[i+2]], F[V[i+2]]);
  incident_tri.add(result);
  }
  }
  
  vec average =incident_tri.get(0);
  if(linear_spiral){
  for(int i=1;i<incident_tri.size();i++){
    ARROW A1 = Arrow(vertex,average);
    ARROW A2 = Arrow(vertex,incident_tri.get(i));
    average =LerpAverageOfArrows(A1,A2).V;
   }
  }
  else{
  for(int i=0;i<incident_tri.size();i++){
    ARROW A1 = Arrow(vertex,average);
    ARROW A2 = Arrow(vertex,incident_tri.get(i));
    average = SteadyAverageOfArrows(A1,A2).V;
   }
  }
  //vec result = V();
  if(linear_spiral){
  ///result = L(average,vec_v,0.5);
   return average;
}
  else{
  //log spiral
   //result = S(average,vec_v,0.5);
   return average;
 }
  
  //return result;

}
void tuck_untuck_span(){
  int rand1 = 1;
  int rand2 = 3;
  int rand3 = 5;
  int rand4 = 6;
  vec[] F_modify = new vec [maxnv];
  for(int i=0;i<nv;i++)
   F_modify[i] = V();
  F_modify[rand1] = F[rand1];
  F_modify[rand2] = F[rand2];
  F_modify[rand3] = F[rand3];
  F_modify[rand4] = F[rand4];
  
  int iterate = 20;
  int count = 0;
  while(count<iterate){
    for(int i=0;i<nv;i++){
       F_modify[i] = find_vec(G[i], F_modify[i]);
    }
   
  F_modify[rand1] = F[rand1];
  F_modify[rand2] = F[rand2];
  F_modify[rand3] = F[rand3];
  F_modify[rand4] = F[rand4];
  count++;
  }
  
  for(int i=0;i<nv;i++)
  F[i] = F_modify[i];
 

}
boolean tri_on_trace(pt A, pt B, pt C, ArrayList<pt> trace){
boolean flag1 = false;
boolean flag2 = false;
boolean flag3 = false;

/*for(int i=0;i<trace.size();i++){
if(A == trace.get(i)) flag1 = true;
if(B == trace.get(i)) flag2 = true;
if(C == trace.get(i)) flag3 = true;
}*/

for(int i=0;i<trace.size();i++){
if(A.x == trace.get(i).x && A.y == trace.get(i).y) 
{flag1 = true;
break;}
}

for(int i=0;i<trace.size();i++){
if(B.x == trace.get(i).x && B.y == trace.get(i).y) 
{flag2 = true;
break;}
}

for(int i=0;i<trace.size();i++){
if(C.x == trace.get(i).x && C.y == trace.get(i).y) 
{flag3 = true;
break;}
}

boolean flag = flag1 && flag2 && flag3;

return flag;

}  
void modify_triangulate(){
c=0;                   // to reset current corner
   pt X = new pt(0,0);
   float r=1;
   for (int i=0; i<nv-2; i++) for (int j=i+1; j<nv-1; j++) for (int k=j+1; k<nv; k++) {
      X=CircumCenter(G[i],G[j],G[k]);  r = d(X,G[i]);
      boolean found=false; 
      for (int m=0; m<nv; m++) if ((m!=i)&&(m!=j)&&(m!=k)&&(d(X,G[m])<=r)) found=true;  
     if (!found) {
     boolean flag = false;
     //print(select_samples.size());
     for(int index = 0;index<select_samples.size();index++){
     if(tri_on_trace(G[i],G[j],G[k],select_samples.get(index))){
       //print("here");
       flag = true;
       break;
     }
     }
       
     if(!flag){
      if(abs(angle(G[i],G[j],G[k]))<3.054 &&abs(angle(G[j],G[i],G[k]))<3.054&&abs(angle(G[i],G[k],G[j]))<3.054){
      if (cw(G[i],G[j],G[k])) 
       addTriangle(i,j,k); 
     else addTriangle(i,k,j);}}
   };
     
   
 }; 

}




} // end of MESH
  
  
  
  
  
