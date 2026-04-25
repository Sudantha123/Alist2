import 'package:flutter/material.dart';

class FileModel {
  final String name;
  final int size;
  final bool isDir;
  final String modified;
  final String? sign;
  final String? thumb;
  final int type;
  final String? rawUrl;

  const FileModel({
    required this.name,
    required this.size,
    required this.isDir,
    required this.modified,
    this.sign,
    this.thumb,
    required this.type,
    this.rawUrl,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      isDir: json['is_dir'] ?? false,
      modified: json['modified'] ?? '',
      sign: json['sign'],
      thumb: json['thumb'],
      type: json['type'] ?? 0,
      rawUrl: json['raw_url'],
    );
  }

  // File type: 1=folder, 2=video, 3=audio, 4=image, 5=text, 6=other
  bool get isVideo => type == 2;
  bool get isAudio => type == 3;
  bool get isImage => type == 4;
  bool get isText => type == 5;
  
  String get extension {
    if (isDir) return '';
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
  
  IconData get icon {
    if (isDir) return Icons.folder_rounded;
    switch (type) {
      case 2: return Icons.play_circle_rounded;
      case 3: return Icons.music_note_rounded;
      case 4: return Icons.image_rounded;
      case 5: return Icons.article_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }
  
  Color get iconColor {
    if (isDir) return const Color(0xFFFFB74D);
    switch (type) {
      case 2: return const Color(0xFF7986CB);
      case 3: return const Color(0xFF4DB6AC);
      case 4: return const Color(0xFF81C784);
      case 5: return const Color(0xFF90A4AE);
      default: return const Color(0xFF9E9E9E);
    }
  }
}

class FileListResponse {
  final List<FileModel> files;
  final String path;
  final int total;
  
  const FileListResponse({
    required this.files,
    required this.path,
    required this.total,
  });
  
  factory FileListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final content = data['content'] as List<dynamic>? ?? [];
    return FileListResponse(
      files: content.map((e) => FileModel.fromJson(e)).toList(),
      path: data['path'] ?? '/',
      total: data['total'] ?? 0,
    );
  }
}
