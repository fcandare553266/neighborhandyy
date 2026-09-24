import 'dart:async';

import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/freelancer_model.dart';
import '../services/firestore_service.dart';

class FreelancerProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  FreelancerProvider({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  List<CategoryModel> categories = [];
  List<FreelancerModel> matchedFreelancers = [];
  bool isLoading = false;
  StreamSubscription? _sub;

  static const _categoryCatalog = [
    ('carpenter', 'Carpenter', '🪚'),
    ('mason', 'Mason', '🧱'),
    ('tiler', 'Tiler', '▦'),
    ('painter', 'Painter', '🎨'),
    ('roofer', 'Roofer', '🏠'),
    ('welder_fabricator', 'Welder / Fabricator', '⚙️'),
    ('electrician', 'Electrician', '💡'),
    ('plumber', 'Plumber', '🔧'),
    ('drywall_installer', 'Drywall Installer', '🧰'),
    ('steel_fixer_ironworker', 'Steel Fixer / Ironworker', '🔩'),
    ('auto_mechanic', 'Auto Mechanic / Mobile Mechanic', '🚗'),
    ('appliance_repair_technician', 'Appliance Repair Technician', '🔌'),
    ('hvac_aircon_technician', 'HVAC / Aircon Technician', '❄️'),
    ('handyman', 'Handyman', '🛠️'),
    ('locksmith', 'Locksmith', '🔐'),
    ('machinist', 'Machinist', '⚙️'),
    ('house_cleaner', 'House Cleaner', '🧹'),
    ('landscaper_gardener', 'Landscaper / Gardener', '🌿'),
    ('pest_control_technician', 'Pest Control Technician', '🐜'),
    ('pool_cleaner', 'Pool Cleaner', '🏊'),
    ('mover_hauler', 'Mover / Hauler', '📦'),
    ('caregiver_nanny', 'Caregiver / Nanny', '🤝'),
    ('tailor_seamstress', 'Tailor / Seamstress', '🧵'),
  ];

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();
    try {
      final firebaseCategories = await _firestoreService.getCategories();
      final freelancerCounts = await _firestoreService
          .getFreelancerCategoryCounts();
      final byId = {
        for (final category in firebaseCategories) category.id: category,
      };
      final byName = {
        for (final category in firebaseCategories)
          category.name.toLowerCase(): category,
      };

      categories = [
        for (final item in _categoryCatalog)
          CategoryModel(
            id: item.$1,
            name: item.$2,
            icon:
                byId[item.$1]?.icon ??
                byName[item.$2.toLowerCase()]?.icon ??
                item.$3,
            nearbyCount:
                freelancerCounts[_normalizeCategory(item.$1)] ??
                byId[item.$1]?.nearbyCount ??
                byName[item.$2.toLowerCase()]?.nearbyCount ??
                0,
          ),
      ];
    } catch (error) {
      categories = [
        for (final item in _categoryCatalog)
          CategoryModel(id: item.$1, name: item.$2, icon: item.$3),
      ];
      debugPrint('Failed to load categories from Firestore: $error');
    }

    isLoading = false;
    notifyListeners();
  }

  String _normalizeCategory(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalized.contains('plumb')) return 'plumber';
    if (normalized.contains('electric')) return 'electrician';
    if (normalized.contains('paint')) return 'painter';
    if (normalized.contains('carpent')) return 'carpenter';
    if (normalized == 'plumbing') return 'plumber';
    return normalized;
  }

  /// Loads freelancers under [category] whose city matches [clientCity].
  void loadFreelancers({required String category, required String clientCity}) {
    isLoading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _firestoreService
        .getFreelancersByCategoryAndCity(category: category, city: clientCity)
        .listen((list) {
          matchedFreelancers = list;
          isLoading = false;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
