ArrayList<TextDrop> drops = new ArrayList<TextDrop>();
String[] lines;
String[] sentences; // Sentences from the text
String[] words;     // Words from the text
char[] letters;     // Letters from the text
PFont font;
int mode = 0;       // 0: Sentence, 1: Word, 2: Letter
boolean collisionEnabled = false; // Collision detection toggle
int numDrops;       // Number of text instances
int maxDrops = 200; // Maximum number of drops allowed
int minDrops = 1;  // Minimum number of drops allowed

void setup() {
  size(600, 400);
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

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  adjustNumDrops((int)e);
}

void adjustNumDrops(int change) {
  numDrops -= change; // Change by 5 drops per scroll notch
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
  text(modeText + " | " + collisionText + " | Drops: " + numDrops, width / 2, 20);
}

