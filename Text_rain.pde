ArrayList<TextDrop> drops = new ArrayList<TextDrop>();
ArrayList<Explosion> explosions = new ArrayList<Explosion>(); // List to store active explosions
String[] lines;
String[] sentences; // Sentences from the text
String[] words;     // Words from the text
char[] letters;     // Letters from the text
PFont font;
int mode = 0;       // 0: Sentence, 1: Word, 2: Letter
boolean collisionEnabled = false; // Collision detection toggle
boolean explosionEnabled = false; // Explosion effect toggle
int numDrops;       // Number of text instances
int maxDrops = 200; // Maximum number of drops allowed
int minDrops = 1;   // Minimum number of drops allowed

// |Explosion animation variables|
PImage[] explosionSheets = new PImage[5]; // Array to hold multiple explosion sprite sheets
int[] numExplosionFrames = {64, 64, 64, 64, 12}; // Number of frames in each explosion animation
boolean[] isGrid = {true, true, true, true, false}; // Whether each explosion sprite sheet is in grid format
int explosionType = 0; // Current explosion type (0-5)

// |Preloaded frames|
ArrayList<PImage[]> explosionFrames = new ArrayList<PImage[]>(); // Stores frames for each explosion type

void setup() {
  size(1600, 900, P2D);
  background(0);
  
  // Load a custom font (optional)
  font = createFont("Arial", 16);
  textFont(font);
  
  // Load the text from the local file
  lines = loadStrings("text.txt");
  
  // Combine all lines into a single string
  String text = join(lines, " ");
  
  // Parse the text into sentences, words, and letters
  sentences = splitTokens(text, ".!?");
  words = splitTokens(text, " \n\r\t");
  letters = text.toCharArray();
  
  // Load and preprocess explosion sprite sheets
  for (int i = 0; i < explosionSheets.length; i++) {
    explosionSheets[i] = loadImage("explosion " + (i+1) + ".png");
    PImage[] frames = extractFrames(explosionSheets[i], numExplosionFrames[i], isGrid[i]);
    explosionFrames.add(frames);
  }
  
  // Set initial number of drops based on mode
  setNumDropsByMode();
  initializeDrops();
}

void draw() {
  // Create a fading trail effect
  fill(0, 50);
  rect(0, 0, width, height);
  
  for (TextDrop drop : drops) {
    drop.update();
  }
  
  // Handle collisions if enabled
  if (collisionEnabled) {
    handleCollisions();
  }
  
  for (TextDrop drop : drops) {
    drop.display();
  }
  
  // Update and display explosions
  for (int i = explosions.size() - 1; i >= 0; i--) {
    Explosion explosion = explosions.get(i);
    explosion.update();
    explosion.display();
    if (explosion.isFinished()) {
      explosions.remove(i);
    }
  }
  
  // Display current mode, collision status, and number of drops
  displayStatus();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    mode = (mode + 1) % 3; // Cycle through modes 0, 1, 2
    setNumDropsByMode();
    initializeDrops();
  } else if (mouseButton == RIGHT) {
    collisionEnabled = !collisionEnabled; // Toggle collision detection
  }
}

void keyPressed() {
  if (key == ' ') {
    explosionEnabled = !explosionEnabled; // Toggle explosion effect
  } else if (key == 'e' || key == 'E') {
    explosionType = (explosionType + 1) % 6; // Cycle through explosion types
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  adjustNumDrops((int)e);
}

void adjustNumDrops(int change) {
  numDrops -= change; // Adjust the number of drops
  numDrops = constrain(numDrops, minDrops, maxDrops);
  
  // Adjust the drops list
  if (drops.size() < numDrops) {
    // Add new drops
    int dropsToAdd = numDrops - drops.size();
    for (int i = 0; i < dropsToAdd; i++) {
      String content = getRandomContent();
      drops.add(new TextDrop(content));
    }
  } else if (drops.size() > numDrops) {
    // Remove excess drops
    int dropsToRemove = drops.size() - numDrops;
    for (int i = 0; i < dropsToRemove; i++) {
      drops.remove(drops.size() - 1); // Remove from the end
    }
  }
}

void setNumDropsByMode() {
  switch (mode) {
    case 0:
      numDrops = 20; // Fewer drops for sentences
      break;
    case 1:
      numDrops = 50;
      break;
    case 2:
      numDrops = 100; // More drops for letters
      break;
    default:
      numDrops = 50;
  }
  numDrops = constrain(numDrops, minDrops, maxDrops);
}

void initializeDrops() {
  drops.clear();
  for (int i = 0; i < numDrops; i++) {
    String content = getRandomContent();
    drops.add(new TextDrop(content));
  }
}

String getRandomContent() {
  String content = "";
  switch (mode) {
    case 0: // Sentence Mode
      content = trim(sentences[int(random(sentences.length))]) + ".";
      break;
    case 1: // Word Mode
      content = words[int(random(words.length))];
      break;
    case 2: // Letter Mode
      content = str(letters[int(random(letters.length))]);
      break;
  }
  return content;
}

void handleCollisions() {
  for (int i = 0; i < drops.size(); i++) {
    TextDrop dropA = drops.get(i);
    for (int j = i + 1; j < drops.size(); j++) {
      TextDrop dropB = drops.get(j);
      if (dropA.checkCollision(dropB)) {
        if (explosionEnabled) {
          // Calculate collision point
          float collisionX = (dropA.x + dropB.x) / 2;
          float collisionY = (dropA.y + dropB.y) / 2;
          int eType = explosionType;
          if (explosionType == 5) { // Random explosion
            eType = int(random(5));
          }
          explosions.add(new Explosion(collisionX, collisionY, eType));
        }
        dropA.resolveCollision(dropB);
      }
    }
  }
}

void displayStatus() {
  fill(255);
  textSize(16);
  textAlign(CENTER);
  String modeText = "";
  switch (mode) {
    case 0:
      modeText = "Sentence Mode";
      break;
    case 1:
      modeText = "Word Mode";
      break;
    case 2:
      modeText = "Letter Mode";
      break;
  }
  String collisionText = collisionEnabled ? "Collision: ON" : "Collision: OFF";
  String explosionText = explosionEnabled ? "Explosion: ON" : "Explosion: OFF";
  String explosionTypeText = "";
  if (explosionEnabled) {
    if (explosionType == 5) {
      explosionTypeText = "Type: Random";
    } else {
      explosionTypeText = "Type: " + (explosionType + 1);
    }
  }
  text(modeText + " | " + collisionText + " | " + explosionText + " " + explosionTypeText + " | Drops: " + numDrops, width / 2, 20);
}

// |Helper function to extract frames from sprite sheets|
PImage[] extractFrames(PImage spriteSheet, int totalFrames, boolean gridFormat) {
  PImage[] frames = new PImage[totalFrames];
  if (gridFormat) {
    // |Grid properties|
    int columns = 8;
    int rows = 8;
    int frameWidth = spriteSheet.width / columns;
    int frameHeight = spriteSheet.height / rows;
    int frameIndex = 0;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (frameIndex < totalFrames) {
          frames[frameIndex] = spriteSheet.get(col * frameWidth, row * frameHeight, frameWidth, frameHeight);
          frameIndex++;
        }
      }
    }
  } else {
    // |Horizontal sprite sheet|
    int frameWidth = spriteSheet.width / totalFrames;
    int frameHeight = spriteSheet.height;
    for (int i = 0; i < totalFrames; i++) {
      frames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, frameHeight);
    }
  }
  return frames;
}
