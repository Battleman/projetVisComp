import processing.video.*;
import java.util.Collections;
import java.util.List;

Capture cam;
PImage img;
int finalW = 400, finalH = 300;
HScrollbar thresholdBar, thresholdBar2;

void settings() {
  size(2 * finalW + finalH, finalH, P2D);
}

void setup() {}

void draw() {
  img = loadImage("board3.jpg");
  background(0);
  
  PImage result = createImage(img.width, img.height, RGB);
  
  println(img.width + img.height);
  
  for(int i = 0; i < img.width * img.height; i++) {
    int temp = img.pixels[i];
    if (hue(temp) > 100 && hue(temp) < 140 && brightness(temp) > 60
        && brightness(temp) < 160 && saturation(temp) > 100) {
      result.pixels[i] = color(255);
    }
    else {
      result.pixels[i] = color(0);
    }
  }
  
  int[][] kernel = {{9, 12, 9},
                    {12, 15, 12},
                    {9, 12, 9}};
  
  PImage gauss = convolute(result, kernel);
  PImage sobel = sobel(gauss);
  PGraphics linesImg = createGraphics(img.width, img.height, P2D);
  PImage hough = hough(sobel, 6, linesImg);
  PImage lines = linesImg.get();
  
  img.resize(finalW, finalH);
  lines.resize(finalW, finalH);
  hough.resize(finalH, finalH);
  sobel.resize(finalW, finalH);
  image(img, 0, 0);
  image(lines, 0, 0);
  image(hough, finalW, 0);
  image(sobel, finalW + finalH, 0);
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
      buffer[j * img.width + i] = sum;
      if (sum > max) {
        max = sum;
      }
    }
  }
  
  for (int y = 2; y < img.height - 2; y++) {               // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) {              // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.25f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      }
      else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}

PImage hough(PImage edgeImg, int nLines, PGraphics linesImg) {
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
  
  houghImg.resize(edgeImg.height, edgeImg.height);
  
  houghImg.updatePixels();
  
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
  
  linesImg.beginDraw();
  
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

    linesImg.stroke(204,102,0);
    if (y0 > 0) {
      if (x1 > 0)
        linesImg.line(x0, y0, x1, y1);
      else if (y2 > 0)
        linesImg.line(x0, y0, x2, y2);
      else
        linesImg.line(x0, y0, x3, y3);
    }
    else {
      if (x1 > 0) {
        if (y2 > 0)
          linesImg.line(x1, y1, x2, y2);
        else
          linesImg.line(x1, y1, x3, y3);
      }
      else 
        linesImg.line(x2, y2, x3, y3);
    }
  }
  
  linesImg.endDraw();
  
  ArrayList<PVector> vectors = new ArrayList<PVector>();
  
  for (int i = 0; i < Math.min(nLines, bestCandidates.size()); i++) {
    int idx = bestCandidates.get(i);
    int accPhi = (int) (idx / rDim);
    int accR = idx - accPhi * rDim;
    float r = accR * discretizationStepsR - (rMax - 1) / 2 ;
    float phi = accPhi * discretizationStepsPhi;
    vectors.add(new PVector((int) (r * Math.cos(phi)), (int) (r * Math.sin(phi))));
  }
  
  getIntersections(vectors, linesImg);
  return houghImg;
}

ArrayList<PVector> getIntersections(List<PVector> lines, PGraphics linesImg) {
  linesImg.beginDraw();
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
      
      linesImg.fill(255, 128, 0);
      linesImg.ellipse(x, y, 10, 10);
    }
  }
  linesImg.endDraw();
  return intersections;
}