
import 'package:flutter/material.dart';

import '../../controllers/catalog_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/widgets/animated_image_overlay_card.dart';
import '../../core/widgets/filter_chips_row.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/widgets/tag_chip.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CatalogController _controller = CatalogController.instance;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('catalog'))),
      body: StreamBuilder(
        stream: _controller.catalogStream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _controller.refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                DebouncedSearchBar(
                  hintText: l10n.translate('search_catalog'),
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                      _controller.applyFilters(value, category: _controller.activeCategory.value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<String?>(
                  valueListenable: _controller.activeCategory,
                  builder: (_, category, __) {
                    return FilterChipsRow(
                      options: const ['Peak', 'Airport'],
                      active: category,
                      onSelected: (value) {
                        _controller.activeCategory.value = value;
                        _controller.applyFilters(_query, category: value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AnimatedImageOverlayCard(
                        imageUrl: item.imageUrl,
                        front: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                            const SizedBox(height: 8),
                            Wrap(spacing: 8, children: item.tags.map((tag) => TagChip(label: tag)).toList()),
                          ],
                        ),
                        back: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.subtitle, style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 8),
                            Text('Price: \$${item.price.toStringAsFixed(2)}'),
                            Text('Distance: ${item.distanceKm.toStringAsFixed(1)} km'),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
