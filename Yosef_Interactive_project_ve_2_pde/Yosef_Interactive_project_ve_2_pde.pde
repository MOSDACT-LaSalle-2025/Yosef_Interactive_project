int cols = 14;
int rows = 14;
int cellSize = 90;

Drawer[] drawers = new Drawer[5];
color[] colors = new color[5];
RowMotion[] xMotion = new RowMotion[rows];
RowMotion[] yMotion = new RowMotion[cols];

float xGlobalOffset = 0;
float yGlobalOffset = 0;
float xDirection = 0;
float yDirection = 0;
float speedFactor = 1.0;
float controlSpeed = 2.5;

// גל ורוד גדול
float waveX = -300;
float waveAlpha = 255;
boolean waveActive = false;

void settings() {
  size(cols * cellSize, rows * cellSize);
}

void setup() {
  rectMode(CENTER);
  initColors();
  initDrawers();
  initMotionArrays();
  textSize(20);
  fill(255);
}

void draw() {
  background(8, 7, 8);

  xGlobalOffset += xDirection * controlSpeed;
  yGlobalOffset += yDirection * controlSpeed;

  drawHorizontalLayer();

  blendMode(DIFFERENCE);
  drawVerticalLayer();
  blendMode(BLEND);

  // הצגת מהירות על המסך
  fill(255);
  text("Speed Factor: " + nf(speedFactor, 1, 2), 10, height - 20);

  // שכבת ציור נוספת — גל ורוד גדול
  drawCustomLayer();
}

void keyPressed() {
  if (keyCode == RIGHT) xDirection = 1;
  if (keyCode == LEFT)  xDirection = -1;
  if (keyCode == UP)    yDirection = -1;
  if (keyCode == DOWN)  yDirection = 1;

  if (key == 's' || key == 'S') {
    speedFactor *= 1.1;
    println("Speed Factor increased to: " + nf(speedFactor, 1, 2));
  }
  if (key == 'a' || key == 'A') {
    speedFactor *= 0.9;
    println("Speed Factor decreased to: " + nf(speedFactor, 1, 2));
  }

  if (key == 'g' || key == 'G') {
    waveActive = true;
    waveX = -300;
    waveAlpha = 255;
    println("Pink wave activated");
  }
}

void drawCustomLayer() {
  if (!waveActive) return;

  pushStyle();
  stroke(255, 105, 180, waveAlpha); // ורוד עם שקיפות
  strokeWeight(4);
  noFill();
  beginShape();
  for (float x = 0; x <= 300; x += 5) {
    float y = height / 2 + 100 * sin(x * 0.05);
    vertex(waveX + x, y);
  }
  endShape();
  popStyle();

  waveX += 4;
  waveAlpha -= 2;

  if (waveX > width || waveAlpha <= 0) {
    waveActive = false;
  }
}

interface Drawer {
  void draw(float cx, float cy, float s, color c);
}

class RowMotion {
  float offset;
  float speed;

  RowMotion(float speed, boolean vertical) {
    this.speed = speed;
    this.offset = vertical ? random(height) : 0;
  }

  void update(boolean vertical) {
    if (vertical) {
      offset -= speed * speedFactor;
      if (offset < 0) offset += cellSize;
    } else {
      offset += speed * speedFactor;
      if (offset > cellSize) offset -= cellSize;
    }
  }

  float getOffset() {
    return offset;
  }
}

void initColors() {
  colors[0] = color(230, 232, 230);
  colors[1] = color(55, 114, 255);
  colors[2] = color(223, 41, 53);
  colors[3] = color(253, 202, 64);
  colors[4] = color(80, 202, 38);
}

void initMotionArrays() {
  for (int i = 0; i < rows; i++) {
    xMotion[i] = new RowMotion(0.5 + random(0.5), false);
  }
  for (int i = 0; i < cols; i++) {
    yMotion[i] = new RowMotion(0.3 + random(0.4), true);
  }
}

void drawHorizontalLayer() {
  for (int y = 0; y < rows; y++) {
    int type = y % drawers.length;
    color c = colors[type];
    xMotion[y].update(false);

    for (int x = 0; x <= cols; x++) {
      float cx = ((x * cellSize + xMotion[y].getOffset() + xGlobalOffset) % (cols * cellSize) + cols * cellSize) % (cols * cellSize);
      float cy = y * cellSize + cellSize * 0.5;
      drawers[type].draw(cx, cy, cellSize, c);
    }
  }
}

void drawVerticalLayer() {
  for (int x = 0; x < cols; x++) {
    int type = x % drawers.length;
    color c = colors[type];
    yMotion[x].update(true);

    for (int i = 0; i <= rows + 2; i++) {
      float cy = ((height + yMotion[x].getOffset() - i * cellSize + yGlobalOffset) % (rows * cellSize) + rows * cellSize) % (rows * cellSize);
      float cx = x * cellSize + cellSize * 0.5;
      drawers[type].draw(cx, cy, cellSize, c);
    }
  }
}

void initDrawers() {
  drawers[0] = (cx, cy, s, c) -> {
    pushStyle();
    stroke(c);
    strokeWeight(5);
    float gap = s / 4;
    for (int i = -1; i <= 1; i++) {
      line(cx + i * gap, cy - s/2, cx + i * gap, cy + s/2);
    }
    popStyle();
  };

  drawers[1] = (cx, cy, s, c) -> {
    pushStyle();
    noFill();
    stroke(c);
    strokeWeight(4);
    ellipse(cx, cy, s, s);
    popStyle();
  };

  drawers[2] = (cx, cy, s, c) -> {
    pushStyle();
    noFill();
    stroke(c);
    strokeWeight(3);
    line(cx - s/2, cy - s/2, cx + s/2, cy + s/2);
    line(cx + s/2, cy - s/2, cx - s/2, cy + s/2);
    popStyle();
  };

  drawers[3] = (cx, cy, s, c) -> {
    pushStyle();
    noStroke();
    fill(c);
    ellipse(cx, cy, s, s);
    popStyle();
  };

  drawers[4] = (cx, cy, s, c) -> {
    pushStyle();
    noFill();
    stroke(c);
    strokeWeight(4);
    rect(cx, cy, s, s);
    popStyle();
  };
}
