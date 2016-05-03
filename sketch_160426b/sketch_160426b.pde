import processing.video.*;

Capture cam;
PImage img, result, hough;

void settings() {
  size(640, 480);
}

void setup() {
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  }
  else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  background(color(0));
  int[][] kernel = {{9, 12, 9},
                    {12, 15, 12},
                    {9, 12, 9}};
  
  PImage gauss = convolute(img, kernel);
  result = sobel(gauss);
  image(result, 0, 0);
  hough(result);
  save("test.png");
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
  float b = 1;
  float s = 0;
  float[][] hKernel = { {s, b, s},
                        {0, 0, 0},
                        {-s, -b, -s}};
  float[][] vKernel = { {s, 0, -s},
                        {b, 0, -b},
                        {s, 0, -s}};
                        
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
      if (buffer[y * img.width + x] > (int)(max * 0.10f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      }
      else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}

void hough(PImage edgeImg) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;

  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rMax = ((edgeImg.width + edgeImg.height) * 2 + 1);
  int rDim = (int) (rMax / discretizationStepsR);
  
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  int rTemp;

  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        float phi = 0;
        for (int n = 0; n < phiDim; n++, phi += discretizationStepsPhi) {
          rTemp = (int) (x*Math.cos(phi) + y*Math.sin(phi));
          rTemp += (rMax - 1)/2;
          rTemp /= discretizationStepsR;
          accumulator[n * rDim + (int)rTemp] += 1;
        }
      }
    }
  }
  
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  
  houghImg.resize(400, 400);
  
  houghImg.updatePixels();
  
  for (int idx = 0; idx < accumulator.length; idx++) {
    if (accumulator[idx] > 200) {
      int accPhi = (int) (idx / rDim);
      int accR = idx - accPhi * rDim;
      float r = accR * discretizationStepsR - (rMax - 1)/2 ;
      float phi = accPhi * discretizationStepsPhi;
  
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

      stroke(204,102,0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      }
      else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        }
        else 
          line(x2, y2, x3, y3);
      }
    }
  }
}