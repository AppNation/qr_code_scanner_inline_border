import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class QrScannerOverlayShape extends ShapeBorder {
  QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.borderMargin = 0,
    this.drawInlineBorders = false,
    double? cutOutSize,
    double? cutOutWidth,
    double? cutOutHeight,
    this.cutOutBottomOffset = 0,
  })
      : cutOutWidth = cutOutWidth ?? cutOutSize ?? 250,
        cutOutHeight = cutOutHeight ?? cutOutSize ?? 250 {
    assert(
    borderLength <=
        min(this.cutOutWidth, this.cutOutHeight) / 2 + borderWidth * 2,
    "Border can't be larger than ${min(this.cutOutWidth, this.cutOutHeight) /
        2 + borderWidth * 2}",
    );
    assert(
    (cutOutWidth == null && cutOutHeight == null) ||
        (cutOutSize == null && cutOutWidth != null && cutOutHeight != null),
    'Use only cutOutWidth and cutOutHeight or only cutOutSize');
  }

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutWidth;
  final double cutOutHeight;
  final double cutOutBottomOffset;
  final double borderMargin;
  final bool drawInlineBorders;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )..lineTo(
        rect.left,
        rect.bottom,
      )..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _borderLength =
    borderLength > min(cutOutHeight, cutOutHeight) / 2 + borderWidth * 2
        ? borderWidthSize / 2
        : borderLength;
    final _cutOutWidth =
    cutOutWidth < width ? cutOutWidth : width - borderOffset;
    final _cutOutHeight =
    cutOutHeight < height ? cutOutHeight : height - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final testPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutWidth / 2 + borderOffset,
      -cutOutBottomOffset +
          rect.top +
          height / 2 -
          _cutOutHeight / 2 +
          borderOffset,
      _cutOutWidth - borderOffset * 2,
      _cutOutHeight - borderOffset * 2,
    );

    Offset pointLT = Offset(cutOutRect.left + borderMargin,
        cutOutRect.top + borderMargin);
    Offset pointLB = Offset(cutOutRect.left + borderMargin,
        cutOutRect.top + borderMargin + _borderLength);
    Offset pointLA = Offset(
        cutOutRect.left + borderMargin, cutOutRect.top + borderMargin);

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      ..restore();

    if (!drawInlineBorders) {
      canvas..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - _borderLength,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + _borderLength,
          topRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw top left corner
        ..drawRRect(
          RRect.fromLTRBAndCorners(
            cutOutRect.left,
            cutOutRect.top,
            cutOutRect.left + _borderLength,
            cutOutRect.top + _borderLength,
            topLeft: Radius.circular(borderRadius),
          ),
          borderPaint,
        )
      // Draw bottom right corner
        ..drawRRect(
          RRect.fromLTRBAndCorners(
            cutOutRect.right - _borderLength,
            cutOutRect.bottom - _borderLength,
            cutOutRect.right,
            cutOutRect.bottom,
            bottomRight: Radius.circular(borderRadius),
          ),
          borderPaint,
        )
      // Draw bottom left corner
        ..drawRRect(
          RRect.fromLTRBAndCorners(
            cutOutRect.left,
            cutOutRect.bottom - _borderLength,
            cutOutRect.left + _borderLength,
            cutOutRect.bottom,
            bottomLeft: Radius.circular(borderRadius),
          ),
          borderPaint,
        )..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        boxPaint,
      );
    } else {
      final double r = _borderLength / 2;
      final double w = borderWidth;

      Path rightTopCorner = Path();
      Path leftTopCorner = Path();
      Path leftBottomCorner = Path();
      Path rightBottomCorner = Path();

      final double topRightStartDx = cutOutRect.right - borderMargin -
          _borderLength;
      final double topRightStartDy = cutOutRect.right + borderMargin;

      rightTopCorner.moveTo(cutOutRect.topRight.dx - borderMargin - _borderLength - 2, cutOutRect.topRight.dy + borderMargin);
      rightTopCorner.lineTo(cutOutRect.topRight.dx - borderMargin - r,cutOutRect.topRight.dy + borderMargin);
      rightTopCorner.quadraticBezierTo(
          cutOutRect.topRight.dx - borderMargin, cutOutRect.topRight.dy + borderMargin,
          cutOutRect.topRight.dx - borderMargin, cutOutRect.topRight.dy + borderMargin + r);
      rightTopCorner.lineTo(
          cutOutRect.topRight.dx - borderMargin, cutOutRect.topRight.dy + borderMargin + 2 * r);
      canvas.drawPath(rightTopCorner, borderPaint);

      rightTopCorner.moveTo(topRightStartDx - 2, topRightStartDy);
      leftTopCorner.moveTo(
          cutOutRect.left + borderMargin + _borderLength + 2,
          cutOutRect.top + borderMargin
      );
      leftTopCorner.lineTo(cutOutRect.left + borderMargin + r,
          cutOutRect.top + borderMargin);
      leftTopCorner.quadraticBezierTo(
          cutOutRect.left + borderMargin,
          cutOutRect.top + borderMargin,
          cutOutRect.left + borderMargin, cutOutRect.top + borderMargin + r);
      leftTopCorner.lineTo(
          cutOutRect.topLeft.dx + borderMargin, cutOutRect.topLeft.dy + borderMargin + 2 * r);


      leftBottomCorner.moveTo(
          cutOutRect.left + borderMargin + _borderLength + 2,
          cutOutRect.bottom - borderMargin
      );
      leftBottomCorner.lineTo(cutOutRect.left + borderMargin + r + 2,
          cutOutRect.bottom - borderMargin);
      leftBottomCorner.quadraticBezierTo(
          cutOutRect.left + borderMargin,
          cutOutRect.bottom - borderMargin,
          cutOutRect.left + borderMargin,
          cutOutRect.bottom - borderMargin - r);
      leftBottomCorner.lineTo(cutOutRect.left + borderMargin,
          cutOutRect.bottom - borderMargin - 2 * r);

      rightBottomCorner.moveTo(
          cutOutRect.right - borderMargin - _borderLength - 2,
          cutOutRect.bottom - borderMargin);
      rightBottomCorner.lineTo(cutOutRect.right - borderMargin - r - 2,
          cutOutRect.bottom - borderMargin);
      rightBottomCorner.quadraticBezierTo(
          cutOutRect.right - borderMargin,
          cutOutRect.bottom - borderMargin,
          cutOutRect.right - borderMargin,
          cutOutRect.bottom - borderMargin - r);
      rightBottomCorner.lineTo(cutOutRect.right - borderMargin,
          cutOutRect.bottom - borderMargin - 2 * r);

      canvas.drawPath(leftTopCorner, borderPaint);
      canvas.drawPath(leftBottomCorner, borderPaint);
      canvas.drawPath(rightBottomCorner, borderPaint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
        borderColor: borderColor,
        borderWidth: borderWidth,
        overlayColor: overlayColor,
        borderMargin: borderMargin,
        drawInlineBorders: drawInlineBorders
    );
  }
}