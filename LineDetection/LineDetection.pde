import processing.video.*;
import java.util.Collections;
import java.util.List;

Capture cam;
PImage img, result, hough;
HScrollbar thresholdBar, thresholdBar2;

void settings() {
  size(800, 600);
}

void setup() {
  thresholdBar = new HScrollbar(0, 540, 800, 20);
  thresholdBar2 = new HScrollbar(0, 580, 800, 20);
  /*String[] cameras = Capture.list();
  
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
  }*/
}

void draw() {
  /*if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();*/
  img = loadImage("board3.jpg");
  background(color(0));
  
  float threshold = 256 * thresholdBar.getPos();//118.5; 121; 109.5; 104;105;
  float threshold2 = 256 * thresholdBar2.getPos();//133.5; 135; 125.5; 125;133;
  PImage hue = createImage(width, height, RGB);
  PImage bright = createImage(width, height, RGB);
  PImage sature = createImage(width, height, RGB);
  
  for(int i = 0; i < img.width * img.height; i++) {
    if(hue(img.pixels[i]) > 100 && hue(img.pixels[i]) < 140) {
      hue.pixels[i] = img.pixels[i];
    }
    else {
      hue.pixels[i] = color(0, 0, 0);
    }
  }
  for(int i = 0; i < img.width * img.height; i++) {
    if(brightness(img.pixels[i]) > threshold && brightness(img.pixels[i]) < threshold2) {
      bright.pixels[i] = hue.pixels[i];
    }
    else {
      bright.pixels[i] = color(0, 0, 0);
    }
  }/*
  for(int i = 0; i < img.width * img.height; i++) {
    if(hue(img.pixels[i]) > threshold && hue(img.pixels[i]) < threshold2) {
      sature.pixels[i] = bright.pixels[i];
    }
    else {
      sature.pixels[i] = color(0, 0, 0);
    }
  }*/
  
  
  int[][] kernel = {{9, 12, 9},
                    {12, 15, 12},
                    {9, 12, 9}};
  
  PImage gauss = convolute(hue, kernel);
  PImage sobel = sobel(gauss);
  image(bright, 0, 0);
  hough(sobel, 4);
  //save("test.png");
  thresholdBar.display();
  thresholdBar.update();
  thresholdBar2.display();
  thresholdBar2.update();
  
  println("min : " + threshold + " max : " + threshold2);
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
  
  float max = 0, sum;
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

void hough(PImage edgeImg, int nLines) {
  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
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
          rTemp = (int) (x * Math.cos(phi) + y * Math.sin(phi));
          rTemp += (rMax - 1) / 2;
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
  
  //image(houghImg, 0, 0);
  
  int minVotes = 200;
  
  int neighbourhood = 10;
  
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate = true;
        
        for (int dPhi = -neighbourhood / 2; dPhi < neighbourhood / 2 + 1; dPhi++) {
          if (accPhi + dPhi < 0 || accPhi + dPhi >= phiDim) continue;
          
          for (int dR = -neighbourhood / 2; dR < neighbourhood / 2 + 1; dR++) {
            if (accR + dR < 0 || accR + dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            
            if (accumulator[idx] < accumulator[neighbourIdx]) {
              bestCandidate = false;
              break;
            }
          }
          
          if (!bestCandidate) break;
        }
        
        if (bestCandidate) {
          bestCandidates.add(idx);
        }
      }
    }
  }

  
  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  
  for (int i = 0; i < Math.min(nLines, bestCandidates.size()); i++) {
    int idx = bestCandidates.get(i);
    int accPhi = (int) (idx / rDim);
    int accR = idx - accPhi * rDim;
    float r = accR * discretizationStepsR - (rMax - 1) / 2 ;
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
  
  ArrayList<PVector> vectors = new ArrayList<PVector>();
  
  for (int i = 0; i < Math.min(nLines, bestCandidates.size()); i++) {
    int idx = bestCandidates.get(i);
    int accPhi = (int) (idx / rDim);
    int accR = idx - accPhi * rDim;
    float r = accR * discretizationStepsR - (rMax - 1) / 2 ;
    float phi = accPhi * discretizationStepsPhi;
    vectors.add(new PVector((int) (r * Math.cos(phi)), (int) (r * Math.sin(phi))));
  }
  
  getIntersections(vectors);
}

ArrayList<PVector> getIntersections(List<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      double phi1 = line1.heading();
      double phi2 = line2.heading();
      double r1 = line1.mag();
      double r2 = line2.mag();
      double d = Math.cos(phi2) * Math.sin(phi1) - Math.cos(phi1) * Math.sin(phi2);
      int x = (int) ((r2 * Math.sin(phi1) - r1 * Math.sin(phi2)) / d);
      int y = (int) ((r1 * Math.cos(phi2) - r2 * Math.cos(phi1)) / d);
      
      intersections.add(new PVector(x, y));
      
      fill(255, 128, 0);
      ellipse(x, y, 10, 10);
    }
  }
  return intersections;
}