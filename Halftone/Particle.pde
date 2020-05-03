// class Spore extends the class "VerletParticle2D"
class Particle extends VerletParticle2D {

  float r;
  ParticleBehavior2D behavior;

  Particle (Vec2D loc) {
    super(loc);
    physics.addParticle(this);
  }

  void updateParticle(float particleRadius, float strength, float forceRadius , int mode,boolean drawSmallCircles, int xStart, int yStart){
    lock();
    r = particleRadius;
    int r2 = int(r);
    if (r2%2 == 0){
      r2 += 1;
    }
    r = r2;
    physics.removeBehavior(behavior);
    if(mode == 6 || mode == 7){
      behavior = new AttractionBehavior(this,forceRadius,-strength/particleRadius);  
    }
    else if (mode == 8){
      behavior = new AttractionBehavior(this,forceRadius*particleRadius,-particleRadius*strength);
    }
    
    physics.addBehavior(behavior);
    unlock();
    if(drawSmallCircles || r>3){
      //float pick = random(3);

      //if(pick <1){
        //fill(255,0,0);
        ellipse (int(x)+xStart,int(y)+yStart, r, r);
      }
     /* else if(pick <2){
        fill(0,255,0);
        triangle(int(x)+xStart,int(y)+yStart-r/1.5,int(x)+xStart+(r/1.5/1.414),int(y)+yStart+(r/1.5/1.414),int(x)+xStart-(r/1.5/1.414),int(y)+yStart+(r/1.5/1.414));
      }
      else if (pick<3){
        fill(0,0,255);
        rect(int(x)+xStart-r,int(y)+yStart-r,r,r);
      }*/

  //  }
    
  }
  /*void display () {
    
    fill (127);
    stroke (0);
    strokeWeight(2);
    ellipse (x, y, r*2, r*2);
  }*/
}
