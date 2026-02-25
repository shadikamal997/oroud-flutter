import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/search_service.dart';
import '../../../core/api/api_provider.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.read(apiClientProvider));
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedType = 'all'; // lowercase for API compatibility
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final searchService = ref.read(searchServiceProvider);
      final result = await searchService.search(
        query: _searchController.text.trim(),
        type: _selectedType,
      );

      setState(() {
        if (_selectedType == 'all') {
          _searchResults = [
            ...?result['shops'],
            ...?result['offers'],
          ];
        } else if (_selectedType == 'shops') {
          _searchResults = result['shops'] ?? [];
        } else {
          _searchResults = result['offers'] ?? [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: $e';
        _isLoading = false;
      });
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
          'Search',
          style: TextStyle(
            color: Color(0xFF2A2A2A),
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2EE),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search shops or offers...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB86E45)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Color(0xFFB86E45)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Row(
                    children: [
                      _buildTypeChip('all'),
                      const SizedBox(width: 8),
                      _buildTypeChip('shops'),
                      const SizedBox(width: 8),
                      _buildTypeChip('offers'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = _selectedType == type;
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
              )
            : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedType = type);
            if (_searchController.text.isNotEmpty) {
              _performSearch();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              type.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFB86E45),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
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
              onPressed: _performSearch,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Search for shops and offers'
                  : 'No results found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        
        // Check if it's a shop or offer
        if (item['userId'] != null) {
          // It's a shop
          return _buildShopCard(item);
        } else {
          // It's an offer
          return _buildOfferCard(item);
        }
      },
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/offer/${offer['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (offer['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    offer['imageUrl'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['title'] ?? 'Offer',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (offer['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        offer['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: shop['logoUrl'] != null
              ? NetworkImage(shop['logoUrl'])
              : null,
          child: shop['logoUrl'] == null
              ? const Icon(Icons.store)
              : null,
        ),
        title: Text(shop['name'] ?? 'Unknown Shop'),
        subtitle: Text(shop['description'] ?? ''),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to shop profile (placeholder)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Shop: ${shop['name']}')),
          );
        },
      ),
    );
  }
}
