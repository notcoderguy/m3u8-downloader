import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:m3u8_downloader/utils/database_helper.dart';

class Downloader {
  static Future<void> downloadWithFFmpeg(String url, String outputPath) async {
    // Ensure the output directory exists
    final outputDir = Directory(path.dirname(outputPath));
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    // Determine the ffmpeg path based on the environment
    final String ffmpegPath = _getFFmpegPath();

    // Construct the ffmpeg command
    final List<String> args = [
      '-i', url, // Input URL
      '-bsf:a', 'aac_adtstoasc', // Bitstream filter for audio
      '-vcodec', 'copy', // Copy video codec
      '-c', 'copy', // Copy both audio and video
      '-crf', '50', // Constant Rate Factor for quality
      outputPath, // Output file path
    ];

    // Execute the ffmpeg command
    final Process process = await Process.start(ffmpegPath, args);

    // Handle process output and errors
    await Future.wait([
      process.stdout.transform(SystemEncoding().decoder).forEach(stdout.write),
      process.stderr.transform(SystemEncoding().decoder).forEach(stderr.write),
    ]);

    // Wait for the process to complete
    final int exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception('FFmpeg failed with exit code $exitCode');
    }
  }

  static String _getFFmpegPath() {
    // Check if running in debug mode
    if (Platform.environment.containsKey('FLUTTER_TEST') ||
        Platform.environment.containsKey('DEBUG')) {
      return path.join('build', 'windows', 'x64', 'runner', 'Debug', 'ffmpeg', 'ffmpeg.exe');
    }

    // Default to release mode path
    return path.join('windows', 'runner', 'ffmpeg', 'ffmpeg.exe');
  }

  static Future<void> processQueue(DatabaseHelper dbHelper) async {
    // Fetch the first queued download
    final queuedDownload = await dbHelper.getFirstQueuedDownload();
    if (queuedDownload == null) return;

    final String url = queuedDownload['url'];
    final String filePath = queuedDownload['file_path'];

    // Update status to 'downloading'
    await dbHelper.updateDownloadStatus(queuedDownload['id'], 'downloading');

    try {
      // Start the download
      await downloadWithFFmpeg(url, filePath);

      // Update status to 'completed'
      await dbHelper.updateDownloadStatus(queuedDownload['id'], 'completed');
    } catch (e) {
      // Handle errors and update status to 'failed'
      await dbHelper.updateDownloadStatus(queuedDownload['id'], 'failed');
      rethrow;
    }

    // Process the next item in the queue
    await processQueue(dbHelper);
  }

  static double parseProgress(String ffmpegOutput) {
    final RegExp regex = RegExp(r"time=(\d+):(\d+):(\d+\.\d+)");
    final match = regex.firstMatch(ffmpegOutput);

    if (match != null) {
      final hours = double.parse(match.group(1)!);
      final minutes = double.parse(match.group(2)!);
      final seconds = double.parse(match.group(3)!);

      final totalSeconds = hours * 3600 + minutes * 60 + seconds;
      return totalSeconds;
    }

    return 0.0;
  }
}
