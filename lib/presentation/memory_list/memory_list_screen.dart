import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

import '../memory_upload/memory_upload_screen.dart';

class MemoryListScreen extends StatefulWidget {
  @override
  _MemoryListScreenState createState() => _MemoryListScreenState();
}

class _MemoryListScreenState extends State<MemoryListScreen> {
  List<Map<String, String>> _memories = [];
  List<Map<String, String>> _filteredMemories = [];
  AudioPlayer? _audioPlayer;
  String? _playingAudioPath;
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMemories();
    _audioPlayer = AudioPlayer();
    _titleController.addListener(_filterMemories);
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadMemories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedMemories = prefs.getStringList('memories') ?? [];

    setState(() {
      _memories = savedMemories.map((memory) {
        final data = memory.split('|');
        return {'title': data[0], 'path': data[1], 'type': data[2]};
      }).toList();
      _filteredMemories = _memories; // Initial display
    });
  }

  void _filterMemories() {
    setState(() {
      String query = _titleController.text.toLowerCase();
      _filteredMemories = _memories.where((memory) {
        return memory['title']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _deleteMemory(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedMemories = prefs.getStringList('memories') ?? [];

    String filePath = _filteredMemories[index]['path']!;
    File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    savedMemories.removeAt(index);
    await prefs.setStringList('memories', savedMemories);

    _loadMemories();
  }

  @override
  Widget _buildMemoryItem(Map<String, String> memory, int index) {
    return GestureDetector(
      onTap: () {
        if (memory['type'] == 'image') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImageViewer(
                imageFile: File(memory['path']!),
                index: index,
                onDelete: (delIndex) => _deleteMemory(delIndex),
              ),
            ),
          );
        } else if (memory['type'] == 'video') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenVideoPlayer(
                videoFile: File(memory['path']!),
                index: index,
                onDelete: (delIndex) => _deleteMemory(delIndex),
              ),
            ),
          );
        } else if (memory['type'] == 'audio') {
          if (_playingAudioPath == memory['path']) {
            _stopAudio();
          } else {
            _playAudio(memory['path']!);
          }
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Expanded(
              child: (memory['type'] == 'image')
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.file(
                  File(memory['path']!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : (memory['type'] == 'video')
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: VideoPlayerWidget(videoFile: File(memory['path']!)),
              )
                  : Icon(Icons.audiotrack, size: 80, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                memory['title']!,
                style: TextStyle(
                  fontFamily: 'Merriweather',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (memory['type'] == 'audio' && _playingAudioPath == memory['path'])
              IconButton(
                icon: Icon(Icons.stop, color: Colors.red),
                onPressed: _stopAudio,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _playAudio(String filePath) async {
    await _audioPlayer?.setSourceDeviceFile(filePath);
    await _audioPlayer?.resume();
    setState(() {
      _playingAudioPath = filePath;
    });
  }

  Future<void> _stopAudio() async {
    await _audioPlayer?.stop();
    setState(() {
      _playingAudioPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Memories',
            style: TextStyle(
              color: Colors.deepPurple,
              fontFamily: 'Oswald',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 6,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Search Memories',
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                ), prefixIcon: Icon(
                Icons.search,
                color: Colors.deepPurple, // Search icon color
              ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredMemories.length,
              itemBuilder: (context, index) {
                return _buildMemoryItem(_filteredMemories[index], index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: SizedBox(
            height: 70,
            width: 70,
            child: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MemoryUploadScreen()),
                );
                _loadMemories();
              },
              tooltip: 'Upload Memory',
              backgroundColor: Colors.grey[200],
              elevation: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple[400]!, Colors.deepPurple[900]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class FullScreenImageViewer extends StatelessWidget {
  final File imageFile;
  final int index;
  final Function(int) onDelete;

  const FullScreenImageViewer({
    required this.imageFile,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Memory'),
                  content: Text('Are you sure you want to delete this memory?'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        onDelete(index);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final File videoFile;
  final int index;
  final Function(int) onDelete;

  const FullScreenVideoPlayer({
    required this.videoFile,
    required this.index,
    required this.onDelete,
  });

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
          _isPlaying = true;
        });
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _isPlaying = false;  // Video has finished playing
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Memory'),
                  content: Text('Are you sure you want to delete this memory?'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        widget.onDelete(widget.index);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _isInitialized
            ? GestureDetector(
          onTap: _togglePlayPause,  // Toggle play/pause on tap
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              if (!_isPlaying)
                Icon(Icons.play_arrow, size: 50, color: Colors.white),
            ],
          ),
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}


class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;

  const VideoPlayerWidget({required this.videoFile});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: _isInitialized
          ? Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            IconButton(
              icon: Icon(Icons.play_arrow, size: 50, color: Colors.white),
              onPressed: () {
                setState(() {
                  _controller.play();
                });
              },
            ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
