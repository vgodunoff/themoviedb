import 'dart:math';

import 'package:flutter/material.dart';

class CustomPaintWidget extends StatefulWidget {
  const CustomPaintWidget({Key? key}) : super(key: key);

  @override
  State<CustomPaintWidget> createState() => _CustomPaintWidgetState();
}

class _CustomPaintWidgetState extends State<CustomPaintWidget> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: RadialPercentWidget(
            percent: 0.72,
            feelColor: Colors.blue,
            lineColor: Colors.red,
            freeColor: Colors.yellow,
            lineWidth: 5,
            child: Text(
              '72%',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class RadialPercentWidget extends StatelessWidget {
  final Widget child;

  final double percent;
  // - цвет заднего фона
  final Color feelColor;
  //цвет линии/дуги
  final Color lineColor;
  //цвет оставшейся части дуги
  final Color freeColor;
  //толщина дуги
  final double lineWidth;

  const RadialPercentWidget(
      {Key? key,
      required this.child,
      required this.percent,
      required this.feelColor,
      required this.lineColor,
      required this.freeColor,
      required this.lineWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: MyPainter(
              percent: percent,
              feelColor: feelColor,
              lineColor: lineColor,
              lineWidth: lineWidth,
              freeColor: freeColor),
        ),
        Padding(
          padding: const EdgeInsets.all(11.0),
          child: Center(child: child),
        )
      ],
    );
  }
}

class MyPainter extends CustomPainter {
  final double percent;
  // - цвет заднего фона
  final Color feelColor;
  //цвет линии/дуги
  final Color lineColor;
  //цвет оставшейся части дуги
  final Color freeColor;
  //толщина дуги
  final double lineWidth;
//для отрисовки дуги
//добавляем переменную, которая будет обозначать процент от всего круга
// 1.0 - полный круг, 0.5 - полкруга и так далее
//инициализируем со значением 0,72

  //final double percent = 0.72;

  MyPainter(
      {required this.percent,
      required this.feelColor,
      required this.lineColor,
      required this.freeColor,
      required this.lineWidth});
  @override
  void paint(Canvas canvas, Size size) {
    Rect arcRect = calculateArcsRect(size);
//рисуем индикатор на черном фоне

//рисуем фон
    drawBackground(canvas, size);

// рисуем оставшуюся часть дуги, которая будет другим цветом
    drawFreeArc(canvas, arcRect);

// рисуем дугу
    drawFilledArc(canvas, arcRect);
  }

  void drawFilledArc(Canvas canvas, Rect arcRect) {
    final linePaint = Paint();
    linePaint.color = lineColor;
    linePaint.style = PaintingStyle.stroke;
    linePaint.strokeWidth = lineWidth;
    linePaint.strokeCap = StrokeCap.round;

    //рисуем дугу
    //canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint)
    //rect - Offset.zero & size
    //
    //Arc здесь работает в радианах, если градусы у круга от 0 до 360
    // то в Пи 0 до 2Пи
    //а радианы от 0 до ~6,3
    //мы  выставим для нашей дуги начальную точку startAngle 0
    //конечную точку на окружности sweepAngle 3,14 (pi)
    //
    //useCenter - false
    canvas.drawArc(arcRect, 3 * pi / 2, pi * 2 * percent, false, linePaint);
  }

  void drawFreeArc(Canvas canvas, Rect arcRect) {
    final freePaint = Paint();
    freePaint.color = freeColor;
    freePaint.style = PaintingStyle.stroke;
    freePaint.strokeWidth = lineWidth;
    //смещение оставляем такое же как и у зеленой дуги
    // начальная точка должна быть концом зеленой дуги pi * 2 * percent
    //конечное положение дуги определяется не точкой, а длиной
    // то есть если мы укажем Пи, то конец дуги не окажется в точке Пи,
    // а продлится на длину Пи, на 180 градусов, или на полкруга,
    //если поставить sweepAngle (конец дуги) 2Пи, то дуга будет по всей окружности
    canvas.drawArc(arcRect, (3 * pi / 2) + (pi * 2 * percent),
        pi * 2 * (1 - percent), false, freePaint);
  }

  void drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint();
    backgroundPaint.color = feelColor;
    backgroundPaint.style = PaintingStyle.fill;
    //нарисовали черный круг, который полностью вписался в квадрат(наш конт.)
    // canvas.drawCircle(
    //     Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    //вместо canvas.drawCircle можно использовать canvas.drawOval(rect, paint)
    //здесь мы привяжем размер квадрата(конт.) с размером овала
    //так как овал принимает rect
    //и если мы изменим, например высоту квадрата, то и овал также изменится
    canvas.drawOval(Offset.zero & size, backgroundPaint);
  }

  Rect calculateArcsRect(Size size) {
    const linesMargin = 3;
    final offset = lineWidth / 2 + linesMargin;
    final arcRect = Offset(offset, offset) &
        Size(size.width - offset * 2, size.height - offset * 2);
    return arcRect;
  }

  void myPaint(Canvas canvas, Size size) {
// final paint = Paint(); - что-то вроде кисти
    final paint = Paint();
    final paintCircle = Paint();
    paintCircle.color = Colors.indigoAccent;
// PaintingStyle.fill - фигура заливается
//PaintingStyle.stroke; - только контур фигуры
    paintCircle.style = PaintingStyle.fill;
    paint.color = Colors.green;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
// если круг центр расположен в левом верхнем углу квадрата,
//то у ректангла-прямоугольника также  в левом верхнем углу квадрата родителя
//но уже не центр, а свой верх. лев. угол
//а точнее начальная точка диагонали, но не Offset.zero, а нужно учитывать толщину
//контура - то есть  Offset(1, 1)
//нужно делить пополам strokeWidth,
//например paint.strokeWidth = 10, то у дочернего прямоугольника
//должен быть Offset(5, 5)
    canvas.drawRect(const Offset(1, 1) & const Size(30, 30), paint);
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    //canvas.drawCircle(Offset(size.width, 0), 30, paintCircle);
//Offset(size.width / 2, size.height / 2) - центр круга в середине конт.
//по умолчанию центр круга в левом верхнем угле контейнера
//радиус круга size.width / 2 вписывает круг ровно ко всем сторонам конт.
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 30, paintCircle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
