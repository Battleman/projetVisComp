PImage img, result;
HScrollbar thresholdBar;
HScrollbar thresholdBar2;

void settings() {
  size(800, 600);
}

void setup() {
  thresholdBar = new HScrollbar(0, 580, 800, 20);
  thresholdBar2 = new HScrollbar(0, 550, 800, 20);
  img = loadImage("board1.jpg");
  noLoop();
}

void draw() {
  background(color(0));
  /*for (int i = 0; i < img.width * img.height; i++) {
    if (hue(img.pixels[i]) > thresholdBar.getPos() * 255
        && hue(img.pixels[i]) < thresholdBar2.getPos() * 255) {
      result.pixels[i] = img.pixels[i];
    }
  }*/
  int[][] kernel = {{9, 12, 9},
                    {12, 15, 12},
                    {9, 12, 9}};
  
  PImage gauss = convolute(img, kernel);
  result = sobel(gauss);
  image(result, 0, 0);
  thresholdBar.display();
  thresholdBar.update();
  thresholdBar2.display();
  thresholdBar2.update();
}

PImage convolute(PImage img, int[][] kernel) {
  PImage result = createImage(img.width, img.height, RGB);
  
  float weight = 0, temp;
  
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      weight += kernel[i][j];
    }
  }
  int acc;
                  
  for (int i = 1; i < img.width - 1; i++) {
    for (int j = 1; j < img.height - 1; j++) {
      acc = 0;
      for (int k = -1; k < 2; k++) {
        for (int l = -1; l < 2; l++) {
          acc += brightness(img.get(i + k, j + l)) * kernel[k + 1][l + 1];
        }
      }
      
      temp = acc / weight;
      result.pixels[j * img.width + i] = color(temp, temp, temp);
    }
  }
  return result;
}

PImage sobel(PImage img) {
  float[][] hKernel = { {0, 1, 0},
                        {0, 0, 0},
                        {0, -1, 0}};
  float[][] vKernel = { {0, 0, 0},
                        {1, 0, -1},
                        {0, 0, 0}};
                        
  PImage result = createImage(img.width, img.height, ALPHA);
  
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  
  float max=0, sum;
  float[] buffer = new float[img.width * img.height];
  
  int sumH, sumV;
  
  for (int i = 1; i < img.width - 1; i++) {
    for (int j = 1; j < img.height - 1; j++) {
      sumH = 0;
      sumV = 0;
      for (int k = -1; k < 2; k++) {
        for (int l = -1; l < 2; l++) {
          sumH += brightness(img.get(i + k, j + l)) * hKernel[k + 1][l + 1];
          sumV += brightness(img.get(i + k, j + l)) * vKernel[k + 1][l + 1];
        }
      }
      sum = sqrt(pow(sumH, 2) + pow(sumV, 2));
      buffer[j * width + i] = sum;
      if (sum > max) {
        max = sum;
      }
    }
  }
  
  for (int y = 2; y < img.height - 2; y++) {               // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) {              // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.15f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      }
      else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}