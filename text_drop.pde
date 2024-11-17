class TextDrop {
  
  // |Position properties|
  
  float x; // Position
  float y;  // Position
  float speedY;
  float speedX;
  
  // |Content properties|
  
  String content; // Text content
  float contentWidth;
  float contentHeight;
  
  // |Spin properties|
  
  boolean spin;        // Whether the text should be spinning
  float angle;         // Current rotation angle
  float rotationSpeed; // Positive for clockwise, negative for counter clockwise.
  
  // |Text properties|
  
  float textSize;      
  color currentColor;  
  int colorChangeTimer; // Timer for color change effect
  
  TextDrop(String c) {
    
    // |Content properties| 
    
    content = c; // Check main tab for more info on how content is randomized (Also basically defining what is the content of the text)
    contentWidth = textWidth(content);
    contentHeight = textAscent() + textDescent();  // Basically (Text_top - Text_baseline) + (Text_baseline - Text Bottom)
    
    // |Randomize all properties|
    
      // |Text properties|
      
      textSize = random(16, 26);
      textFont(font, textSize); 
    
      // |Position properties|
    
      x = random(width - contentWidth); // Assure entire text starts within the screen
      y = random(-500, -50); // Spawn on top of the screen to simulate small random delay in appearance
      speedY = random(1, 3);  // Fall speed
      speedX = random(-1, 1); // Wind effect
    
      // |Spin properties|
    
      spin = random(1) < 0.2; // 20% chance to spin
      angle = 0;
      rotationSpeed = random(-0.02, 0.02);
    
      // |Color properties|
      
      currentColor = color(0, 255, 0); // Initial color is green
      colorChangeTimer = 0;
    
  }
  
  void update() {
    
    // |Position|
    
    y += speedY;
    x += speedX;
    
    // |Keep the text within the horizontal bounds|
    
    if (x < -contentWidth) {
      x = width;
    } else if (x > width) {
      x = -contentWidth;
    }
    
    // |Spin update|
    
    if (spin) {
      angle += rotationSpeed;
    }
    
    // |Color change chance update (color lootbox)|

    if (colorChangeTimer == 0 && random(1) < 0.01) { // 1% chance each frame
      currentColor = color(random(255), random(255), random(255));
      colorChangeTimer = int(random(10, 30)); // Color change lasts for 10-30 frames at random
    } else if (colorChangeTimer > 0) {
      colorChangeTimer--;
      if (colorChangeTimer == 0) {
        currentColor = color(0, 255, 0); // Revert back to green
      }
    }
    
    // |Respawn when hit bottom|
    
    if (y > height) {
      reset();
    }
    
  }
  
  void display() {
    
    // |Save coordinates|
    
    pushMatrix();
    
    // |Move text down/left/right|
    
    translate(x + contentWidth / 2, y + contentHeight / 2);
    
    // |Rotate text|
    
    if (spin) {
      rotate(angle);
    }
    
    // |Text settings|
    
    fill(currentColor);
    textAlign(CENTER, CENTER);
    textFont(font, textSize);
    text(content, 0, 0);
    
    // |Load saved coordinates|
    
    popMatrix();
    
  }
  
  void reset() { // Check constructor code for further comment explanations
    
    // |Position properties|
    
    y = random(-500, -50); 
    x = random(width - contentWidth);
    speedY = random(1, 3);
    speedX = random(-1, 1);
    
    // |Content properties|
    
    content = getRandomContent();  // Each spawn, a new random content is selected from the total text
    contentWidth = textWidth(content);
    contentHeight = textAscent() + textDescent(); 
    
    // |Text properties|
    
    textSize = random(16, 26);
    textFont(font, textSize);
    
    // |Spin properties|
   
    spin = random(1) < 0.2; // Again 20% chance to respawn spinning
    angle = 0;
    rotationSpeed = random(-0.02, 0.02);
    
    // |Color properties|
    
    currentColor = color(0, 255, 0); // Also respawns green
    colorChangeTimer = 0;
    
  }
  
  boolean checkCollision(TextDrop other) {
    
    // |Collision box coordinates for this text|
    
    float thisLeft = x;
    float thisRight = x + contentWidth;
    float thisTop = y;
    float thisBottom = y + contentHeight;
    
    // |Collision box coordinates for any other text|
    
    float otherLeft = other.x;
    float otherRight = other.x + other.contentWidth;
    float otherTop = other.y;
    float otherBottom = other.y + other.contentHeight;
    
    // |Overlap check|
    
    return !(thisRight < otherLeft || thisLeft > otherRight || thisBottom < otherTop || thisTop > otherBottom); // Basically checking if part of a collision box is inside another one (Not perfectly functional for rotating texts, but in general works well without being overly complex)
    
  }
  
  void resolveCollision(TextDrop other) { 
    
    // |Simple collision calculation: just exchanging speeds|    (The technical physics term would actually be velocities but I think speed suffices for the understanding given the variable names I had already landed upon)
    
      // |Temporary speeds|
      
      float tempSpeedX = speedX;
      float tempSpeedY = speedY;
      
      // |Gain other text speed|
    
      speedX = other.speedX;
      speedY = other.speedY;
    
      // |Give this previous text speed|
      
      other.speedX = tempSpeedX;
      other.speedY = tempSpeedY;
    
    // |Anti-sticking measure|
    
    while (checkCollision(other)) { // Basically whenever the texts collide push them away from each other until they are completely away before resuming program so they don't get stuck inside each other
      x += speedX;
      y += speedY;
      other.x += other.speedX;
      other.y += other.speedY;
    }
    
  }
}
