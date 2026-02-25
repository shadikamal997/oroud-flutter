import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/category_service.dart';
import '../../../core/api/api_provider.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.read(apiClientProvider));
});

class FavoriteCategoriesScreen extends ConsumerStatefulWidget {
  const FavoriteCategoriesScreen({super.key});

  @override
  ConsumerState<FavoriteCategoriesScreen> createState() =>
      _FavoriteCategoriesScreenState();
}

class _FavoriteCategoriesScreenState extends ConsumerState<FavoriteCategoriesScreen> {
  List<dynamic> _allCategories = [];
  List<dynamic> _followedCategories = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final categoryService = ref.read(categoryServiceProvider);
      final results = await Future.wait([
        categoryService.getAllCategories(),
        categoryService.getFollowedCategories(),
      ]);

      setState(() {
        _allCategories = results[0];
        _followedCategories = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories: $e';
        _isLoading = false;
      });
    }
  }

  bool _isFollowing(String category) {
    return _followedCategories.any((c) => c['category'] == category);
  }

  Future<void> _toggleFollow(String category) async {
    final isCurrentlyFollowing = _isFollowing(category);

    try {
      final categoryService = ref.read(categoryServiceProvider);
      
      if (isCurrentlyFollowing) {
        await categoryService.unfollowCategory(category);
        setState(() {
          _followedCategories.removeWhere((c) => c['category'] == category);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed $category')),
        );
      } else {
        await categoryService.followCategory(category);
        setState(() {
          _followedCategories.add({
            'category': category,
            'auto': false,
            'followedAt': DateTime.now().toIso8601String(),
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Following $category')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFB86E45)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Favorite Categories',
          style: TextStyle(
            color: Color(0xFF2A2A2A),
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFFB86E45)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text(
                    'About Category Preferences',
                    style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    'Follow categories to receive personalized notifications when new offers are posted!\n\n'
                    '• Manual: Categories you explicitly follow\n'
                    '• Auto: Categories learned from your behavior',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it', style: TextStyle(color: Color(0xFFB86E45))),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_followedCategories.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Following ${_followedCategories.length} categories',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
        Expanded(
          child: ListView.builder(
            itemCount: _allCategories.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final category = _allCategories[index];
              final categoryName = category['name'] ?? category['id'];
              final isFollowing = _isFollowing(categoryName);
              final followedData = _followedCategories.firstWhere(
                (c) => c['category'] == categoryName,
                orElse: () => {},
              );
              final isAuto = followedData['auto'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isFollowing
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    child: Icon(
                      _getCategoryIcon(categoryName),
                      color: isFollowing ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(categoryName)),
                      if (isFollowing && isAuto)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'AUTO',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    isFollowing
                        ? 'Receiving notifications'
                        : 'Tap to follow',
                  ),
                  trailing: Switch(
                    value: isFollowing,
                    onChanged: (_) => _toggleFollow(categoryName),
                  ),
                  onTap: () => _toggleFollow(categoryName),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food') || lower.contains('restaurant')) {
      return Icons.restaurant;
    } else if (lower.contains('fashion') || lower.contains('clothing')) {
      return Icons.checkroom;
    } else if (lower.contains('electronic')) {
      return Icons.devices;
    } else if (lower.contains('health') || lower.contains('beauty')) {
      return Icons.spa;
    } else if (lower.contains('home')) {
      return Icons.home;
    } else if (lower.contains('sport')) {
      return Icons.sports;
    } else {
      return Icons.category;
    }
  }
}
