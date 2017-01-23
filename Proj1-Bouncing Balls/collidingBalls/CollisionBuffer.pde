import java.util.*;

// This file was written by Michael X. Grey. It provides a class that will handle all of the collision
// prediction and handling, and also buffers the predictions.

class CollisionData {
  CollisionData() { time = Float.POSITIVE_INFINITY; index[0] = 0; index[1] = 0; printedCollision = false; }
  float time; // Time of the collision
  int[] index = new int[2]; // Index of each ball
  vec[] pc = new vec[2]; // Collision location of each ball
  vec[] vc = new vec[2]; // Velocity of each ball after the collision
  int wall; // Wall index, if the collision occurs with a wall
  
  boolean printedCollision;
}

class State {
  
  vec p;
  vec v;
  float time;
  
  State() { }
  
}

float computeCollisionTime(vec p_init1, vec v01, float t1, vec p_init2, vec v02, float t2, float R) {
  
  float lastCollisionTime;
  if(t1 > t2)
    lastCollisionTime = t1;
  else
    lastCollisionTime = t2;
  
  vec p02 = new vec(v02);
  p02.mul(-t2);
  p02.add(p_init2);
  
  vec p01 = new vec(v01);
  p01.mul(-t1);
  p01.add(p_init1);
  
  vec dp0 = new vec(p02);
  dp0.sub(p01);
  
  vec dv0 = new vec(v02);
  dv0.sub(v01);
  
  float dp0_dv0 = dot(dp0,dv0);
  float dv0_norm2 = dot(dv0,dv0);
  float dp0_norm2 = dot(dp0,dp0);
  
  float S = 4*R*R*dv0_norm2 + dp0_dv0*dp0_dv0 - dv0_norm2*dp0_norm2;
  if(S < 0.0) {
   // Negative discriminant means they will never collide
   return Float.POSITIVE_INFINITY;
  }
  float S_sqrt = sqrt(S);
  
  //float t_plus = -dp0_dv0 + S_sqrt;
  //if(t_plus < lastCollisionTime) t_plus = Float.POSITIVE_INFINITY;
  float t_plus = Float.POSITIVE_INFINITY;
  
  float t_minus = -dp0_dv0 - S_sqrt;
  if(t_minus < lastCollisionTime) t_minus = Float.POSITIVE_INFINITY;
  
  float t;
  if(t_plus < t_minus) {
    t = t_plus;
  } else {
    t = t_minus;
  }
  
  if(t == Float.POSITIVE_INFINITY)
    return t;
  
  //if(t > -dp0_dv0)
  //  return Float.POSITIVE_INFINITY;
  
  return t / dv0_norm2;
}

class CollisionBuffer {
  CollisionBuffer() { };
  
  float[] wallSign = new float[]{1.0, -1.0, 1.0, -1.0, 1.0, -1.0};
  int[] wallAxis = new int[]{0, 0, 1, 1, 2, 2};
  
  CollisionData[][] data = new CollisionData[BALLS.maxnv][BALLS.maxnv];
  Deque<CollisionData> queue = new LinkedList<CollisionData>();
  State[] finalState = new State[BALLS.maxnv];
  
  void updateP(float time) {
    
    if(queue.size() == 0) {
      //System.err.println("Error: Collision queue is empty!!");
      return;
    }
    
    CollisionData c = queue.getFirst();
    while(c.time < time) {
      System.out.println("Initial queue size: "+queue.size()+" | Current time: "+time+" | Highest queued time: "+queue.getLast().time);
    
      for(int index=0; index < 2; ++index) {
        if( index == 1 && c.index[0] == c.index[1] ) {
          break;
        }
        
        vec dp = new vec(c.vc[index]);
        dp.mul(c.time);
        
        int i = c.index[index];
        vec p = new vec(c.pc[index]);
        p.sub(dp);
        P.G0[i] = new pt(p);
        
        if(c.index[0] != c.index[1]) {
          System.out.print("["+c.index[index]+"] Old v: "+toText(P.V[i]));
        }
        
        P.V[i] = new vec(c.vc[index]);
        
        if(c.index[0] != c.index[1]) {
          System.out.println("| New v: "+toText(P.V[i]));
        }
        
        if(c.index[0] != c.index[1]) {
        
          vec result_p = new vec(P.G0[i]);
          result_p.add(c.time, P.V[i]);
          vec p_error = new vec(result_p);
          p_error.sub(c.pc[index]);
          
          //System.out.println("Old p: "+toText(c.pc[index])+" | New p: "+toText(result_p));
          System.out.println("P error: "+toText(p_error));
        }
      }
      
      if(queue.size() == 1) {
        //System.out.println("Computing new collision because queue is too small");
        //computeFutureCollision();
        
        System.out.println("Ran out of collisions");
      }
      
      System.out.println("Handling a collision at time "+c.time+" (sim time: "+time+")");
      queue.removeFirst();
      c = queue.getFirst();
      System.out.println("Next collision time: "+c.time);
    }
    
  }
  
  CollisionData updateCollisionData(int i) {
    
    float lowestTime = Float.POSITIVE_INFINITY;
    int[] lowestIndices = new int[]{0, 0};
    
    float Ri = P.r[i];
    vec p0i = new vec(finalState[i].p);
    vec v0i = new vec(finalState[i].v);
    float ti = finalState[i].time;
    
    // Compute wall collisions
    CollisionData cwall = new CollisionData();
    cwall.index[0] = i; cwall.index[1] = i;
    float lowestWallTime = Float.POSITIVE_INFINITY;
    int wall = 6;
    
    for(int j=0; j < 6; ++j) {
      int axis = wallAxis[j];
      float v0in = v0i.getComponent(axis);
      if(v0in == 0.0)
        continue;
      
      float p0in = p0i.getComponent(axis);
      float time = (wallSign[j]*(w/2.0 - Ri) -  p0in)/v0in + ti;
      
      if(time <= ti) time = Float.POSITIVE_INFINITY;
      
      if(time < lowestWallTime) {
        lowestWallTime = time;
        wall = j;
      }
    }
    
    cwall.wall = wall;
    cwall.time = lowestWallTime;
    data[i][i] = cwall;
    
    if(lowestWallTime < lowestTime) {
      lowestTime = lowestWallTime;
      lowestIndices[0] = i;
      lowestIndices[1] = i;
    }
    
    // Compute ball-to-ball collisions
    for(int j=i+1; j < P.nv; ++j) {
      vec p0j = new vec(finalState[j].p);
      vec v0j = new vec(finalState[j].v);
      float tj = finalState[j].time;
      
      float time = computeCollisionTime(p0i, v0i, ti, p0j, v0j, tj, Ri);
      CollisionData c = new CollisionData();
      c.time = time;
      c.index[0] = i;
      c.index[1] = j;
      
      data[i][j] = c;
      
      if(time < lowestTime) {
        lowestTime = time;
        lowestIndices[0] = i;
        lowestIndices[1] = j;
      }
    }
    
    return data[lowestIndices[0]][lowestIndices[1]];
  };
  
  void initialize() {
    
    for(int i=0; i < P.nv; ++i) {
      State s = new State();
      s.p = new vec(P.G0[i]);
      s.v = new vec(P.V[i]);
      s.time = 0.0;
      
      finalState[i] = s;
    }
    
    queue.clear();
    
    CollisionData soonest = new CollisionData();
    for(int i=0; i < P.nv; ++i) {
      CollisionData result = updateCollisionData(i);
      
      if(result.time < soonest.time) {
        soonest = result;
      }
    }
    
    addToQueue(soonest);
  };
  
  void computeFutureCollision() {
    
    if(queue.size() == 0) {
      System.err.println("Error: Collision queue is empty!!");
      return;
    }
    
    if(queue.size() > MaxCollisionBufferSize) {
      return;
    }
    
    CollisionData c_last = queue.getLast();
    
    CollisionData c_next = updateCollisionData(c_last.index[0]);
    if(c_last.index[0] != c_last.index[1]) {
      
      CollisionData c_test = updateCollisionData(c_last.index[1]);
      if(c_test.time < c_next.time)
        c_next = c_test;
    }
    
    for(int i=0; i < P.nv; ++i) {
      if(i == c_last.index[0] || i == c_last.index[1])
        continue; // We've already found the soonest collisions for these balls
        
      for(int j=i; j < P.nv; ++j) {
        CollisionData c_test = data[i][j];
        if(c_test.time < c_next.time)
          c_next = c_test;
      }
    }
    
    addToQueue(c_next);
  }
  
  void addToQueue(CollisionData c) {
     //<>//
    if(c.index[0] == c.index[1]) { // This indicates a ball-to-wall collision
      int i = c.index[0];
      vec p0 = finalState[i].p;
      vec v0 = finalState[i].v;
      float t0 = finalState[i].time;
      
      vec p = new vec(v0);
      p.mul(c.time - t0);
      p.add(p0);
      
      vec v = new vec(v0);
      int axis = wallAxis[c.wall];
      v.setComponent(axis, -v0.getComponent(axis));
      
      c.pc[0] = p;
      c.pc[1] = p;
      c.vc[0] = v;
      c.vc[1] = v;
      
      //System.out.print("Prior velocity: "+toText(finalState[i].v));
      finalState[i].p = new vec(p);
      finalState[i].v = new vec(v);
      finalState[i].time = c.time;
      //System.out.print(" | After velocity : "+toText(finalState[i].v));
      //System.out.println(" | Time: "+finalState[i].time);
      
    } else {
      
      for(int index=0; index < 2; ++index) {
        int i = c.index[index];
        vec p0 = finalState[i].p;
        vec v0 = finalState[i].v;
        float t0 = finalState[i].time;
        
        vec p = new vec(v0);
        p.mul(c.time - t0);
        p.add(p0);
        
        c.pc[index] = p;
      }
      
      vec v1 = new vec(finalState[c.index[0]].v);
      vec v2 = new vec(finalState[c.index[1]].v);
      
      vec n = new vec(c.pc[0]);
      n.sub(c.pc[1]);
      n.normalize();
      
      float v1n_scalar = dot(v1, n);
      float v2n_scalar = dot(v2, n);
      
      vec v1n = new vec(n);
      v1n.mul(v1n_scalar);
      v1.sub(v1n);
      
      vec v2n = new vec(n);
      v2n.mul(v2n_scalar);
      v2.sub(v2n);
      
      v1.add(v2n);
      v2.add(v1n);
      
      c.vc[0] = new vec(v1);
      c.vc[1] = new vec(v2);
      
      finalState[c.index[0]].p = new vec(c.pc[0]);
      finalState[c.index[0]].v = new vec(v1);
      finalState[c.index[0]].time = c.time;
      
      finalState[c.index[1]].p = new vec(c.pc[1]);
      finalState[c.index[1]].v = new vec(v2);
      finalState[c.index[1]].time = c.time;
    }
    
    if( !(c.time < Float.POSITIVE_INFINITY) ) {
      System.err.println("The predictor believes there will never be another collision!");
    }
    
    queue.addLast(c);
  }
}