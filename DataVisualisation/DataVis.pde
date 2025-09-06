//variables for map and population data
PImage mapImage;
Table cityData;

//visual setting variables
int currentYear = 1991; //default year
float zoom = 0.3; //inital zoom level
float offsetX = 0; //initial horizontal pan
float offsetY = 0; //initial vertical pan
int minPopulation = 0; //filter threshold
int filterStep = 50000; //change step size for filtering
boolean showLabels = false; //booleanfor showing city labels
void setup() {
  size(700, 800, P3D); //size of screen on 3D canvas
  mapImage = loadImage("uk-admin.jpg"); //loading the map
  cityData = loadTable("Data.csv", "header"); //loading the data
  imageMode(CORNER); //top left corner is the oragin
}

void draw() {
  background(200); //light grey for back ground
  translate(width / 2 + offsetX, height / 2 + offsetY, -200); //centered map with offsets
  scale(zoom); //value for the zooming
  rotateX(PI / 3); //tilt view towards the camera
  scale(1, -1, 1); //flip Y axis
  //draw the map as a textured rectangle
  pushMatrix();
  translate(-mapImage.width / 2, -mapImage.height / 2, -1);//center the map
  beginShape();
  texture(mapImage); //sets texture as the map
  //set vertices
  vertex(0, 0, 0, 0, mapImage.height);
  vertex(mapImage.width, 0, 0, mapImage.width, mapImage.height);
  vertex(mapImage.width, mapImage.height, 0, mapImage.width, 0);
  vertex(0, mapImage.height, 0, 0, 0);
  endShape();
  popMatrix();

  //draw bars for each city
  for (TableRow row : cityData.rows()) {
    String city = row.getString("City");
    float x = row.getFloat("X") - mapImage.width / 2;
    float y = (mapImage.height - row.getFloat("Y")) - mapImage.height / 2;
    //gets the population based on the specific year
    int pop = 0;
    if (currentYear == 1991 && row.getString("1991") != null)
      pop = int(row.getString("1991").replace(",", ""));
    else if (currentYear == 2001 && row.getString("2001") != null)
      pop = int(row.getString("2001").replace(",", ""));
    else if (currentYear == 2011 && row.getString("2011") != null)
      pop = int(row.getString("2011").replace(",", ""));

    //skip if no population
    if (pop == 0 || pop < minPopulation) continue;

    //converting population to the bar heights 
    float h = map(pop, 0, 8500000, 10, 500); //range of 10 to 500


    pushMatrix();
    translate(x, y, h / 2); //lifting the bar above the map
    //colours based on population size
    if (pop > 1000000) fill(255, 0, 0);         //big cities are red
    else if (pop > 500000) fill(255, 150, 0);   //mid cities are orange
    else fill(0, 180, 255);                    //small cities are blue    
    noStroke();
    box(10, 10, h); //box dimensions
    popMatrix();
    
    //city labels
    if (showLabels) {
      pushMatrix();
      translate(x, y, h + 15); //position label above bar
      rotateX(-PI/2);        
      fill(0);
      textSize(12);
      textAlign(CENTER);
      text(city, 0, 0);
      popMatrix();
    }
  }


  //reset to default camera for UI
  camera();
  hint(DISABLE_DEPTH_TEST); //so text isnt hidden behind 3d
  textAlign(LEFT);
  fill(0);
  textSize(14);
  text("Year: " + currentYear + " (press 1/2/3 to switch)", 10, 20);
  text("Drag or use Arrow keys to pan, scroll to zoom, double click to reset camera", 10, 40);
  text("Filtering cities with population greater than or equal to: " + minPopulation, 10, 60);
  text("Press [ or ] to change filter", 10, 80);
  text("Press 'C' to toggle labels", 10, 100);
  hint(ENABLE_DEPTH_TEST); //enable depth for next frame
}

void keyPressed() {
  //switch between years
  if (key == '1') currentYear = 1991;
  if (key == '2') currentYear = 2001;
  if (key == '3') currentYear = 2011;

  //panning with arrow keys
  int panAmount = 20;

  if (keyCode == LEFT)  offsetX += panAmount;
  if (keyCode == RIGHT) offsetX -= panAmount;
  if (keyCode == UP)    offsetY += panAmount;
  if (keyCode == DOWN)  offsetY -= panAmount;
  
   //adjust population filter
  if (key == ']') minPopulation += filterStep;
  if (key == '[') minPopulation = max(0, minPopulation - filterStep);
  
  //city labels
  if (key == 'c') showLabels = !showLabels;
}

//pan with mouse drag
void mouseDragged() {
  offsetX += (mouseX - pmouseX);
  offsetY += (mouseY - pmouseY);
}

//zoom with mouse scroll
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoom -= e * 0.05;
  zoom = constrain(zoom, 0.3, 3.0);
}
//snap view double click
void mousePressed(MouseEvent event) {
  //check for double click to reset view
  if (event.getCount() == 2) {
    offsetX = 0;
    offsetY = 0;
    zoom = 0.3;
  } 
}
