import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:flutter_app_moving_slider/math_util.dart';

double round10(double num) {
  return (num * pow(10, 10)).round().toDouble() / pow(10, 10);
}

void main() {
  group('getAngleInRadians', () {
    test('getAngleInRadians atan(1/0)=pi/2', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(0,1))), round10(pi/2));
    });
    test('getAngleInRadians atan(1/1)=pi/4', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(1,1))), round10(pi/4));
    });
    test('getAngleInRadians atan(1/-1)=3pi/4', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(-1,1))), round10(3*pi/4));
    });
    test('getAngleInRadians atan(-1/-1)=5pi/4', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(-1,-1))), round10(5*pi/4));
    });
    test('getAngleInRadians atan(-1/1)=7pi/4', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(1,-1))), round10(7*pi/4));
    });
    test('getAngleInRadians atan(-1/0)=3pi/2', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(0,-1))), round10(3*pi/2));
    });
    test('getAngleInRadians atan(0/1)=0', () {
      expect(MathUtil.getAngleInRadians(Offset(1,0)), 0);
    });
    test('getAngleInRadians atan(0/-1)=pi', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(-1,0))), round10(pi));
    });
    test('getAngleInRadians atan((1/2)/(sqrt(3)/2))=pi/6', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(sqrt(3)/2,1/2))), round10(pi/6));
    });
    test('getAngleInRadians atan((sqrt(3)/2)/(1/2))=pi/3', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(1/2,sqrt(3)/2))), round10(pi/3));
    });
    test('getAngleInRadians atan((sqrt(3)/2)/(-1/2))=2pi/3', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(-1/2,sqrt(3)/2))), round10(2*pi/3));
    });
    test('getAngleInRadians atan((1/2)/(-sqrt(3)/2))=5pi/6', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(-sqrt(3)/2,1/2))), round10(5*pi/6));
    });
    test('getAngleInRadians atan((-1/2)/(-sqrt(3)/2))=7pi/6', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(-sqrt(3)/2,-1/2))), round10(7*pi/6));
    });
    test('getAngleInRadians atan((-sqrt(3)/2)/(-1/2))=4pi/3', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(-1/2,-sqrt(3)/2))), round10(4*pi/3));
    });
    test('getAngleInRadians atan((-sqrt(3)/2)/(1/2))=5pi/3', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(1/2,-sqrt(3)/2))), round10(5*pi/3));
    });
    test('getAngleInRadians atan((-1/2)/(sqrt(3)/2))=5pi/6', () {
      expect(round10(MathUtil.getAngleInRadians(Offset(sqrt(3)/2,-1/2))), round10(11*pi/6));
    });
  });


  group('projectAngleOnEllipse', () {
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(0, Offset(100,300), Offset(300,500)), Offset(100,500)), Offset(300,500));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(0, Offset(100,500), Offset(300,300)), Offset(100,300)), Offset(300,300));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(3*pi/2, Offset(100,300), Offset(300,500)), Offset(100,500)), Offset(100,300));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(3*pi/2, Offset(300,300), Offset(100,500)), Offset(300,500)), Offset(300,300));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(pi, Offset(300,300), Offset(100,500)), Offset(300,500)), Offset(100,500));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(pi, Offset(300,500), Offset(100,300)), Offset(300, 300)), Offset(100,300));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(pi/2, Offset(100,500), Offset(300,300)), Offset(100, 300)), Offset(100,500));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(pi/2, Offset(300,500), Offset(100,300)), Offset(300,300)), Offset(300,500));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(7*pi/4, Offset(100,300), Offset(300,500)), Offset(100, 500)), Offset((100*sqrt(2)+100).roundToDouble(),(-100*sqrt(2)+500).roundToDouble()));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(5*pi/4, Offset(300,300), Offset(100,500)), Offset(300, 500)), Offset((-100*sqrt(2)+300).roundToDouble(),(-100*sqrt(2)+500).roundToDouble()));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(3*pi/4, Offset(300,500), Offset(100,300)), Offset(300, 300)), Offset((-100*sqrt(2)+300).roundToDouble(),(100*sqrt(2)+300).roundToDouble()));
    });
    test('projectAngleOnEllipse', () {
      expect(MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(pi/4, Offset(100,500), Offset(300,300)), Offset(100, 300)), Offset((100*sqrt(2)+100).roundToDouble(),(100*sqrt(2)+300).roundToDouble()));
    });
  });

  group('screenTranslation', () {
    test('screenToEllipseIV', () {
      expect(MathUtil.screenToEllipseSpace(Offset(150,400), Offset(100,500)), Offset(50, -100));
    });
    test('screenToEllipseIII', () {
      expect(MathUtil.screenToEllipseSpace(Offset(50,400), Offset(100,500)), Offset(-50, -100));
    });
    test('screenToEllipseII', () {
      expect(MathUtil.screenToEllipseSpace(Offset(50,600), Offset(100,500)), Offset(-50, 100));
    });
    test('screenToEllipseI', () {
      expect(MathUtil.screenToEllipseSpace(Offset(150,600), Offset(100,500)), Offset(50, 100));
    });
    test('ellipseToScreenIV', () {
      expect(MathUtil.ellipseToScreenSpace(Offset(50,-100), Offset(100,500)), Offset(150,400));
    });
    test('ellipseToScreenIII', () {
      expect(MathUtil.ellipseToScreenSpace(Offset(-50,-100), Offset(100,500)), Offset(50,400));
    });
    test('ellipseToScreenII', () {
      expect(MathUtil.ellipseToScreenSpace(Offset(-50,100), Offset(100,500)), Offset(50,600));
    });
    test('ellipseToScreenI', () {
      expect(MathUtil.ellipseToScreenSpace(Offset(50,100), Offset(100,500)), Offset(150,600));
    });
  });

  group('translatePointToEllipse', () {
    test('translateIV', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(200,200), Offset(100,100), Offset(300, 300)), Offset(200,200));
    });
    test('translateIV', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(0,200), Offset(100,100), Offset(300, 300)), Offset(200,200));
    });
    test('translateIV', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(200,400), Offset(100,100), Offset(300, 300)), Offset(200,200));
    });
    test('translateIV', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(0,400), Offset(100,100), Offset(300, 300)), Offset(200,200));
    });

    test('translateIII', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(200,200), Offset(300,100), Offset(100, 300)), Offset(200,200));
    });
    test('translateIII', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(400,200), Offset(300,100), Offset(100, 300)), Offset(200,200));
    });
    test('translateIII', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(400,400), Offset(300,100), Offset(100, 300)), Offset(200,200));
    });
    test('translateIII', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(200,400), Offset(300,100), Offset(100, 300)), Offset(200,200));
    });

    test('translateII', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(200,200), Offset(300,300), Offset(100, 100)), Offset(200,200));
    });
    test('translateII', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(400,200), Offset(300,300), Offset(100, 100)), Offset(200,200));
    });
    test('translateII', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(400,0), Offset(300,300), Offset(100, 100)), Offset(200,200));
    });
    test('translateII', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(200,0), Offset(300,300), Offset(100, 100)), Offset(200,200));
    });

    test('translateI', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(200,200), Offset(100,300), Offset(300, 100)), Offset(200,200));
    });
    test('translateI', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(0,200), Offset(100,300), Offset(300, 100)), Offset(200,200));
    });
    test('translateI', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(0,0), Offset(100,300), Offset(300, 100)), Offset(200,200));
    });
    test('translateI', () {
      expect(MathUtil.translatePointToEllipseQuadrant(Offset(200,0), Offset(100,300), Offset(300, 100)), Offset(200,200));
    });
  });
}