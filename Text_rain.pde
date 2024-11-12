ArrayList<TextDrop> drops = new ArrayList<TextDrop>();
String[] lines;
String[] sentences; // Sentences from the text
String[] words;     // Words from the text
char[] letters;     // Letters from the text
PFont font;
int mode = 0;       // 0: Sentence, 1: Word, 2: Letter
boolean collisionEnabled = false; // Collision detection toggle

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
  
  // Display current mode and collision status
  displayStatus();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    mode = (mode + 1) % 3; // Cycle through modes 0, 1, 2
    initializeDrops();
  } else if (mouseButton == RIGHT) {
    collisionEnabled = !collisionEnabled; // Toggle collision detection
  }
}

void initializeDrops() {
  drops.clear();
  
  int numDrops;
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
  
  for (int i = 0; i < numDrops; i++) {
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
    drops.add(new TextDrop(content));
  }
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
  text(modeText + " | " + collisionText, width / 2, 20);
}
