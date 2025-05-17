import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart'; // Add this import
import '../components/sidebar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _outputFolder = '';
  String _fileExtension = '.mp4';
  int _threadCount = 4;
  final TextEditingController _threadCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initOutputFolder();
    _threadCountController.text = _threadCount.toString();
  }

  @override
  void dispose() {
    _threadCountController.dispose();
    super.dispose();
  }

  Future<void> _initOutputFolder() async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      setState(() {
        _outputFolder = path.join(downloadsDir.path, 'm3u8-downloader');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicSettings(),
                  const SizedBox(height: 32),
                  _buildAdvancedSettings(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Basic Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed:
                  _resetBasicSettings, // <-- Fix: should reset basic settings
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Output Folder',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                controller: TextEditingController(text: _outputFolder),
                readOnly: true,
              ),
            ),
            IconButton(
              icon: Icon(Icons.folder_open, color: Colors.white),
              tooltip: 'Select Folder',
              onPressed: _pickOutputFolder,
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'File Extension',
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          dropdownColor: Colors.grey[900],
          value: _fileExtension,
          items: const [
            DropdownMenuItem(
              value: '.mp4',
              child: Text('MP4', style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: '.mkv',
              child: Text('MKV', style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: '.ts',
              child: Text('TS', style: TextStyle(color: Colors.white)),
            ),
          ],
          onChanged: (value) => setState(() => _fileExtension = value!),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Advanced Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: _resetAdvancedSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange),
          ),
          child: Text(
            'Warning: Only modify these settings if you know what you\'re doing!',
            style: TextStyle(color: Colors.orange),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Thread Count',
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          controller: _threadCountController, // <-- use controller
          onChanged: (value) {
            final count = int.tryParse(value) ?? 4;
            setState(() => _threadCount = count.clamp(1, 8));
          },
        ),
      ],
    );
  }

  Future<void> _pickOutputFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _outputFolder = selectedDirectory;
      });
    }
  }

  void _resetBasicSettings() {
    _initOutputFolder();
    setState(() {
      _fileExtension = '.mp4';
    });
  }

  void _resetAdvancedSettings() {
    setState(() {
      _threadCount = 4;
      _threadCountController.text = '4'; // <-- update controller
    });
  }
}
