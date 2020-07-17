
// https://github.com/sympou/physarum

PShader updateParticlesPosShader;
PShader updateParticlesAngShader;
PShader updatePheromonesShader;
PShader addParticlesShader;
PShader seePheromonesShader;

PGraphics dataX, dataY, dataAng;// size = dataSize*dataSize
PGraphics pheromones;// size = width*height

PShape particlesShape;

// variables
int dataSize = 100; //dataSize*dataSize = number of particules

float speed = 2.0;
float rotAngle = 0.2;
float foresee = 4.0;
float particleFov = 0.1; //a new variable !

float pheroDecay   = 0.99;
float pheroDropped = 0.05;
float particleSize = 2.0;

void setup() {
  // fullScreen(P2D);
  size(1000, 500, P2D);
  noSmooth();

  // pheromones
  pheromones = createGraphics(width, height, P2D);
  pheromones.noSmooth();

  // particules, in a PShape object 
  particlesShape = createShape();
  particlesShape.beginShape(QUADS);
  particlesShape.noStroke();
  for (int n = 0; n < dataSize*dataSize; n ++) {
    particlesShape.vertex(-0.5, -0.5, n);
    particlesShape.vertex(-0.5,  0.5, n);
    particlesShape.vertex( 0.5,  0.5, n);
    particlesShape.vertex( 0.5, -0.5, n);
  }
  particlesShape.endShape();

  // shaders
  addParticlesShader = loadShader("addParticlesF.glsl", "addParticlesV.glsl");
  addParticlesShader.set("dataSize", float(dataSize));
  addParticlesShader.set("pheroDropped", pheroDropped);
  addParticlesShader.set("particleSize", particleSize);

  addParticlesShader = loadShader("addParticlesF.glsl", "addParticlesV.glsl");
  addParticlesShader.set("dataSize", float(dataSize));
  addParticlesShader.set("pheroDropped", pheroDropped);
  addParticlesShader.set("particleSize", particleSize);

  updateParticlesPosShader = loadShader("updateParticlesPosF.glsl");
  updateParticlesPosShader.set("pheroRes", float(width), float(height));
  updateParticlesPosShader.set("speed", speed);

  updateParticlesAngShader = loadShader("updateParticlesAngF.glsl");
  updateParticlesAngShader.set("pheroRes", float(width), float(height));
  updateParticlesAngShader.set("foresee", foresee);
  updateParticlesAngShader.set("particleFov", particleFov);
  updateParticlesAngShader.set("rotAngle", rotAngle);

  updatePheromonesShader = loadShader("updatePheromonesF.glsl");
  updatePheromonesShader.set("pheroDecay", pheroDecay);

  seePheromonesShader = loadShader("seePheromonesF.glsl");

  initData();
}

void initData() {
  // coords + angles in 3 PGraphics objects
  dataX   = randomGr(dataSize, dataSize);
  dataY   = randomGr(dataSize, dataSize);
  dataAng = randomGr(dataSize, dataSize);
}

PGraphics randomGr(int w, int h) {
  PGraphics data = createGraphics(w, h, P2D);
  data.beginDraw();
  data.noSmooth();
  data.image(randomBuffer(dataSize, dataSize), 0, 0);
  data.endDraw(); 
  return data;
}

PImage randomBuffer(int w, int h) {
  PImage bufferImg = createImage(w, h, RGB);
  bufferImg.loadPixels();
  for (int i = 0; i < bufferImg.pixels.length; i++) bufferImg.pixels[i] = color(random(255), random(255), random(255));
  bufferImg.updatePixels(); 
  return  bufferImg;
}

void randomizeParameters() {
  foresee = random(random(random(0, 100)));
  rotAngle = random(random(0.0, 1.0));
  speed = random(0.0, 5.0);
  particleFov = random(-0.25, 0.25);

  updateParticlesAngShader.set("foresee", foresee);
  updateParticlesAngShader.set("rotAngle", rotAngle);
  updateParticlesPosShader.set("speed", speed);
  updateParticlesAngShader.set("particleFov", particleFov);
}

void applyShader(PGraphics data, PShader shader) {
  data.beginDraw();
  data.shader(shader);
  data.noStroke();
  data.rect(0, 0, data.width, data.height);
  data.endDraw();
}

void draw() {

  // auto-randomize
  if (frameCount%100==0) randomizeParameters();

  // update shader vars
  updateParticlesAngShader.set("dataX", dataX);
  updateParticlesAngShader.set("dataY", dataY);
  updateParticlesAngShader.set("pheromones", pheromones);

  // update angles
  applyShader(dataAng, updateParticlesAngShader);
  updateParticlesPosShader.set("dataAng", dataAng);

  // update positions
  updateParticlesPosShader.set("mode", float(0));
  applyShader(dataX, updateParticlesPosShader);
  updateParticlesPosShader.set("mode", float(1));
  applyShader(dataY, updateParticlesPosShader);

  //draw cursor if clicked
  if (mousePressed) {
    if (mouseButton == LEFT) pheromones.fill(255);
    else                     pheromones.fill(0);
    pheromones.beginDraw();
    pheromones.resetShader();
    pheromones.noStroke();
    pheromones.ellipse(mouseX, mouseY, 50, 50); 
    pheromones.endDraw();
  }

  // write particules in the pheromones image
  addParticlesShader.set("pheroDropped", pheroDropped);
  addParticlesShader.set("dataX", dataX);
  addParticlesShader.set("dataY", dataY);
  pheromones.beginDraw();
  pheromones.shader(addParticlesShader);
  pheromones.noStroke();
  pheromones.shape(particlesShape, 0, 0);
  pheromones.endDraw();

  applyShader(pheromones, updatePheromonesShader);

  shader(seePheromonesShader);
  image(pheromones, 0, 0, width, height);
  shape(particlesShape, 0, 0);
}
