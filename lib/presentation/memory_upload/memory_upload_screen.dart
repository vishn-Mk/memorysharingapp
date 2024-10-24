import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class MemoryUploadScreen extends StatefulWidget {
  @override
  _MemoryUploadScreenState createState() => _MemoryUploadScreenState();
}

class _MemoryUploadScreenState extends State<MemoryUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _mediaFile;
  final TextEditingController _titleController = TextEditingController();
  String _mediaType = '';

  // Audio Recorder variables
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<String> _getFilePath() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    return '${tempDir.path}/audio_record.aac';
  }

  // Audio recording functions
  void _startRecording() async {
    String filePath = await _getFilePath();
    await _recorder!.startRecorder(toFile: filePath);
    setState(() {
      _isRecording = true;
      _recordedFilePath = filePath;
    });
  }

  void _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _mediaFile = File(_recordedFilePath!);
      _mediaType = 'audio';
    });
  }

  void _playRecording() async {
    if (_recordedFilePath != null) {
      await _player!.startPlayer(
        fromURI: _recordedFilePath,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _pausePlaying() async {
    await _player!.pausePlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _saveMemory() async {
    if (_mediaFile != null && _titleController.text.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> memories = prefs.getStringList('memories') ?? [];
      final directory = await getApplicationDocumentsDirectory();
      final mediaDirectory = Directory('${directory.path}/$_mediaType');
      if (!await mediaDirectory.exists()) {
        await mediaDirectory.create(recursive: true);
      }
      final newPath = '${mediaDirectory.path}/${_mediaFile!.path.split('/').last}';
      await _mediaFile!.copy(newPath);
      memories.add('${_titleController.text}|$newPath|$_mediaType');
      prefs.setStringList('memories', memories);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Memory', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share a new memory',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Memory Title',
                labelStyle: TextStyle(fontSize: 16, color: Colors.black),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Pick or record media', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMediaButton(Icons.photo, 'Image', _pickImage),
                _buildMediaButton(Icons.videocam, 'Video', _pickVideo),
                _buildMediaButton(Icons.audiotrack, 'Audio', _pickAudio),
                _buildMediaButton(Icons.mic, 'Record', _isRecording ? _stopRecording : _startRecording),
              ],
            ),
            SizedBox(height: 30),
            _mediaFile != null
                ? _mediaType == 'image'
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_mediaFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
            )
                : Text(
              'Media selected: $_mediaType',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            )
                : Text('No media selected', style: TextStyle(color: Colors.grey, fontSize: 16)),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveMemory,
                icon: Icon(Icons.save, color: Colors.white),
                label: Text('Save Memory', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: Colors.grey[850],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton(IconData icon, String label, Function() onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple.withOpacity(0.1),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 30),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.deepPurple, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _mediaFile = File(image.path);
        _mediaType = 'image';
      }
    });
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      if (video != null) {
        _mediaFile = File(video.path);
        _mediaType = 'video';
      }
    });
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    setState(() {
      if (result != null) {
        _mediaFile = File(result.files.single.path!);
        _mediaType = 'audio';
      }
    });
  }
}
