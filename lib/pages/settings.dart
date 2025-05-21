import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import '../components/sidebar.dart';
import '../utils/database_helper.dart';

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
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load output folder
    final downloadsDir = await getDownloadsDirectory();
    String defaultOutputFolder = '';
    if (downloadsDir != null) {
      defaultOutputFolder = path.join(downloadsDir.path, 'm3u8-downloader');
    }

    // Load saved settings from database
    final fileExt = await _dbHelper.getSetting('file_extension');
    final threadCount = await _dbHelper.getSetting('thread_count');
    final outputFolder = await _dbHelper.getSetting('output_folder');

    if (mounted) {
      setState(() {
        _fileExtension = fileExt ?? '.mp4';
        _threadCount = int.tryParse(threadCount ?? '4') ?? 4;
        _outputFolder = outputFolder ?? defaultOutputFolder;
        _threadCountController.text = _threadCount.toString();
      });
    }
  }

  @override
  void dispose() {
    _threadCountController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    await _dbHelper.insertSetting('file_extension', _fileExtension);
    await _dbHelper.insertSetting('thread_count', _threadCount.toString());
    await _dbHelper.insertSetting('output_folder', _outputFolder);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _initOutputFolder() async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      final defaultOutputFolder = path.join(downloadsDir.path, 'm3u8-downloader');
      if (mounted) {
        setState(() {
          _outputFolder = defaultOutputFolder;
        });
      }
    }
  }

  Future<void> _pickOutputFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      if (mounted) {
        setState(() {
          _outputFolder = selectedDirectory;
        });
      }
      await _dbHelper.insertSetting('output_folder', selectedDirectory);
    }
  }

  void _resetBasicSettings() async {
    await _initOutputFolder();
    if (mounted) {
      setState(() {
        _fileExtension = '.mp4';
      });
    }
    await _dbHelper.insertSetting('file_extension', '.mp4');
    await _dbHelper.insertSetting('output_folder', _outputFolder);
  }

  void _resetAdvancedSettings() async {
    if (mounted) {
      setState(() {
        _threadCount = 4;
        _threadCountController.text = '4';
      });
    }
    await _dbHelper.insertSetting('thread_count', '4');
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
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
                children: [
                  _buildBasicSettings(),
                  const SizedBox(height: 32),
                  _buildAdvancedSettings(),
                  const SizedBox(height: 32),
                  ElevatedButton( // Move button to the left
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Save Settings'),
                  ),
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
              onPressed: _resetBasicSettings,
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
          onChanged: (value) {
            if (value != null) {
              setState(() => _fileExtension = value);
            }
          },
        ),
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
          controller: _threadCountController,
          onChanged: (value) {
            final count = int.tryParse(value) ?? 4;
            setState(() => _threadCount = count.clamp(1, 8));
          },
        ),
      ],
    );
  }
}