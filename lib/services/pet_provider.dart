import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';

class PetProvider with ChangeNotifier {
  Pet? _currentPet;

  Pet? get currentPet => _currentPet;

  void setPet(Pet pet) {
    _currentPet = pet;
    notifyListeners();
  }
} 