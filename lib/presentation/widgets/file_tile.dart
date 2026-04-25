import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/utils/file_utils.dart';
import '../../data/models/file_model.dart';

class FileTile extends StatelessWidget {
  final FileModel file;
  final VoidCallback onTap;
  
  const FileTile({
    super.key,
    required this.file,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF2A2A45),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // File icon or thumbnail
            _buildIcon(),
            
            const SizedBox(width: 14),
            
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (!file.isDir) ...[
                        Text(
                          FileUtils.formatSize(file.size),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          ' · ',
                          style: TextStyle(color: Colors.white24),
                        ),
                      ],
                      Text(
                        FileUtils.formatDate(file.modified),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Arrow or type indicator
            if (file.isDir)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white24,
              )
            else
              _buildTypeChip(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIcon() {
    // Show thumbnail for images
    if (file.isImage && file.thumb != null && file.thumb!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: file.thumb!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildIconBox(),
          errorWidget: (_, __, ___) => _buildIconBox(),
        ),
      );
    }
    
    return _buildIconBox();
  }
  
  Widget _buildIconBox() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: file.iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: file.iconColor.withOpacity(0.2),
        ),
      ),
      child: Icon(
        file.icon,
        color: file.iconColor,
        size: 24,
      ),
    );
  }
  
  Widget _buildTypeChip() {
    if (file.extension.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: file.iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        file.extension.toUpperCase(),
        style: TextStyle(
          color: file.iconColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
