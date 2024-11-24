class Explosion {
  
  // |Position properties|
  
  float x; // X-coordinate
  float y; // Y-coordinate
  
  // |Animation properties|
  
  PImage[] frames; // Array of preloaded frames
  int currentFrame;
  int totalFrames;
  int frameDelay;
  int frameCounter;
  
  Explosion(float x, float y, int type) {
    
    // |Position properties|
    
    this.x = x;
    this.y = y;
    
    // |Animation properties|
    
    frames = explosionFrames.get(type);
    totalFrames = frames.length;
    currentFrame = 0;
    frameDelay = 2; // Adjust for animation speed
    frameCounter = 0;
    
  }
  
  void update() {
    
    frameCounter++;
    if (frameCounter >= frameDelay) {
      currentFrame++;
      frameCounter = 0;
    }
    
  }
  
  void display() {
    
    if (currentFrame < totalFrames) {
      PImage frame = frames[currentFrame];
      imageMode(CENTER);
      image(frame, x, y);
    }
    
  }
  
  boolean isFinished() {
    
    return currentFrame >= totalFrames;
    
  }
}
