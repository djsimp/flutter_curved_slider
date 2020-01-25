import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _positionValue = 0;
  int _sliderStartValue = 0;
  int _sliderEndValue = 100;
  double _sliderStartX = 50;
  double _sliderStartY = 50;
  double _sliderEndX = 330;
  double _sliderEndY = 50;
  double _positionX = 50;
  double _positionY = 50;
  double _thumbRadius = 30;
  bool _isActive = false;

  double distanceBetween(Offset touchPosition, Offset currentPosition) {
    return sqrt(pow((currentPosition.dx - touchPosition.dx),2)+pow((currentPosition.dy - touchPosition.dy),2));
  }

  void activateSlider(PointerDownEvent event) {
    if(distanceBetween(event.localPosition, Offset(_positionX,_positionY)) <= _thumbRadius) {
      setState(() {
        _isActive = true;
      });
    }
  }

  void deactivateSlider(PointerUpEvent event) {
    setState(() {
      _isActive = false;
    });
  }

  void moveSlider(PointerMoveEvent event) {
    if(_isActive && event.localPosition.dx >= _sliderStartX && event.localPosition.dx <= _sliderEndX) {
      setState(() {
        _positionX = event.localPosition.dx;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent;
        child: Column(
          children: [Listener(
          onPointerDown: activateSlider,
          onPointerMove: moveSlider,
          onPointerUp: deactivateSlider,
          child: Container(
            width: 380,
            height: 100,
            color: Color.fromRGBO(230, 230, 230, 1.0),
            child: CustomPaint(
              painter: _MySliderPainter(
                  Offset(_positionX, _positionY), _thumbRadius,
                  Offset(_sliderStartX, _sliderStartY),
                  Offset(_sliderEndX, _sliderEndY)),
            ),
          ),
        ),
            Text('$_positionX')
        ]
        ),
      ),
    );
  }
}

class _MySliderPainter extends CustomPainter {
  Offset _thumbOffset;
  double _thumbRadius;
  Offset _sliderStartOffset;
  Offset _sliderEndOffset;

  _MySliderPainter(Offset thumbOffset, double thumbRadius, Offset sliderStartOffset, Offset sliderEndOffset) {
    _thumbOffset = thumbOffset;
    _thumbRadius = thumbRadius;
    _sliderStartOffset = sliderStartOffset;
    _sliderEndOffset = sliderEndOffset;
  }

  Offset getThumbOffset() {
    return _thumbOffset;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final sliderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawLine(_sliderStartOffset,_sliderEndOffset,sliderPaint);
    final sliderEndsPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(0, 0, 0, 1.0);
    canvas.drawCircle(_sliderStartOffset,10,sliderEndsPaint);
    canvas.drawCircle(_sliderEndOffset,10,sliderEndsPaint);
    double red = 0;
    double green = 0;
    double blue = 0;
    if(_thumbOffset.dx <= 190) {
      red = 0;
      green = 255*(1-2*(_thumbOffset.dx-_sliderStartOffset.dx)/(_sliderEndOffset.dx-_sliderStartOffset.dx));
      blue = 255*2*(_thumbOffset.dx-_sliderStartOffset.dx)/(_sliderEndOffset.dx-_sliderStartOffset.dx);
    } else {
      red = 255*(2*_thumbOffset.dx-_sliderEndOffset.dx-_sliderStartOffset.dx)/(_sliderEndOffset.dx-_sliderStartOffset.dx);
      green = 0;
      blue = 255*(2-(2*_thumbOffset.dx-_sliderEndOffset.dx-_sliderStartOffset.dx))/(_sliderEndOffset.dx-_sliderStartOffset.dx);
    }
    final thumbPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(red.round(), green.round(), blue.round(), 1.0);
    canvas.drawCircle(_thumbOffset,_thumbRadius,thumbPaint);
    final smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Color.fromRGBO(255, 255, 255, 1.0);
    if(_thumbOffset.dx <= ((_sliderEndOffset.dx - _sliderStartOffset.dx)/3 + _sliderStartOffset.dx)) {
      canvas.drawArc(
          Rect.fromCircle(center: _thumbOffset, radius: _thumbRadius * 2 / 3),
          pi / 16, 7 * pi / 8, false, smilePaint);
    } else if(_thumbOffset.dx > (2*(_sliderEndOffset.dx - _sliderStartOffset.dx)/3 + _sliderStartOffset.dx)) {
      canvas.drawArc(Rect.fromCircle(center: Offset(_thumbOffset.dx,_thumbOffset.dy+_thumbRadius*5/6),radius: _thumbRadius*2/3),pi*5/4,pi/2,false,smilePaint);
    } else {
      canvas.drawLine(Offset(_thumbOffset.dx-_thumbRadius/2,_thumbOffset.dy+_thumbRadius/3),Offset(_thumbOffset.dx+_thumbRadius/2,_thumbOffset.dy+_thumbRadius/3),smilePaint);
    }
    canvas.drawCircle(Offset(_thumbOffset.dx-_thumbRadius/3,_thumbOffset.dy-_thumbRadius/3),_thumbRadius/5,Paint()..color = Color.fromRGBO(255, 255, 255, 1.0));
    canvas.drawCircle(Offset(_thumbOffset.dx+_thumbRadius/3,_thumbOffset.dy-_thumbRadius/3),_thumbRadius/5,Paint()..color = Color.fromRGBO(255, 255, 255, 1.0));

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}
