import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoScreen extends StatefulWidget {
  final String filename;

  const VideoScreen({super.key, required this.filename});

  @override
  State<VideoScreen> createState() => _CustomVlcPlayerState();
}

class _CustomVlcPlayerState extends State<VideoScreen> {
  late VlcPlayerController _controller;
  bool _controlsVisible = true;
  double _currentPosition = 0;
  double _videoDuration = 0;
  Timer? _progressTimer;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    final encodedUrl = Uri.encodeFull('http://172.22.0.20:56486/api/v1/storage/stream/${widget.filename}');
    _controller = VlcPlayerController.network(encodedUrl);

    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      final duration = await _controller.getDuration();
      final position = await _controller.getPosition();

      setState(() {
        _videoDuration = duration.inMilliseconds.toDouble();
        _currentPosition = position.inMilliseconds.toDouble();
      });
    });

    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _controlsVisible = false;
      });
    });
  }

  void _onUserInteraction() {
    setState(() {
      _controlsVisible = true;
    });
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _hideControlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  Future<void> _rewind10() async {
    final position = await _controller.getPosition();
    if (position != null) {
      int newTime = position.inMilliseconds - 10000;
      if (newTime < 0) newTime = 0;
      _controller.setTime(newTime);
      setState(() {
        _currentPosition = newTime.toDouble();
      });
    }
  }

  Future<void> _forward10() async {
    final position = await _controller.getPosition();
    final duration = await _controller.getDuration();
    if (position != null && duration != null) {
      int newTime = position.inMilliseconds + 10000;
      if (newTime > duration.inMilliseconds) {
        newTime = duration.inMilliseconds;
      }
      _controller.setTime(newTime);
      setState(() {
        _currentPosition = newTime.toDouble();
      });
    }
  }

  void _onSliderChanged(double value) {
    _controller.setTime(value.toInt());
    setState(() {
      _currentPosition = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onUserInteraction,
        child: Stack(
          children: [
            Center(
              child: VlcPlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            ),
            if (_controlsVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10, color: Colors.white),
                            onPressed: () {
                              _onUserInteraction();
                              _rewind10();
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _onUserInteraction();
                              _togglePlayPause();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.forward_10, color: Colors.white),
                            onPressed: () {
                              _onUserInteraction();
                              _forward10();
                            },
                          ),
                        ],
                      ),
                      Slider(
                        value: _currentPosition,
                        max: _videoDuration > 0 ? _videoDuration : 1,
                        onChanged: (value) {
                          _onUserInteraction();
                          _onSliderChanged(value);
                        },
                        activeColor: Colors.red,
                        inactiveColor: Colors.white,
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
