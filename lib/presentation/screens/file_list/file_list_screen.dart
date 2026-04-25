import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/file_model.dart';
import '../../../data/repositories/alist_repository.dart';
import '../../../core/utils/file_utils.dart';
import '../../widgets/file_tile.dart';

final fileListProvider = FutureProvider.family<FileListResponse, String>(
  (ref, path) async {
    final repo = ref.watch(alistRepositoryProvider);
    return repo.listFiles(path: path);
  },
);

class FileListScreen extends ConsumerStatefulWidget {
  final String path;
  
  const FileListScreen({super.key, required this.path});

  @override
  ConsumerState<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends ConsumerState<FileListScreen> {
  String _sortBy = 'name';
  bool _ascending = true;
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();
  
  String get _displayPath {
    if (widget.path == '/') return 'Root';
    return widget.path.split('/').last;
  }
  
  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(fileListProvider(widget.path));
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(theme),
      body: filesAsync.when(
        loading: () => _buildShimmer(),
        error: (err, stack) => _buildError(err.toString()),
        data: (data) => _buildFileList(data, theme),
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      leading: widget.path != '/'
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
            )
          : null,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search files...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            )
          : Column(
              children: [
                Text(
                  _displayPath,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.path != '/')
                  Text(
                    widget.path,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Iconsax.search_normal),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Iconsax.sort),
          onSelected: (value) {
            setState(() {
              if (_sortBy == value) {
                _ascending = !_ascending;
              } else {
                _sortBy = value;
                _ascending = true;
              }
            });
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'name',
              child: Row(
                children: [
                  Icon(Iconsax.text),
                  SizedBox(width: 8),
                  Text('Name'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'size',
              child: Row(
                children: [
                  Icon(Iconsax.maximize_2),
                  SizedBox(width: 8),
                  Text('Size'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'date',
              child: Row(
                children: [
                  Icon(Iconsax.calendar),
                  SizedBox(width: 8),
                  Text('Date'),
                ],
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Iconsax.refresh),
          onPressed: () {
            ref.invalidate(fileListProvider(widget.path));
          },
        ),
      ],
    );
  }
  
  Widget _buildFileList(FileListResponse data, ThemeData theme) {
    var files = data.files;
    
    // Filter
    if (_searchQuery.isNotEmpty) {
      files = files
          .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    // Sort
    files.sort((a, b) {
      // Folders first
      if (a.isDir && !b.isDir) return -1;
      if (!a.isDir && b.isDir) return 1;
      
      int result;
      switch (_sortBy) {
        case 'size':
          result = a.size.compareTo(b.size);
          break;
        case 'date':
          result = a.modified.compareTo(b.modified);
          break;
        default:
          result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      
      return _ascending ? result : -result;
    });
    
    if (files.isEmpty) {
      return _buildEmpty();
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(fileListProvider(widget.path));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return FileTile(
            file: file,
            onTap: () => _openFile(file),
          )
          .animate(delay: (index * 30).ms)
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.1);
        },
      ),
    );
  }
  
  void _openFile(FileModel file) async {
    if (file.isDir) {
      final newPath = widget.path == '/'
          ? '/${file.name}'
          : '${widget.path}/${file.name}';
      context.push('/home/files?path=${Uri.encodeComponent(newPath)}');
      return;
    }
    
    final filePath = widget.path == '/'
        ? '/${file.name}'
        : '${widget.path}/${file.name}';
    
    // Get file info for URL
    final repo = ref.read(alistRepositoryProvider);
    
    try {
      final info = await repo.getFileInfo(filePath);
      final rawUrl = info['raw_url'] ?? '';
      
      if (file.isVideo) {
        context.push('/home/video', extra: {
          'url': rawUrl,
          'title': file.name,
        });
      } else if (file.isImage) {
        context.push('/home/image', extra: {
          'url': rawUrl,
          'title': file.name,
        });
      } else {
        // Download or open in browser
        _showFileOptions(file, rawUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  void _showFileOptions(FileModel file, String url) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              file.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              FileUtils.formatSize(file.size),
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Iconsax.document_download, color: Color(0xFF6C63FF)),
              title: const Text('Download', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Download implementation
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.share, color: Color(0xFF6C63FF)),
              title: const Text('Share Link', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1A2E),
      highlightColor: const Color(0xFF252540),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFCF6679)),
          const SizedBox(height: 16),
          Text(
            'Failed to load files',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.invalidate(fileListProvider(widget.path)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.folder_open,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            'Empty Folder',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
