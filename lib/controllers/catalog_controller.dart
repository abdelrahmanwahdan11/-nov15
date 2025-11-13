import 'dart:async';

import 'package:flutter/material.dart';

import '../core/utils/dummy_data.dart';
import '../core/utils/models.dart';

class CatalogController {
  CatalogController._();

  static final CatalogController instance = CatalogController._();

  final StreamController<List<CatalogItem>> _catalogStreamController =
      StreamController<List<CatalogItem>>.broadcast();
  final ValueNotifier<List<String>> activeFilters = ValueNotifier(<String>[]);
  final ValueNotifier<String?> activeCategory = ValueNotifier(null);

  List<CatalogItem> _items = List.of(dummyCatalogItems);

  Stream<List<CatalogItem>> get catalogStream => _catalogStreamController.stream;
  List<CatalogItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _catalogStreamController.add(_items);
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _items = List.of(dummyCatalogItems)..shuffle();
    _catalogStreamController.add(_filterItems('', category: activeCategory.value));
  }

  Future<void> paginate() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final start = _items.length;
    _items.addAll(List.generate(
      6,
      (index) => CatalogItem(
        id: 'catalog-${start + index}',
        title: 'Driver Bundle ${start + index + 1}',
        subtitle: 'More opportunities in trending hotspots.',
        imageUrl: 'https://images.unsplash.com/photo-1529429617124-aee64c1a05d5',
        category: index.isEven ? 'Peak' : 'Airport',
        tags: ['bonus', 'city', if (index.isEven) 'express'],
        rating: 4.2 + (index % 3) * 0.2,
        price: 16 + index * 3,
        distanceKm: 12 + index * 1.4,
        meta: {'traffic': 'Medium', 'time': '${12 + index} mins'},
      ),
    ));
    _catalogStreamController.add(_items);
  }

  void applyFilters(String query, {String? category}) {
    final filtered = _filterItems(query, category: category);
    _catalogStreamController.add(filtered);
  }

  List<CatalogItem> _filterItems(String query, {String? category}) {
    return _items.where((item) {
      final matchesCategory = category == null || item.category == category;
      final matchesTags = activeFilters.value.isEmpty ||
          activeFilters.value.any((tag) => item.tags.contains(tag));
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.subtitle.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesTags && matchesQuery;
    }).toList();
  }

  void dispose() {
    _catalogStreamController.close();
  }
}
