import processing.video.*;
import java.util.Collections;
import java.util.List;
import java.util.Random;

class LineDetection {
  PImage result, gauss, sobel, linesFinal, bw;
  PGraphics linesImg;
  TwoDThreeD transformer;
  int finalW = 400, finalH = 300;
  int[][] kernel = {{9, 12, 9},
                  {12, 15, 12},
                  {9, 12, 9}};
  
  LineDetection() {
    transformer = new TwoDThreeD();
  }
  
  Boolean drawLineDetec(PImage img, PVector position) {
    result = createImage(img.width, img.height, RGB);
    
    for(int i = 0; i < img.width * img.height; i++) {
      int temp = img.pixels[i];
      if (hue(temp) > 100 && hue(temp) < 140 && brightness(temp) > 30
          && brightness(temp) < 140 && saturation(temp) > 100) {
        result.pixels[i] = (int) brightness(temp);
      }
      else {
        result.pixels[i] = color(0);
      }
    }
    
    gauss = convolute(result, kernel);
    bw = createImage(img.width, img.height, RGB);
    for(int i = 0; i < img.width * img.height; i++) {
      int temp = gauss.pixels[i];
      if (brightness(temp) > 30)
        bw.pixels[i] = color(255);
      else
        bw.pixels[i] = color(0);
    }
    
    sobel = sobel(bw);
    
    linesImg = createGraphics(img.width, img.height, P2D);
    List<PVector> lines = new ArrayList<PVector>();
    List<PVector> vertices = new ArrayList<PVector>();
    hough(sobel, 6, linesImg, lines, vertices); 
    
    if (vertices.size() > 0) {
      position = transformer.get3DRotations(vertices);
      return true;
    }
    else return false;
  }
  
  PImage convolute(PImage img, int[][] kernel) {
    PImage result = createImage(img.width, img.height, RGB);
    
    float weight = 0, temp;
    int acc;
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        weight += kernel[i][j];
      }
    }
                    
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
    
    for (int y = 2; y < img.height - 2; y++) {
      for (int x = 2; x < img.width - 2; x++) {
        if (buffer[y * img.width + x] > (int)(max * 0.25f)) {
          result.pixels[y * img.width + x] = color(255);
        }
        else {
          result.pixels[y * img.width + x] = color(0);
        }
      }
    }
    return result;
  }
  
  PImage hough(PImage edgeImg, int nLines, PGraphics linesImg, List<PVector> vectors, List<PVector> vertices) {
    List<Integer> bestCandidates = new ArrayList<Integer>();
    
    float discretizationStepsPhi = 0.06f;
    float discretizationStepsR = 2.5f;
  
    int phiDim = (int) (Math.PI / discretizationStepsPhi);
    int rMax = ((edgeImg.width + edgeImg.height) * 2 + 1);
    int rDim = (int) (rMax / discretizationStepsR);
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
    int rTemp;
    int rTempDef = (int) (((rMax - 1) >> 1) / discretizationStepsR);
    int minVotes = 200;
    int neighbourhood = 10;
    
    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
  
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
  
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
    
    PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          for (int n = 0; n < phiDim; n++) {
            rTemp = rTempDef + (int) (x * tabCos[n] + y * tabSin[n]);
            accumulator[n * rDim + (int) rTemp] += 1;
          }
        }
      }
    }
    
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    
    houghImg.resize(edgeImg.height, edgeImg.height);
    
    houghImg.updatePixels();
    
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        
        if (accumulator[idx] > minVotes) {
          boolean bestCandidate = true;
          
          for (int dPhi = -(neighbourhood >> 1); dPhi < (neighbourhood >> 1) + 1; dPhi++) {
            if (accPhi + dPhi < 0 || accPhi + dPhi >= phiDim) continue;
            
            for (int dR = -(neighbourhood >> 1); dR < (neighbourhood >> 1) + 1; dR++) {
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
      float r = accR * discretizationStepsR - ((rMax - 1) >> 1);
      float phi = accPhi * discretizationStepsPhi;
      vectors.add(new PVector(r, phi));
    }
    
    QuadGraph graph = new QuadGraph();
    graph.build(vectors,result.width, result.height);
    List<int[]> quads = graph.findCycles();
    
    if (quads.size() > 0) {
    
      float area, maxArea = 0;
      int[] qTemp = quads.get(0);
        
      
      for (int i = 0; i < quads.size(); i++) {
        int[] q = quads.get(i);
        
        PVector v1 = vectors.get(q[0]);
        PVector v2 = vectors.get(q[1]);
        PVector v3 = vectors.get(q[2]);
        PVector v4 = vectors.get(q[3]);
        
        PVector c12 = intersection(v1, v2);
        PVector c23 = intersection(v2, v3);
        PVector c34 = intersection(v3, v4);
        PVector c41 = intersection(v4, v1);
        
        if (graph.isConvex(c12, c23, c34, c41)
            && graph.nonFlatQuad(c12, c23, c34, c41)
            && graph.validArea(c12, c23, c34, c41, result.height * result.height, result.height * result.height / 50)) {
          area = area(c12, c23, c34, c41);
        
          if (area > maxArea) {
            maxArea = area;
            qTemp = q;
          }
        }
      }
      
      List<PVector> newVectors = new ArrayList<PVector>();
      linesImg.beginDraw();
      
      for (int i = 0; i < 4; i++) {
        PVector line = vectors.get(qTemp[i]);
        newVectors.add(vectors.get(qTemp[i]));
        float r = line.x;
        float phi = line.y;
      
        int x0 = 0;
        int y0 = (int) (r / sin(phi));
        int x1 = (int) (r / cos(phi));
        int y1 = 0;
        int x2 = edgeImg.width;
        int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
        int y3 = edgeImg.width;
        int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    
        linesImg.stroke(204, 102, 0);
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
      
      vertices = getIntersections(newVectors, linesImg);
    }
    return houghImg;
  }
  
  float area(PVector v21, PVector v32, PVector v43, PVector v14) {
    
    float i1 = v21.cross(v32).z;
    float i2 = v32.cross(v43).z;
    float i3 = v43.cross(v14).z;
    float i4 = v14.cross(v21).z;
  
    return Math.abs(.5f * (i1 + i2 + i3 + i4));
  }
  
  PVector intersection(PVector line1, PVector line2) {
    double phi1 = line1.y;
    double phi2 = line2.y;
    double r1 = line1.x;
    double r2 = line2.x;
    double d = Math.cos(phi2) * Math.sin(phi1) - Math.cos(phi1) * Math.sin(phi2);
    int x = (int) ((r2 * Math.sin(phi1) - r1 * Math.sin(phi2)) / d);
    int y = (int) ((r1 * Math.cos(phi2) - r2 * Math.cos(phi1)) / d);
    
    return new PVector(x, y);
  }
  
  List<PVector> getIntersections(List<PVector> lines, PGraphics linesImg) {
    linesImg.beginDraw();
    List<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < lines.size() - 1; i++) {
      PVector line1 = lines.get(i);
      for (int j = i + 1; j < lines.size(); j++) {
        PVector line2 = lines.get(j);
        PVector temp = intersection(line1, line2);
        
        intersections.add(temp);
        
        linesImg.fill(255, 128, 0);
        linesImg.ellipse(temp.x, temp.y, 10, 10);
      }
    }
    linesImg.endDraw();
    return intersections;
  }
}