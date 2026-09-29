import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A 640px RGBA PNG is at most ~1.7 MB, so the output always fits the
/// backend's 2.5 MB avatar limit without a quality loop.
const avatarOutputSize = 640;

/// The square of the image, in image pixels, that is visible in a square
/// viewport of side [viewport] after [transform] (from InteractiveViewer).
/// At scale 1 the image's shorter side exactly fills the viewport.
Rect avatarCropRect({
  required Size imageSize,
  required double viewport,
  required Matrix4 transform,
}) {
  final shortest = math.min(imageSize.width, imageSize.height);
  final pixelsPerPoint = shortest / viewport;
  final scale = transform.getMaxScaleOnAxis();
  final translation = transform.getTranslation();
  final side = math.min(shortest, viewport / scale * pixelsPerPoint);
  final left = (-translation.x / scale * pixelsPerPoint).clamp(
    0.0,
    imageSize.width - side,
  );
  final top = (-translation.y / scale * pixelsPerPoint).clamp(
    0.0,
    imageSize.height - side,
  );
  return Rect.fromLTWH(left, top, side, side);
}

Future<Uint8List> renderAvatarPng(
  ui.Image image,
  Rect source, {
  int size = avatarOutputSize,
}) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawImageRect(
    image,
    source,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    Paint()..filterQuality = FilterQuality.high,
  );
  final picture = recorder.endRecording();
  final output = await picture.toImage(size, size);
  picture.dispose();
  try {
    final data = await output.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  } finally {
    output.dispose();
  }
}

/// Square avatar crop with pan and pinch-zoom. Pops with PNG bytes, or null
/// when cancelled.
class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({required this.imageBytes, super.key});

  final Uint8List imageBytes;

  static Future<Uint8List?> open(BuildContext context, Uint8List bytes) =>
      Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AvatarCropScreen(imageBytes: bytes),
        ),
      );

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  final _transform = TransformationController();
  ui.Image? _image;
  double? _viewport;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.imageBytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() => _image = frame.image);
    } catch (_) {
      if (mounted) setState(() => _error = 'Không đọc được ảnh này.');
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    _transform.dispose();
    super.dispose();
  }

  Size _childSize(ui.Image image, double viewport) {
    final base = viewport / math.min(image.width, image.height);
    return Size(image.width * base, image.height * base);
  }

  void _center(ui.Image image, double viewport) {
    final child = _childSize(image, viewport);
    _transform.value = Matrix4.translationValues(
      -(child.width - viewport) / 2,
      -(child.height - viewport) / 2,
      0,
    );
  }

  Future<void> _confirm() async {
    final image = _image;
    final viewport = _viewport;
    if (image == null || viewport == null || _busy) return;
    setState(() => _busy = true);
    try {
      final rect = avatarCropRect(
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
        viewport: viewport,
        transform: _transform.value,
      );
      final bytes = await renderAvatarPng(image, rect);
      if (mounted) Navigator.of(context).pop(bytes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không cắt được ảnh. Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Cắt ảnh đại diện'),
        actions: [
          TextButton(
            key: const Key('avatar-crop-confirm'),
            onPressed: image == null || _busy ? null : _confirm,
            child: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Xong'),
          ),
        ],
      ),
      body: SafeArea(
        child: _error != null
            ? Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : image == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final viewport =
                            math.min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ) -
                            32;
                        if (_viewport != viewport) {
                          final first = _viewport == null;
                          _viewport = viewport;
                          if (first) {
                            _center(image, viewport);
                          } else {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _center(image, viewport),
                            );
                          }
                        }
                        final child = _childSize(image, viewport);
                        return Center(
                          child: SizedBox.square(
                            dimension: viewport,
                            child: Stack(
                              children: [
                                ClipRect(
                                  child: InteractiveViewer(
                                    transformationController: _transform,
                                    constrained: false,
                                    minScale: 1,
                                    maxScale: 6,
                                    child: SizedBox(
                                      width: child.width,
                                      height: child.height,
                                      child: RawImage(
                                        image: image,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                const IgnorePointer(
                                  child: CustomPaint(
                                    size: Size.infinite,
                                    painter: _CircleGuidePainter(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Text(
                      'Kéo để di chuyển, chụm hai ngón để phóng to.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CircleGuidePainter extends CustomPainter {
  const _CircleGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final circle = Path()..addOval(bounds);
    final shade = Path.combine(
      PathOperation.difference,
      Path()..addRect(bounds),
      circle,
    );
    canvas.drawPath(shade, Paint()..color = Colors.black54);
    canvas.drawPath(
      circle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white70,
    );
  }

  @override
  bool shouldRepaint(_CircleGuidePainter oldDelegate) => false;
}
