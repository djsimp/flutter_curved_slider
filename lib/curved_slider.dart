import 'package:flutter/material.dart';
import 'dart:math';
import 'math_util.dart';


class CurvedSlider extends StatefulWidget {
  CurvedSlider({ this.onValueChanged, this.onActivated, this.onDeactivated, this.rangeLeftValue, this.rangeRightValue, this.thumbCount });
  final int rangeLeftValue;
  final int rangeRightValue;
  final int thumbCount;
  final ValueChangedCallback onValueChanged;
  final VoidCallback onActivated;
  final VoidCallback onDeactivated;

  @override
  _CurvedSliderState createState() => _CurvedSliderState();
}

typedef ValueChangedCallback = void Function(List newValues);

class _CurvedSliderState extends State<CurvedSlider> {
  int _positionValue = 0;
  int _sliderStartValue;
  int _sliderEndValue;
  List _thumbs;
  bool _isEditable;
  static double _containerHeight = 700;
  static double _containerWidth = 400;
  Offset _sliderStart;
  Offset _sliderEnd;
  Offset _tempOldStart;
  Offset _tempOldEnd;
  bool _movingStartNode;
  bool _movingEndNode;
  double _thumbRadius = 30;

  @override
  initState() {
    super.initState();
    _isEditable = false;
    _movingStartNode = false;
    _movingEndNode = false;
    _sliderStart = Offset(50, 300);
    _sliderEnd = Offset(250, 650);
    if(widget.rangeLeftValue != null) {
      _sliderStartValue = widget.rangeLeftValue;
    } else {
      _sliderStartValue = 0;
    }
    if(widget.rangeRightValue != null) {
      _sliderEndValue = widget.rangeRightValue;
    } else {
      _sliderEndValue = 100;
    }
    if(widget.thumbCount != null) {
      _thumbs = new List(widget.thumbCount);
      for(var i = 0; i < widget.thumbCount; i++) {
        _thumbs[i] = new Thumb(_thumbRadius, _sliderStart);
      }
    } else {
      _thumbs = new List(1);
      _thumbs[0] = new Thumb(_thumbRadius, _sliderStart);
    }
  }

  void activateSlider(PointerDownEvent event) {
    for(var i = 0; i < _thumbs.length; i++) {
      if (_thumbs[i].didHitThumb(event.localPosition)) {
        setState(() {
          _thumbs[i].activate();
        });
        if (widget.onActivated != null) {
          widget.onActivated();
        }
        break;
      }
    }
  }

  void deactivateSlider(PointerUpEvent event) {
    for(var i = 0; i < _thumbs.length; i++) {
      if(_thumbs[i].isActive()) {
        setState(() {
          _thumbs[i].deactivate();
        });
        if (widget.onDeactivated != null) {
          widget.onDeactivated();
        }
      }
    }
  }

  Offset calculateNewSliderPosition(Offset touchPoint, Offset start, Offset end) {
    if(MathUtil.isVertical(start, end)) {
      if(start.dy > end.dy) {
        if(touchPoint.dy > start.dy) {
          return start;
        } else if(touchPoint.dy < end.dy) {
          return end;
        }
      } else {
        if(touchPoint.dy > end.dy) {
          return end;
        } else if(touchPoint.dy < start.dy) {
          return start;
        }
      }
      return Offset(start.dx,touchPoint.dy);
    } else if(MathUtil.isHorizontal(start, end)) {
      if(start.dx > end.dx) {
        if(touchPoint.dx > start.dx) {
          return start;
        } else if(touchPoint.dx < end.dx) {
          return end;
        }
      } else {
        if(touchPoint.dx > end.dx) {
          return end;
        } else if(touchPoint.dx < start.dx) {
          return start;
        }
      }
      return Offset(touchPoint.dx, start.dy);
    } else {
      Offset point = MathUtil.translatePointToEllipseQuadrant(touchPoint, start, end);
      return MathUtil.ellipseToScreenSpace(
        MathUtil.projectAngleOnEllipse(
          MathUtil.getAngleInRadians(
            MathUtil.screenToEllipseSpace(
              point,
              MathUtil.getEllipseCenterOffset(
                start,
                end
              )
            )
          ),
          start,
          end
        ),
        MathUtil.getEllipseCenterOffset(
          start,
          end
        )
      );
    }
  }

  void moveSlider(PointerMoveEvent event) {
    for(var i = 0; i < _thumbs.length; i++) {
      if (_thumbs[i].isActive()) {
        int oldSliderValue = interpolateSliderToValue(_thumbs[i].getPosition(), _sliderStart, _sliderEnd);
        Offset newPosition = calculateNewSliderPosition(event.localPosition, _sliderStart, _sliderEnd);
        setState(() {
          _thumbs[i].moveThumb(newPosition);
          _positionValue = interpolateSliderToValue(newPosition, _sliderStart, _sliderEnd);
        });
        if (_positionValue != oldSliderValue && widget.onValueChanged != null) {
          widget.onValueChanged(getThumbValues());
        }
      }
    }
  }

  int interpolateSliderToValue(Offset point, Offset start, Offset end) {
    if(MathUtil.isHorizontal(start, end)) {
      return (MathUtil.interpolate(
          point.dx - start.dx,
          end.dx - start.dx,
          _sliderEndValue.toDouble() - _sliderStartValue.toDouble()
      ) + _sliderStartValue).round();
    } else if(MathUtil.isVertical(start, end)) {
      return (MathUtil.interpolate(
          point.dy - start.dy,
          end.dy - start.dy,
          _sliderEndValue.toDouble() - _sliderStartValue.toDouble()
      ) + _sliderStartValue).round();
    } else {
      double portion = MathUtil.distanceBetween(point, start);
      double total = portion + MathUtil.distanceBetween(end, point);
      double values = _sliderEndValue.toDouble() - _sliderStartValue.toDouble();
      double interpolatedValue = MathUtil.interpolate(portion, total, values);
      double adjustedValue = interpolatedValue + _sliderStartValue;
      return adjustedValue.round();
    }
  }

  Offset interpolateValueToSlider(int value, Offset sliderStart, Offset sliderEnd) {
    if(MathUtil.isVertical(sliderStart, sliderEnd)) {
      return Offset(sliderStart.dx, MathUtil.interpolate(value.toDouble(), (_sliderEndValue-_sliderStartValue).toDouble(), sliderEnd.dy-sliderStart.dy)+sliderStart.dy);
    } else if(MathUtil.isHorizontal(sliderStart, sliderEnd)) {
      return Offset(MathUtil.interpolate(value.toDouble(), (_sliderEndValue-_sliderStartValue).toDouble(), sliderEnd.dx-sliderStart.dx)+sliderStart.dx, sliderStart.dy);
    }
    Offset position = sliderStart;
    int divisor = 2;
    double angle = MathUtil.getAngleInRadians(MathUtil.screenToEllipseSpace(position, MathUtil.getEllipseCenterOffset(_sliderStart, _sliderEnd)));
    int curValue = interpolateSliderToValue(position, sliderStart, sliderEnd);
    int quadrant = MathUtil.getEllipseQuadrant(sliderStart, sliderEnd);
    while(curValue != value) {
      divisor *= 2;
      if((quadrant % 2 == 1 && curValue > value)
          || (quadrant % 2 == 0 && curValue < value)) {
        angle += pi/divisor;
      } else {
        angle -= pi/divisor;
      }
      position = MathUtil.ellipseToScreenSpace(MathUtil.projectAngleOnEllipse(angle, sliderStart, sliderEnd),MathUtil.getEllipseCenterOffset(sliderStart, sliderEnd));
      if(position.dx.isNaN || position.dy.isNaN) {
        return Offset(0,0);
      }
      curValue = interpolateSliderToValue(position, sliderStart, sliderEnd);
    }
    return position;
  }

  void startEditSlider(PointerDownEvent event) {
    if(MathUtil.distanceBetween(_sliderStart, event.localPosition) <= 20) {
      _movingStartNode = true;
      _tempOldStart = _sliderStart;
      _tempOldEnd = _sliderEnd;
    } else if(MathUtil.distanceBetween(_sliderEnd, event.localPosition) <= 20) {
      _movingEndNode = true;
      _tempOldStart = _sliderStart;
      _tempOldEnd = _sliderEnd;
    }
  }

  void editMoveSlider(PointerMoveEvent event) {
    if(_movingStartNode
        && !(_sliderStart.dx == event.localPosition.dx
            && _sliderStart.dy == event.localPosition.dy)) {
      Offset newStart = event.localPosition;
      if((newStart.dy - _sliderEnd.dy).abs() <= 5) {
        newStart = Offset(newStart.dx, _sliderEnd.dy);
      } else if((newStart.dx - _sliderEnd.dx).abs() <= 5) {
        newStart = Offset(_sliderEnd.dx, newStart.dy);
      }
      setState(() {
        _sliderStart = newStart;
      });
    } else if(_movingEndNode
        && !(_sliderEnd.dx == event.localPosition.dx
            && _sliderEnd.dy == event.localPosition.dy)) {
      Offset newEnd = event.localPosition;
      if((newEnd.dy - _sliderStart.dy).abs() <= 5) {
        newEnd = Offset(newEnd.dx, _sliderStart.dy);
      } else if((newEnd.dx - _sliderStart.dx).abs() <= 5) {
        newEnd = Offset(_sliderStart.dx, newEnd.dy);
      }
      setState(() {
        _sliderEnd = newEnd;
      });
    }
  }

  void stopEditSlider(PointerUpEvent event) {
    _movingStartNode = _movingEndNode = false;
    if(_tempOldStart != null && _tempOldEnd != null) {
      setState(() => adjustThumbPositions(_tempOldStart, _tempOldEnd, _sliderStart, _sliderEnd));
    }
    _tempOldEnd = null;
    _tempOldStart = null;
  }

  void adjustThumbPositions(Offset oldStart, Offset oldEnd, Offset newStart, Offset newEnd) {
    for(int i = 0; i < _thumbs.length; i++) {
      _thumbs[i].activate();
      int value = interpolateSliderToValue(_thumbs[i].getPosition(), oldStart, oldEnd);
      _thumbs[i].moveThumb(interpolateValueToSlider(value, newStart, newEnd));
      _thumbs[i].deactivate();
    }
    widget.onValueChanged(getThumbValues());
  }

  List getThumbValues() {
    List thumbPositions = new List(_thumbs.length);
    for(var i = 0; i < _thumbs.length; i++) {
      thumbPositions[i] = interpolateSliderToValue(_thumbs[i].getPosition(), _sliderStart, _sliderEnd);
    }
    return thumbPositions;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [
        Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent;
          child: Listener(
            onPointerDown: (event) => _isEditable ? startEditSlider(event) : activateSlider(event),
            onPointerMove: (event) => _isEditable ? editMoveSlider(event) : moveSlider(event),
            onPointerUp: (event) => _isEditable ? stopEditSlider(event) : deactivateSlider(event),
            child: Container(
              height: _containerHeight,
              width: _containerWidth,
              color: Color.fromRGBO(230, 230, 230, 1.0),
              child: CustomPaint(
                painter: _MySliderPainter(_thumbs, _thumbRadius, _sliderStart, _sliderEnd, _isEditable),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: FloatingActionButton(
              child: Icon(Icons.mode_edit),
              onPressed: () => setState(() => _isEditable = !_isEditable),
            ),
          )
        ),
      ]
    );
  }
}

class _MySliderPainter extends CustomPainter {
  List _thumbs;
  double _thumbRadius;
  Offset _sliderStartOffset;
  Offset _sliderEndOffset;
  bool _isEditing;

  _MySliderPainter(List thumbs, double thumbRadius, Offset sliderStartOffset, Offset sliderEndOffset, bool isEditing) {
    _thumbs = thumbs;
    _thumbRadius = thumbRadius;
    _sliderStartOffset = sliderStartOffset;
    _sliderEndOffset = sliderEndOffset;
    _isEditing = isEditing;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sliderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    final sliderEndsPaint = Paint()
      ..style = PaintingStyle.fill;
    final sliderStartPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(255,255,255,1.0);
    if(MathUtil.isVertical(_sliderStartOffset, _sliderEndOffset)
      || MathUtil.isHorizontal(_sliderStartOffset, _sliderEndOffset)) {
      if(_isEditing) {
        sliderPaint.color = Color.fromRGBO(100, 100, 100, 1.0);
        canvas.drawLine(_sliderStartOffset,_sliderEndOffset,sliderPaint);
        sliderEndsPaint.color = Color.fromRGBO(19, 242, 116, 1.0);
        canvas.drawCircle(_sliderStartOffset, 20, sliderEndsPaint);
        canvas.drawCircle(_sliderEndOffset, 20, sliderEndsPaint);
        canvas.drawCircle(_sliderStartOffset, 5, sliderStartPaint);
      } else {
        canvas.drawLine(_sliderStartOffset,_sliderEndOffset,sliderPaint);
        sliderEndsPaint.color = Color.fromRGBO(0, 0, 0, 1.0);
        canvas.drawCircle(_sliderStartOffset, 10, sliderEndsPaint);
        canvas.drawCircle(_sliderEndOffset, 10, sliderEndsPaint);
        drawThumbs(canvas);
      }
    } else {
      Rect rect = MathUtil.createRectForEllipse(_sliderStartOffset,_sliderEndOffset);
      int quadrant = MathUtil.getEllipseQuadrant(_sliderStartOffset,_sliderEndOffset);
      canvas.drawArc(rect, (quadrant-1)*pi/2, pi/2, false, sliderPaint);
      if(_isEditing) {
        sliderEndsPaint.color = Color.fromRGBO(19, 242, 116, 1.0);
        canvas.drawCircle(_sliderStartOffset, 20, sliderEndsPaint);
        canvas.drawCircle(_sliderEndOffset, 20, sliderEndsPaint);
        canvas.drawCircle(_sliderStartOffset, 5, sliderStartPaint);
      } else {
        sliderEndsPaint.color = Color.fromRGBO(0, 0, 0, 1.0);
        canvas.drawCircle(_sliderStartOffset, 10, sliderEndsPaint);
        canvas.drawCircle(_sliderEndOffset, 10, sliderEndsPaint);
        drawThumbs(canvas);
      }
    }
  }

  void drawThumbs(Canvas canvas) {
    for (int i = 0; i < _thumbs.length; i++) {
      drawSimpleThumb(canvas, _thumbs[i]);
    }
  }

  void drawSimpleThumb(Canvas canvas, Thumb thumb) {
    final thumbPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Color.fromRGBO(100, 100, 100, 1.0);
    canvas.drawCircle(thumb.getPosition(), _thumbRadius, thumbPaint);
  }

  void drawSmileyThumb(Canvas canvas, Thumb thumb) {
    double red = 0;
    double green = 0;
    double blue = 0;
    if (thumb
        .getPosition()
        .dx <= 190) {
      red = 0;
      green = 255 * (1 - 2 * (thumb
          .getPosition()
          .dx - _sliderStartOffset.dx) /
          (_sliderEndOffset.dx - _sliderStartOffset.dx));
      blue = 255 * 2 * (thumb
          .getPosition()
          .dx - _sliderStartOffset.dx) /
          (_sliderEndOffset.dx - _sliderStartOffset.dx);
    } else {
      red = 255 * (2 * thumb
          .getPosition()
          .dx - _sliderEndOffset.dx -
          _sliderStartOffset.dx) /
          (_sliderEndOffset.dx - _sliderStartOffset.dx);
      green = 0;
      blue = 255 * (2 - (2 * thumb
          .getPosition()
          .dx - _sliderEndOffset.dx -
          _sliderStartOffset.dx)) /
          (_sliderEndOffset.dx - _sliderStartOffset.dx);
    }
    final thumbPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(
          red.round(), green.round(), blue.round(), 1.0);
    canvas.drawCircle(thumb.getPosition(), _thumbRadius, thumbPaint);
    final smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Color.fromRGBO(255, 255, 255, 1.0);
    if (thumb
        .getPosition()
        .dx <=
        ((_sliderEndOffset.dx - _sliderStartOffset.dx) / 3 +
            _sliderStartOffset.dx)) {
      canvas.drawArc(
          Rect.fromCircle(center: thumb.getPosition(),
              radius: _thumbRadius * 2 / 3),
          pi / 16, 7 * pi / 8, false, smilePaint);
    } else if (thumb
        .getPosition()
        .dx >
        (2 * (_sliderEndOffset.dx - _sliderStartOffset.dx) / 3 +
            _sliderStartOffset.dx)) {
      canvas.drawArc(Rect.fromCircle(center: Offset(
          thumb
              .getPosition()
              .dx, thumb
          .getPosition()
          .dy + _thumbRadius * 5 / 6),
          radius: _thumbRadius * 2 / 3), pi * 5 / 4, pi / 2, false,
          smilePaint);
    } else {
      canvas.drawLine(Offset(thumb
          .getPosition()
          .dx - _thumbRadius / 2,
          thumb
              .getPosition()
              .dy + _thumbRadius / 3), Offset(
          thumb
              .getPosition()
              .dx + _thumbRadius / 2,
          thumb
              .getPosition()
              .dy + _thumbRadius / 3), smilePaint);
    }
    canvas.drawCircle(Offset(thumb
        .getPosition()
        .dx - _thumbRadius / 3,
        thumb
            .getPosition()
            .dy - _thumbRadius / 3), _thumbRadius / 5, Paint()
      ..color = Color.fromRGBO(255, 255, 255, 1.0));
    canvas.drawCircle(Offset(thumb
        .getPosition()
        .dx + _thumbRadius / 3,
        thumb
            .getPosition()
            .dy - _thumbRadius / 3), _thumbRadius / 5, Paint()
      ..color = Color.fromRGBO(255, 255, 255, 1.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Thumb {
  double _radius;
  Offset _position;
  bool _active;

  Thumb(double radius, Offset position) {
    _radius = radius;
    _position = position;
    _active = false;
  }

  bool didHitThumb(Offset hit) {
    return MathUtil.distanceBetween(_position, hit) <= _radius;
  }

  bool isActive() {
    return _active;
  }

  void moveThumb(Offset point) {
    if(_active) {
      _position = point;
    }
  }

  Offset getPosition() {
    return _position;
  }

  void activate() {
    _active = true;
  }

  void deactivate() {
    _active = false;
  }
}