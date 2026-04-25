import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final String title;
  
  const VideoPlayerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _showControls = true;
  bool _isFullscreen = false;
  
  @override
  void initState() {
    super.initState();
    
    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024 * 1024, // 32MB buffer
      ),
    );
    _controller = VideoController(_player);
    
    // Set network optimization
    _player.open(
      Media(
        widget.url,
        httpHeaders: {
          'User-Agent': 'AlistApp/1.0',
        },
      ),
    );
    
    // Auto-hide controls
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }
  
  @override
  void dispose() {
    _player.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
  
  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  
  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    
    if (_showControls) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _showControls) {
          setState(() => _showControls = false);
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video
            Center(
              child: Video(
                controller: _controller,
                fit: BoxFit.contain,
              ),
            ),
            
            // Controls overlay
            if (_showControls) _buildControls(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xCC000000),
              Colors.transparent,
              Colors.transparent,
              Color(0xCC000000),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              _buildTopBar(),
              
              const Spacer(),
              
              // Center controls
              _buildCenterControls(),
              
              const Spacer(),
              
              // Bottom bar
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
  
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              _isFullscreen 
                  ? Icons.fullscreen_exit_rounded 
                  : Icons.fullscreen_rounded,
              color: Colors.white,
            ),
            onPressed: _toggleFullscreen,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCenterControls() {
    return StreamBuilder(
      stream: _player.stream.playing,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rewind 10s
            GestureDetector(
              onTap: () async {
                final pos = await _player.stream.position.first;
                _player.seek(pos - const Duration(seconds: 10));
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.replay_10_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Play/Pause
            GestureDetector(
              onTap: () => _player.playOrPause(),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying 
                      ? Icons.pause_rounded 
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Forward 10s
            GestureDetector(
              onTap: () async {
                final pos = await _player.stream.position.first;
                _player.seek(pos + const Duration(seconds: 10));
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.forward_10_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress bar
          StreamBuilder(
            stream: _player.stream.position,
            builder: (context, posSnapshot) {
              return StreamBuilder(
                stream: _player.stream.duration,
                builder: (context, durSnapshot) {
                  final position = posSnapshot.data ?? Duration.zero;
                  final duration = durSnapshot.data ?? Duration.zero;
                  
                  final progress = duration.inMilliseconds > 0
                      ? position.inMilliseconds / duration.inMilliseconds
                      : 0.0;
                  
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF6C63FF),
                          inactiveTrackColor: Colors.white24,
                          thumbColor: const Color(0xFF6C63FF),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            final seek = Duration(
                              milliseconds: (value * duration.inMilliseconds).toInt(),
                            );
                            _player.seek(seek);
                          },
                        ),
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Bottom controls
          Row(
            children: [
              // Volume
              StreamBuilder(
                stream: _player.stream.volume,
                builder: (context, snapshot) {
                  final volume = snapshot.data ?? 100.0;
                  return Row(
                    children: [
                      Icon(
                        volume > 0 ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(
                        width: 80,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: volume / 100,
                            onChanged: (value) {
                              _player.setVolume(value * 100);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const Spacer(),
              
              // Speed
              PopupMenuButton<double>(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: StreamBuilder(
                    stream: _player.stream.rate,
                    builder: (context, snapshot) {
                      final rate = snapshot.data ?? 1.0;
                      return Text(
                        '${rate}x',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                onSelected: (rate) => _player.setRate(rate),
                itemBuilder: (_) => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                    .map((speed) => PopupMenuItem(
                          value: speed,
                          child: Text('${speed}x'),
                        ))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
