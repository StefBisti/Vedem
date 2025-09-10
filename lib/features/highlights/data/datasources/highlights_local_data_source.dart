import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/highlights/data/datasources/highlights_data_source.dart';
import 'package:vedem/features/highlights/data/models/highlight_model.dart';
import 'package:image/image.dart' as img;

class HighlightsLocalDataSource implements HighlightsDataSource {
  final Box<HighlightModel> box;

  const HighlightsLocalDataSource({required this.box});

  @override
  Future<List<HighlightModel>> readAllHighlightsMetadata() async {
    try {
      final List<HighlightModel> highlights = box.values.toList();
      return highlights;
    } catch (e) {
      debugPrint(e.toString());
      throw LocalHiveException(message: loadHighlightsError);
    }
  }

  @override
  Future<List<HighlightModel>> readMonthHighlightsMetadata(
    String monthId,
  ) async {
    try {
      final List<HighlightModel> highlights = box.keys
          .where((k) => k.toString().startsWith(monthId))
          .map((k) => box.get(k)!)
          .toList();
      return highlights;
    } catch (e) {
      debugPrint(e.toString());
      throw LocalHiveException(message: loadHighlightsError);
    }
  }

  @override
  Future<Unit> writeHighlightMetadataForDay(
    HighlightModel highlight,
    String dayId,
  ) async {
    try {
      box.put(dayId, highlight);
      return unit;
    } catch (e) {
      debugPrint(e.toString());
      throw LocalHiveException(message: loadHighlightsError);
    }
  }

  @override
  Future<Unit> deleteHighlightMetadataForDay(String dayId) async {
    try {
      box.delete(dayId);
      return unit;
    } catch (e) {
      debugPrint(e.toString());
      throw LocalHiveException(message: saveHighlightError);
    }
  }

  @override
  Future<Unit> generateVariantsForHighlight(
    String currentImagePath,
    String headerImagePath,
    String carouselImagePath,
    String galleryImagePath,
  ) async {
    try {
      final bytes = await File(currentImagePath).readAsBytes();

      const headerSize = 1024;
      const carouselSize = 256;
      const gallerySize = 20;

      final results = await Future.wait<Uint8List>([
        compute(_generateVariant, {
          'data': bytes,
          'targetWidth': headerSize,
          'quality': 85,
        }),
        compute(_generateVariant, {
          'data': bytes,
          'targetWidth': carouselSize,
          'quality': 85,
        }),
        compute(_generateVariant, {
          'data': bytes,
          'targetWidth': gallerySize,
          'quality': 85,
        }),
      ]);

      final headerBytes = results[0];
      final carouselBytes = results[1];
      final galleryBytes = results[2];

      Future<void> atomicWrite(String path, Uint8List data) async {
        final file = File(path);
        await file.parent.create(recursive: true);
        final tempPath = '$path.tmp';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(data, flush: true);
        if (await file.exists()) {
          await file.delete();
        }
        await tempFile.rename(path);
      }

      await atomicWrite(headerImagePath, headerBytes);
      await atomicWrite(carouselImagePath, carouselBytes);
      await atomicWrite(galleryImagePath, galleryBytes);

      return unit;
    } catch (e) {
      debugPrint(e.toString());
      throw ImageProcessingException(message: imageProcessingError);
    }
  }

  static Future<Uint8List> _generateVariant(Map<String, dynamic> params) async {
    final Uint8List data = params['data'] as Uint8List;
    final int targetWidth = params['targetWidth'] as int;
    final int jpegQuality = params['quality'] as int? ?? 85;

    final img.Image? src = img.decodeImage(data);
    if (src == null) {
      throw ImageProcessingException(message: imageProcessingError);
    }

    final img.Image resized = img.copyResize(
      src,
      width: targetWidth,
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: jpegQuality));
  }

  @override
  Future<Unit> deleteVariantsForHighlight(
    String headerImagePath,
    String carouselImagePath,
    String galleryImagePath,
  ) async {
    try {
      Future<void> safeDelete(String path) async {
        try {
          final file = File(path);
          if (await file.exists()) await file.delete();
          final tmp = File('$path.tmp');
          if (await tmp.exists()) await tmp.delete();
        } catch (e) {
          debugPrint('Failed to delete "$path": $e');
        }
      }

      await Future.wait([
        safeDelete(headerImagePath),
        safeDelete(carouselImagePath),
        safeDelete(galleryImagePath),
      ]);

      return unit;
    } catch (e) {
      debugPrint(e.toString());
      throw ImageProcessingException(message: imageProcessingError);
    }
  }

  @override
  Future<Uint8List> getVariantForHighlight(String path) async {
    try {
      Uint8List decoded = await File(path).readAsBytes();
      return decoded;
    } catch (e) {
      debugPrint(e.toString());
      throw ImageProcessingException(message: imageProcessingError);
    }
  }
}
