import 'package:flutter/foundation.dart';

/// Singleton service to manage recipe generation state across navigation
class RecipeGenerationState extends ChangeNotifier {
  static final RecipeGenerationState _instance = RecipeGenerationState._internal();
  
  factory RecipeGenerationState() {
    return _instance;
  }
  
  RecipeGenerationState._internal();

  bool _isGenerating = false;
  Map<String, dynamic>? _lastGeneratedRecipe;
  String? _generationError;
  DateTime? _generationStartTime;

  bool get isGenerating => _isGenerating;
  Map<String, dynamic>? get lastGeneratedRecipe => _lastGeneratedRecipe;
  String? get generationError => _generationError;
  DateTime? get generationStartTime => _generationStartTime;

  /// Start recipe generation
  void startGeneration() {
    _isGenerating = true;
    _lastGeneratedRecipe = null;
    _generationError = null;
    _generationStartTime = DateTime.now();
    notifyListeners();
    print('🔄 Recipe generation started at ${_generationStartTime}');
  }

  /// Complete recipe generation with success
  void completeGeneration(Map<String, dynamic> recipe) {
    _isGenerating = false;
    _lastGeneratedRecipe = recipe;
    _generationError = null;
    final duration = DateTime.now().difference(_generationStartTime ?? DateTime.now());
    notifyListeners();
    print('✅ Recipe generation completed in ${duration.inSeconds}s');
  }

  /// Complete recipe generation with error
  void failGeneration(String error) {
    _isGenerating = false;
    _lastGeneratedRecipe = null;
    _generationError = error;
    notifyListeners();
    print('❌ Recipe generation failed: $error');
  }

  /// Clear the last generated recipe
  void clearLastRecipe() {
    _lastGeneratedRecipe = null;
    _generationError = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _isGenerating = false;
    _lastGeneratedRecipe = null;
    _generationError = null;
    _generationStartTime = null;
    notifyListeners();
  }
}
