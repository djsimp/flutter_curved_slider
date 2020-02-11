import 'package:flutter/material.dart';
import 'dart:math';

class MathUtil {
  static double distanceBetween(Offset point1, Offset point2) {
    return sqrt(pow((point1.dx - point2.dx),2)+pow((point1.dy - point2.dy),2));
  }

  static double getAngleInRadians(Offset pointFromCenter) {
    if(pointFromCenter.dx == 0 && pointFromCenter.dy == 0) {
      return 0;
    }
    if(pointFromCenter.dx == 0) {
      if(pointFromCenter.dy >= 0) {
        return pi/2;
      } else {
        return 3*pi/2;
      }
    }
    if(pointFromCenter.dy == 0 && pointFromCenter.dx < 0) {
      return pi;
    }
    double angle;
    if(pointFromCenter.dy < 0) {
      if(pointFromCenter.dx < 0) {
        angle = atan(pointFromCenter.dy/pointFromCenter.dx) + pi;
      } else {
        angle = atan(-pointFromCenter.dx/pointFromCenter.dy) + 3*pi/2;
      }
    } else {
      if(pointFromCenter.dx < 0) {
        angle = atan(-pointFromCenter.dx/pointFromCenter.dy) + pi/2;
      } else {
        angle = atan(pointFromCenter.dy/pointFromCenter.dx);
      }
    }
    return angle;
  }

  static Offset projectAngleOnEllipse(double angleInRadians, Offset start, Offset end) {
    double verticalRadius = MathUtil.getVerticalRadius(start, end);
    double horizontalRadius = MathUtil.getHorizontalRadius(start, end);
    double k = 1/sqrt(pow(verticalRadius,2) * pow(cos(angleInRadians),2)
        + pow(horizontalRadius,2) * pow(sin(angleInRadians),2));
    return Offset((k*verticalRadius*horizontalRadius*cos(angleInRadians)).roundToDouble(),
        (k*verticalRadius*horizontalRadius*sin(angleInRadians)).roundToDouble());
  }

  static Offset screenToEllipseSpace(Offset point, Offset centerOfEllipse) {
    return Offset(point.dx - centerOfEllipse.dx, point.dy - centerOfEllipse.dy);
  }

  static Offset ellipseToScreenSpace(Offset point, Offset centerOfEllipse) {
    return Offset(point.dx + centerOfEllipse.dx, point.dy + centerOfEllipse.dy);
  }

  static double interpolate(double value, double from, double to) {
    if(from == 0) {
      return 0;
    }
    return value*to/from;
  }

  static Offset getEllipseCenterOffset(Offset start, Offset end) {
    return Offset(start.dx, end.dy);
  }

  static double getVerticalRadius(Offset start, Offset end) {
    return (end.dy - start.dy).abs();
  }

  static double getHorizontalRadius(Offset start, Offset end) {
    return (end.dx - start.dx).abs();
  }

  static bool isHorizontal(Offset start, Offset end) {
    return start.dy == end.dy;
  }

  static bool isVertical(Offset start, Offset end) {
    return start.dx == end.dx;
  }

  static Rect createRectForEllipse(Offset start, Offset end) {
    int quadrant = getEllipseQuadrant(start, end);
    Offset centerOffset = getEllipseCenterOffset(start, end);
    switch(quadrant) {
      case 1:
        return Rect.fromCenter(
            center: centerOffset,
            width: 2*(end.dx-start.dx),
            height: 2*(start.dy-end.dy)
        );
      case 2:
        return Rect.fromCenter(
            center: centerOffset,
            width: 2*(start.dx-end.dx),
            height: 2*(start.dy-end.dy)
        );
      case 3:
        return Rect.fromCenter(
            center: centerOffset,
            width: 2*(start.dx-end.dx),
            height: 2*(end.dy-start.dy)
        );
      default:
        return Rect.fromCenter(
            center: centerOffset,
            width: 2*(end.dx-start.dx),
            height: 2*(end.dy-start.dy)
        );
    }
  }

  static int getEllipseQuadrant(Offset start, Offset end) {
    if(start.dx <= end.dx) {
      if(start.dy >= end.dy) {
        return 1;
      } else {
        return 4;
      }
    } else {
      if(start.dy >= end.dy) {
        return 2;
      } else {
        return 3;
      }
    }
  }

  static int getPointQuadrant(Offset point, Offset start, Offset end) {
    Offset centerOfEllipse = getEllipseCenterOffset(start, end);
    if(point.dx >= centerOfEllipse.dx) {
      if(point.dy >= centerOfEllipse.dy) {
        return 1;
      } else {
        return 4;
      }
    } else {
      if(point.dy >= centerOfEllipse.dy) {
        return 2;
      } else {
        return 3;
      }
    }
  }

  static Offset translatePointToEllipseQuadrant(Offset point, Offset start, Offset end) {
    int pointQuadrant = MathUtil.getPointQuadrant(point, start, end);
    int ellipseQuadrant = MathUtil.getEllipseQuadrant(start, end);
    Offset centerOfEllipse = MathUtil.getEllipseCenterOffset(start, end);
    point = screenToEllipseSpace(point, centerOfEllipse);

    if(pointQuadrant == ellipseQuadrant) {
      return ellipseToScreenSpace(point, centerOfEllipse);
    } else if(pointQuadrant%2 == ellipseQuadrant%2) {
      point = Offset(-point.dx,-point.dy);
    } else {
      switch(pointQuadrant) {
        case 1:
          if(ellipseQuadrant == 2) {
            point = Offset(-point.dx,point.dy);
          } else {
            point = Offset(point.dx, -point.dy);
          }
          break;
        case 2:
          if(ellipseQuadrant == 1) {
            point = Offset(-point.dx,point.dy);
          } else {
            point = Offset(point.dx, -point.dy);
          }
          break;
        case 3:
          if(ellipseQuadrant == 4) {
            point = Offset(-point.dx,point.dy);
          } else {
            point = Offset(point.dx, -point.dy);
          }
          break;
        case 4:
          if(ellipseQuadrant == 3) {
            point = Offset(-point.dx,point.dy);
          } else {
            point = Offset(point.dx, -point.dy);
          }
      }
    }
    return ellipseToScreenSpace(point, centerOfEllipse);
  }
}