import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/features/profile/presentation/avatar_crop_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const landscape = Size(2000, 1000);

  test('centered image at scale 1 crops the middle square', () {
    // Viewport 300: the image is shown 600x300, centered at x = -150.
    final rect = avatarCropRect(
      imageSize: landscape,
      viewport: 300,
      transform: Matrix4.translationValues(-150, 0, 0),
    );
    expect(rect, const Rect.fromLTWH(500, 0, 1000, 1000));
  });

  test('zoom narrows the crop and panning moves it', () {
    final transform = Matrix4.translationValues(-300, -150, 0)
      ..multiply(Matrix4.diagonal3Values(2, 2, 1));
    final rect = avatarCropRect(
      imageSize: landscape,
      viewport: 300,
      transform: transform,
    );
    expect(rect.width, 500);
    expect(rect.height, 500);
    expect(rect.left, 500);
    expect(rect.top, 250);
  });

  test('crop never leaves the image', () {
    final rect = avatarCropRect(
      imageSize: landscape,
      viewport: 300,
      transform: Matrix4.translationValues(-5000, 400, 0),
    );
    expect(rect.left, 1000);
    expect(rect.top, 0);
    expect(rect.right, landscape.width);
  });

  test('renders a square PNG within the upload limit', () async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(
      const Rect.fromLTWH(0, 0, 40, 20),
      Paint()..color = Colors.teal,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(40, 20);
    final bytes = await renderAvatarPng(
      image,
      const Rect.fromLTWH(10, 0, 20, 20),
      size: 64,
    );
    expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    expect(bytes.length, lessThan(2500000));
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 64);
    expect(frame.image.height, 64);
  });
}
