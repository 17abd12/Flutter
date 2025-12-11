import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class FavoriteButton extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final String recipeSource; // 'generated', 'popular', 'smart', 'meal'
  final VoidCallback? onFavoriteChanged;
  
  const FavoriteButton({
    super.key,
    required this.recipeData,
    required this.recipeSource,
    this.onFavoriteChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  bool _isFavorite = false;
  String? _favoriteId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final sourceId = widget.recipeData['id']?.toString() ?? 
                       widget.recipeData['name'] ?? 
                       widget.recipeData['mealName'] ??
                       '';
      
      if (sourceId.isEmpty) return;

      final favoriteId = await _firestoreService.checkIfFavorite(
        user.uid,
        sourceId,
      );

      if (mounted) {
        setState(() {
          _isFavorite = favoriteId != null;
          _favoriteId = favoriteId;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to save favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite && _favoriteId != null) {
        // Remove from favorites
        await _firestoreService.removeFavoriteRecipe(_favoriteId!);
        
        if (mounted) {
          setState(() {
            _isFavorite = false;
            _favoriteId = null;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: AppTheme.primary,
              duration: Duration(seconds: 1),
            ),
          );
          
          widget.onFavoriteChanged?.call();
        }
      } else {
        // Add to favorites
        final sourceId = widget.recipeData['id']?.toString() ?? 
                         widget.recipeData['name'] ?? 
                         widget.recipeData['mealName'] ??
                         DateTime.now().millisecondsSinceEpoch.toString();
        
        // Get recipe name from various possible fields
        final recipeName = widget.recipeData['name'] ?? 
                          widget.recipeData['mealName'] ?? 
                          'Unnamed Recipe';
        
        // Add sourceId to recipe data and normalize field names
        final recipeDataWithId = {
          ...widget.recipeData,
          'id': sourceId,
          'name': recipeName, // Ensure name field exists
        };
        
        final favoriteId = await _firestoreService.saveFavoriteRecipe(
          uid: user.uid,
          recipeName: recipeName,
          recipeData: recipeDataWithId,
          recipeSource: widget.recipeSource,
        );

        if (mounted) {
          setState(() {
            _isFavorite = true;
            _favoriteId = favoriteId;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites ❤️'),
              backgroundColor: AppTheme.primary,
              duration: Duration(seconds: 1),
            ),
          );
          
          widget.onFavoriteChanged?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: _toggleFavorite,
      tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}
