import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'generated_recipe_detail_screen.dart';

class FavoriteRecipesScreen extends StatefulWidget {
  final bool showAppBar;
  
  const FavoriteRecipesScreen({super.key, this.showAppBar = true});

  @override
  State<FavoriteRecipesScreen> createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final favorites = await _firestoreService.getUserFavoriteRecipes(user.uid);
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(String favoriteId, String recipeName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: Text('Remove "$recipeName" from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firestoreService.removeFavoriteRecipe(favoriteId);
      if (mounted) {
        setState(() {
          _favorites.removeWhere((f) => f['id'] == favoriteId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
    final calories = favorite['calories'] ?? 0;
    final protein = favorite['protein'] ?? 0;
    final prepTime = favorite['prepTime'] ?? '';
    final source = favorite['source'] ?? 'unknown';
    
    // Source badge color
    Color sourceColor;
    String sourceLabel;
    switch (source) {
      case 'generated':
        sourceColor = Colors.purple;
        sourceLabel = 'Generated';
        break;
      case 'popular':
        sourceColor = Colors.orange;
        sourceLabel = 'Popular';
        break;
      case 'smart':
        sourceColor = Colors.blue;
        sourceLabel = 'Smart AI';
        break;
      case 'meal':
        sourceColor = Colors.green;
        sourceLabel = 'Meal';
        break;
      default:
        sourceColor = Colors.grey;
        sourceLabel = 'Recipe';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GeneratedRecipeDetailScreen(
                recipe: favorite,
                onDelete: () {
                  // Refresh favorites list after delete
                  _loadFavorites();
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with source badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      favorite['name'] ?? 'Unnamed Recipe',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sourceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sourceColor, width: 1),
                    ),
                    child: Text(
                      sourceLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sourceColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              if (favorite['description'] != null && favorite['description'].toString().isNotEmpty)
                Text(
                  favorite['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),

              // Nutrition chips
              Row(
                children: [
                  if (calories > 0) ...[
                    _buildChip(Icons.local_fire_department, '$calories cal', Colors.orange),
                    const SizedBox(width: 8),
                  ],
                  if (protein > 0) ...[
                    _buildChip(Icons.fitness_center, '${protein}g protein', AppTheme.primary),
                    const SizedBox(width: 8),
                  ],
                  if (prepTime.isNotEmpty)
                    _buildChip(Icons.access_time, prepTime, Colors.blue),
                ],
              ),
              const SizedBox(height: 12),

              // Footer with date and remove button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Added ${_formatDate(favorite['createdAt'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _removeFavorite(
                      favorite['id'],
                      favorite['name'] ?? 'this recipe',
                    ),
                    tooltip: 'Remove from favorites',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.showAppBar ? AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.boldGradient),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        title: const Text(
          'Favorite Recipes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on recipes to save them here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteCard(_favorites[index]);
                    },
                  ),
                ),
    );
  }
}
