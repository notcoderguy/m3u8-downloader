import 'package:flutter/material.dart';
import 'dart:async';
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
                  Text(
                    'Downloads',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MonaSans',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                              return ListTile(
                                title: Text(
                                  download['url'] ?? 'Unknown',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Status: ${download['status']}',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                trailing: SizedBox(
                                  width: 150,
                                  child: LinearProgressIndicator(
                                    value: download['status'] == 'completed' ? 1.0 : 0.5,
                                    backgroundColor: Colors.grey[800],
                                    color: download['status'] == 'completed' 
                                      ? Colors.green 
                                      : Colors.orange,
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
