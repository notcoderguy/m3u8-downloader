import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../components/sidebar.dart';
import 'package:m3u8_downloader/utils/database_helper.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<Map<String, dynamic>> _downloads = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _loadDownloads();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDownloads() async {
    final downloads = await _dbHelper.getDownloads();
    setState(() {
      _downloads = downloads;
    });
  }

  Future<void> _clearAllDownloads() async {
    await _dbHelper.clearDownloads();
    setState(() {
      _downloads.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Row(
          children: [
            const Sidebar(),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Downloads',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'MonaSans',
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _clearAllDownloads,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _downloads.isEmpty
                        ? const Center(
                            child: Text(
                              'No downloads available',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _downloads.length,
                            itemBuilder: (context, index) {
                              final download = _downloads[index];
                              final isDownloading = download['status'] == 'downloading';
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                color: Colors.grey[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        download['url'] ?? 'Unknown',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Status: ${download['status']}',
                                            style: TextStyle(color: Colors.grey[400]),
                                          ),
                                          if (isDownloading)
                                            ElevatedButton(
                                              onPressed: () async {
                                                // Stop download logic
                                                if (download['status'] == 'downloading') {
                                                  await _dbHelper.updateDownloadStatus(download['id'], 'stopped');
                                                  setState(() {
                                                    download['status'] = 'stopped';
                                                  });
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Stop',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (download['status'] == 'failed')
                                        LinearProgressIndicator(
                                          value: 1.0, // Static progress for failed downloads
                                          backgroundColor: Colors.grey[800],
                                          color: Colors.red,
                                        )
                                      else if (isDownloading)
                                        LinearProgressIndicator(
                                          value: null, // Animated indeterminate progress for downloading
                                          backgroundColor: Colors.grey[800],
                                          color: Colors.white,
                                        )
                                      else if (download['status'] == 'stopped')
                                        LinearProgressIndicator(
                                          value: 0.0, // Static progress for stopped downloads
                                          backgroundColor: Colors.grey[800],
                                          color: Colors.grey,
                                        )
                                      else
                                        LinearProgressIndicator(
                                          value: download['status'] == 'completed' ? 1.0 : null,
                                          backgroundColor: Colors.grey[800],
                                          color: Colors.green,
                                        ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Open file logic
                                              final filePath = download['file_path'];
                                              if (filePath != null) {
                                                await Process.run('explorer', [filePath]);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Open File',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Open folder logic
                                              final folderPath = path.dirname(download['file_path']);
                                              await Process.run('explorer', [folderPath]);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Open Folder',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Delete file logic
                                              final filePath = download['file_path'];
                                              if (filePath != null) {
                                                final file = File(filePath);
                                                if (await file.exists()) {
                                                  await file.delete();
                                                }
                                                await _dbHelper.deleteDownload(download['id']);
                                                setState(() {
                                                  _downloads.removeAt(index);
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
