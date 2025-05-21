import 'package:flutter/material.dart';
import '../components/sidebar.dart';
import '../utils/database_helper.dart';
import 'package:path/path.dart' as path;
import '../utils/downloader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
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
                    _buildTitle(),
                    const SizedBox(height: 32),
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'M3U8 Downloader',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'MonaSans',
        color: Colors.white,
      ),
    );
  }

  Widget _buildForm() {
    return SizedBox(
      width: 400,
      child: Column(
        children: [
          _buildTextField(
            controller: _urlController,
            labelText: 'Enter URL',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _fileNameController,
            labelText: 'Enter File Name',
          ),
          const SizedBox(height: 16),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.grey[700],
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
            color: Colors.grey[700]!,
            width: 1.5,
          ),
        ),
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey[500],
          fontFamily: 'MonaSans',
        ),
      ),
      onSubmitted: (_) => _handleAddToQueue(), // Trigger on Enter key press
    );
  }

  Widget _buildSubmitButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
              onPressed: _handleAddToQueue,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAddToQueue() async {
    if (_urlController.text.isNotEmpty && _fileNameController.text.isNotEmpty) {
      // Fetch settings from the database
      final String? outputFolder = await _dbHelper.getSetting('output_folder');
      final String? fileExtension = await _dbHelper.getSetting('file_extension');

      if (outputFolder == null || fileExtension == null) {
        _showSnackBar('Settings are not properly configured.');
        return;
      }

      // Construct the full file path
      final String filePath = path.join(outputFolder, '${_fileNameController.text}$fileExtension');

      await _dbHelper.insertDownload({
        'url': _urlController.text,
        'file_path': filePath,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'queued',
      });

      // Clear controllers and show snack bar immediately
      _urlController.clear();
      _fileNameController.clear();
      _showSnackBar('Download added to queue');

      // Process the queue asynchronously
      Downloader.processQueue(_dbHelper);
    } else {
      _showSnackBar('Please fill in all fields');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}