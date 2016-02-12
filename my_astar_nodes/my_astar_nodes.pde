// CONSTANTS
int BOARDWIDTH  = 64;
int BOARDHEIGHT = 64;
int TILESIZE    = 24;
int xoffset;
int yoffset;

// Globals
ArrayList openList;
ArrayList closedList;
ArrayList path;

int[] centerMousePosition;

// Types of tiles in the world
enum TILETYPE {EMPTY, STONE, GRASS};
// direction an entity may move
enum DIRECTION {UP, DOWN, LEFT, RIGHT};

// array to hold all nodes
Node[][] nodes;
Tile[][] tiles;

class Mover {
  
  int x,y;
  
  Mover(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  void display() {
   fill(255);
   rect(xoffset + x * TILESIZE, yoffset + y * TILESIZE, TILESIZE, TILESIZE);
  }
  
  void walk(DIRECTION dir) {
    
    if ( dir == DIRECTION.UP) {
      y -= 1;
    } else if ( dir == DIRECTION.DOWN ) {
      y += 1;
    } else if ( dir == DIRECTION.LEFT  ) {
      x -= 1;
    } else if ( dir == DIRECTION.RIGHT) {
      x += 1;
    }
  }
}

class Tile {
 
  int x, y;
  TILETYPE tileType;
  boolean walkable;
   
  Tile (int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  void display() {
   stroke(100, 100, 100);
   if ( tileType == TILETYPE.STONE) {
     fill(100, 100, 100);
     walkable = false;
   }
   else if ( tileType == TILETYPE.GRASS) {
    fill(50, 200, 50);
    walkable = true;
   }
   rect(xoffset + x * TILESIZE, yoffset + y * TILESIZE, TILESIZE, TILESIZE); 
  }
}

void initializeTiles() {
  
  tiles = new Tile[BOARDWIDTH][BOARDHEIGHT];
  
  for ( int j = 0; j < BOARDHEIGHT; j++) {
    for ( int i = 0; i < BOARDWIDTH; i++) {
      tiles[i][j] = new Tile(i,j);
      // random value used to determine the tile type
      int r = (int)random(5);
      if ( r == 0 ) tiles[i][j].tileType = TILETYPE.STONE;
      else tiles[i][j].tileType = TILETYPE.GRASS;
    }
  }
}

void drawTiles() {
 for ( int j = 0; j < BOARDHEIGHT; j++) {
  for ( int i = 0; i < BOARDWIDTH; i++) {
   fill(0);
   tiles[i][j].display();
  }
 }
}

class Node {
 
  int x,y;
  float g,h,f;
  Node parent;
  boolean walkable = false;
  
  Node(int x, int y) {
    this.x = x;
    this.y = y;
    f = g = h = 0;
  }
}

void pathFinder(Node start, Node target) {
  boolean done = false;
  // initialize the lists
  openList    = new ArrayList();
  closedList  = new ArrayList();
  path        = new ArrayList();
  // push the start nose onto the open list
  openList.add(start);
  
  
  while ( !done) {
    if ( openList.size() < 1 ) break;  
    // by default, choose the last node added to the opne list
    int bestNode = openList.size()-1;
    Node best = (Node)openList.get(bestNode);
    float minf = best.f;
    // find the node with the lowest f score in the open list
    for ( int i = 0; i < openList.size(); i++) {
      Node node = (Node)openList.get(i);
      if ( node.f < minf) {
        minf = node.f;
        bestNode = i;
      }
    }
    // set the best node to 'q'
    Node q = (Node)openList.get(bestNode);
    println("best Node");
    println(q.x, q.y, q.g, q.h, q.f);
    if ( q.x != start.x || q.y != start.y){
     Node p = q.parent;
     println("Parent: " + p.x + " " + p.y);
    }
    println();
    openList.remove(q);
    closedList.add(q);
    // find q's neighors
    ArrayList neighbors = new ArrayList();
    // search left
    if ( q.x - 1 >= 0 && tiles[q.x - 1][q.y].walkable) neighbors.add(nodes[q.x-1][q.y]);
    // search right
    if ( q.x + 1 < BOARDWIDTH && tiles[q.x + 1][q.y].walkable) neighbors.add(nodes[q.x+1][q.y]);
    // search up
    if ( q.y - 1 >= 0 && tiles[q.x][q.y-1].walkable) neighbors.add(nodes[q.x][q.y-1]);
    //search down
    if ( q.y + 1 < BOARDHEIGHT && tiles[q.x][q.y+1].walkable) neighbors.add(nodes[q.x][q.y+1]);
     println("neighbors");
    // handle neighbors
    for ( int i = 0; i < neighbors.size(); i++) {
     Node n = (Node)neighbors.get(i);
     // check if we've reached the destination
     if ( n.x == target.x && n.y == target.y) {
       println("done");
       path.add(n);
       done = true;
     }
   
     // if a node with the same position as neighbor is in the open List
     // and that node's f score is lower, skip this neighbor
     if ( inClosedList(n) ) {
       continue;
     } else if ( !inOpenList(n) ) {
       // calculate node score
       n.parent = q;
       n.g = q.g + 1;
       n.h = abs(target.x - n.x) + abs(target.y - n.y);
       n.f = n.g + n.h;
       openList.add(n);
       println(n.x, n.y, n.g, n.h, n.f);
     } 
  
     }
    }
   println();
}

// check if a node is already in the open list
boolean inOpenList(Node node) {
  // loop through each node on the open list
  for ( int i = 0; i < openList.size(); i++) {
    // get a node off the list
    Node n = (Node)openList.get(i);
    // if the node matches the location of our node
    if ( n.x == node.x && n.y == node.y) { 
        return true;
    }
  }
  return false;
}

// check if any nodes in the open list match 
// a passed node's location and have a lower f score
boolean inClosedList(Node node) {
  // loop through each node in the closed list
  for ( int i = 0; i < closedList.size(); i++) {
    Node n = (Node)closedList.get(i);
    // check if the current node matches our node's location
    if ( n.x == node.x && n.y == node.y) {
       return true;
    }
  }
  return false;
}

void buildPath(Node start) {
 // a node in the path
 if ( path.size() < 1 ) return;
 Node n = (Node)path.get(0);
  // flag to stop after we reach the end of the nodes
  boolean done = false;
  // walk backwards through the nodes and add them to the path 
  while (!done ) {
   Node p = n.parent;
   if ( p == null) return;
   n = p;
   if ( n.x == start.x && n.y == start.y) {
     done = true;
   } else  path.add(n);
  }
  
  ArrayList reversePath = new ArrayList();
  
   for ( int i = path.size()-1; i >= 0; i--) {
    Node pathNode = (Node)path.get(i);
    reversePath.add(pathNode);
    println(pathNode.x, pathNode.y);
   } 
   
   path = reversePath;
}

void drawPath() {
  stroke(255);
  noFill();
  
  for ( int i = 0; i < path.size(); i++) {
     Node n = (Node)path.get(i);
     rect(xoffset + n.x * TILESIZE, yoffset + n.y * TILESIZE, TILESIZE, TILESIZE);
  }
}

/* Entry point for the program
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
*/

Mover mover;

Node target;
Node start;

// timer and counter set used to time the character movement
float aTimer = 10;
float aCounter;

void setup() {
  size(640, 480);
  background(0);
  // create a new character
  mover = new Mover(BOARDWIDTH/2,BOARDHEIGHT/2);
  // set the offest for drawing the board tiles
  // so that our board is location in the center of the screen
  xoffset = ( width - (BOARDWIDTH * TILESIZE) ) /2;
  yoffset = ( height - (BOARDHEIGHT * TILESIZE ) ) /2;
  
  // create all the tiles 
  initializeTiles();
  // darw tiles on the screen
  drawTiles();
  // draw the mover character on the screen
  mover.display();
  
  // initialize nodes
  nodes = new Node[BOARDWIDTH][BOARDHEIGHT];   
  for ( int j = 0; j < BOARDHEIGHT; j++) {
   for ( int i =0; i < BOARDWIDTH; i++) {
    nodes[i][j] = new Node(i,j); 
   }
  }
  //set start and finish for the path finder
  start   = new Node(mover.x, mover.y);
  target  = new Node(mover.x, mover.y);
  
  pathFinder(start, target);

}

void draw() {
  
    int moveSpeed = 1;
   if ( mouseX > width - width/7 ) {
     xoffset -= moveSpeed;
   } else if ( mouseX < width/7) {
     xoffset += moveSpeed; 
   } 
   if ( mouseY > height - height/7) {
     yoffset -= moveSpeed; 
   } else if ( mouseY < height/7) {
     yoffset += moveSpeed; 
   }
  
  // timer for the animation
  aCounter += 1;
  if ( aCounter > aTimer) {
    aCounter = 0;
   
   if ( path.size() > 0) {
    
     Node n = (Node)path.get(0);
     mover.x = n.x;
     mover.y = n.y;
     
     start = new Node(mover.x, mover.y);
     pathFinder(start, target);
     buildPath(start);
     drawTiles();
     drawPath();
     mover.display();
   }
  }
 
}

// INPUT
//////////////////////////////////////////////////////////

// input variables

PVector startMousePosition;

void mousePressed() {
 
  if ( mouseButton == LEFT) {
    setup();
    
  } else if ( mouseButton == CENTER) {
   startMousePosition = new PVector(mouseX, mouseY);
    
  } else if (mouseButton == RIGHT) {
    target.x = (mouseX - xoffset)/TILESIZE;
    target.y = (mouseY - yoffset)/TILESIZE;
    start   = new Node(mover.x, mover.y);
  
    pathFinder(start, target);
    buildPath(start);
    drawTiles();
    mover.display();
    drawPath();
    stroke(255, 0, 0);
    rect(xoffset + target.x * TILESIZE, yoffset + target.y * TILESIZE, TILESIZE, TILESIZE); 
  }
}

void mouseReleased() {
 
}

void keyPressed() {
 
  if ( key == CODED) {
  
  }
}