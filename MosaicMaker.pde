JSONObject data;
ArrayList<String> keys;
ArrayList<PImage> images = new ArrayList<PImage>();
int imageSize = 50;
int selectedImage = 3;
int[][] avgColors;
PImage[] smallPics;
//int[] gridNums={1,2,4,5,8,10,16,20,25,32,40,50,64,80,100};
int[] gridNums={4,5,8,10,16,20,25,40,50,80,100};
int gridSize=0;
PImage showImage; // Current Image being displayed
int imageX; // X axis position of the image in carousel
int imageY; // Y axis position of the image in carousel
int[] distance;
boolean picMode = true;

void setup() {
  size(1000,500);
  background(255);
  data = loadJSONObject("output.json"); // JSON file from Flickr API
  keys = new ArrayList(data.keys()); 
  
  //load images
  for (int i = 0; i < keys.size(); i++) {
    PImage img = loadImage(keys.get(i) + ".jpg");
    images.add(img); // Adds the image to the images ArrayList
  }
  findAvg();
}
void draw() {
  displayBar();
  breakRegions(gridSize);
}

void displayBar() {
 imageY = height/2;
 
 //Images to the left of the center pic
 imageX = imageSize/2;
 for (int i = selectedImage - 3; i < selectedImage; i++) {  
 showImage = images.get(i); // Gets the image from the JSON file
 imageMode(CORNER);
 image(showImage,imageX,imageY,imageSize,imageSize); // Display the image from the current JSON Object
 imageX += width/10;
 }
 //Larger center image
 imageX = 5*width/10;
 showImage = images.get(selectedImage);
 imageMode(CENTER);
 image(showImage,imageX,imageY,400,400);
 
 //Images to the right of the center pic
 imageX = 7*width/10+imageSize/2;
 for (int i = selectedImage+1; i < selectedImage+4; i++) { 
 showImage = images.get(i);
 imageMode(CORNER);
 image(showImage,imageX,imageY,imageSize,imageSize); // Display the image from the current JSON Object
 imageX += width/10;
 }
}

void keyPressed() {
 if (keyCode == RIGHT) {
   selectedImage++;
 }
 if (keyCode == LEFT && selectedImage > 3) {
   selectedImage--;
 }
 if (keyCode == UP && gridSize < 10) {
   gridSize++;
 }
 if (keyCode == DOWN && gridSize > 0) {
   gridSize--;
 }
 if (keyCode == SHIFT) {
   picMode = !picMode;
 }
}


int[] findAvg2(PImage image) {
  int red = 0;
  int blue = 0;
  int green = 0;
  for (int i = 0; i < image.pixels.length; i++) {
    red += red(image.pixels[i]);
    blue += blue(image.pixels[i]);
    green += green(image.pixels[i]);
  }
  red = red/image.pixels.length;
  blue = blue/image.pixels.length; 
  green = green/image.pixels.length;
  int[] rgb = {red,green,blue};
  return rgb;
}

void findAvg() {
  avgColors = new int[images.size()][3];
  int num = 0;
  for (PImage image : images) {
    int red = 0;
    int blue = 0;
    int green = 0;
    for (int i = 0; i < image.pixels.length; i++) {
      red += red(image.pixels[i]);
      blue += blue(image.pixels[i]);
      green += green(image.pixels[i]);
    }
    red = red/image.pixels.length;
    blue = blue/image.pixels.length; 
    green = green/image.pixels.length;
    avgColors[num][0] = red;
    avgColors[num][1] = green;
    avgColors[num][2] = blue;
    num++;
  }
}

int findSize() {
  int num = 0;
  for (PImage img : smallPics) {
    if (img != null) {
      num++;
    }
  }
  return num;
}

void breakRegions(int gridSize) {
  PImage bigImage = get( 5*width/10-200,height/2-200,400,400);
  smallPics = new PImage[160000/gridNums[gridSize]];
  //image(bigImage,5*width/10-200,height/2-200);
  
  int num=0;
  for (int x = 0; x < bigImage.width; x+=gridNums[gridSize]) {
    for (int y = 0; y < bigImage.height; y+=gridNums[gridSize]) {
      smallPics[num] = bigImage.get(x,y,gridNums[gridSize],gridNums[gridSize]);
      int[] avgRGB = findAvg2(smallPics[num]);
      if (picMode) {
        image(findPic(avgRGB),(5*width/10-200)+x,(height/2-200)+y,gridNums[gridSize],gridNums[gridSize]);
      }
      else {
        noStroke();
        fill(avgRGB[0],avgRGB[1],avgRGB[2]);
        rect((5*width/10-200)+x,(height/2-200)+y,gridNums[gridSize],gridNums[gridSize]);
      
      }
      num++;  
    }
  }
  //text(gridSize, 80, 80);
  
  //println(gridNums[gridSize]);
  //image(smallPics[(1600/gridSize)-1], 100, 100);
  
  //print(num);
}
  
PImage findPic(int[] rgb) {
  distance = new int[3];
  distance[0] = abs(rgb[0] - avgColors[0][0]);
  distance[1] = abs(rgb[1] - avgColors[0][1]);
  distance[2] = abs(rgb[2] - avgColors[0][2]);
  int count = 0;
  int num = 0;
  for (int[] avgCol : avgColors) {
    int oldDist = distance[0] + distance[1] + distance[2];
    int newDist = abs(rgb[0] - avgCol[0]) + abs(rgb[1] - avgCol[1]) + abs(rgb[2] - avgCol[2]);
    if (newDist < oldDist) {
      num = count;
      distance[0] = abs(rgb[0] - avgCol[0]);
      distance[1] = abs(rgb[1] - avgCol[1]);
      distance[2] = abs(rgb[2] - avgCol[2]);  
    }
    count++;
  }
  return images.get(num);
}
