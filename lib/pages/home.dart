import 'package:flutter/material.dart';
import '../components/sidebar.dart';
import '../utils/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Row(
          children: [
            const Sidebar(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'M3U8 Downloader',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'MonaSans',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 400,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.white),
                              cursorColor:
                                  Colors
                                      .grey[700], // shadcn compatible cursor color
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[900],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey[800]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color:
                                        Colors
                                            .grey[700]!, // shadcn compatible color
                                    width: 1.5,
                                  ),
                                ),
                                labelText: 'Enter URL',
                                labelStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontFamily: 'MonaSans',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.grey[700]!,
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () async {
                                if (_controller.text.isNotEmpty) {
                                  await _dbHelper.insertDownload({
                                    'url': _controller.text,
                                    'file_path': '',
                                    'created_at': DateTime.now().toIso8601String(),
                                    'status': 'queued'
                                  });
                                  _controller.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Download added to queue'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
