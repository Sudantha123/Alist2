class FileUtils {
  static String formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int index = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index++;
    }
    
    if (index == 0) return '${size.toInt()} ${units[index]}';
    return '${size.toStringAsFixed(1)} ${units[index]}';
  }
  
  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays == 0) {
        if (diff.inHours == 0) return '${diff.inMinutes}m ago';
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateStr;
    }
  }
  
  static bool isVideoFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'm4v', 'webm', 
            'ts', 'm2ts', 'rmvb', 'rm', '3gp'].contains(ext);
  }
  
  static bool isImageFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg', 'heic'].contains(ext);
  }
  
  static bool isAudioFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ['mp3', 'flac', 'aac', 'wav', 'ogg', 'm4a', 'opus'].contains(ext);
  }
}
