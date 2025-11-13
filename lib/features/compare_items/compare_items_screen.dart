
import 'package:flutter/material.dart';

import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';

class CompareItemsScreen extends StatelessWidget {
  const CompareItemsScreen({super.key, this.items});

  final List<dynamic>? items;

  @override
  Widget build(BuildContext context) {
    final list = items?.cast<dynamic>() ?? [];
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('compare_items'))),
      body: list.isEmpty
          ? Center(child: Text(l10n.translate('select_items_to_compare')))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(l10n.translate('metric'))),
                  ...list.map((item) => DataColumn(label: Text(_title(item)))),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text(l10n.translate('price'))),
                    ...list.map((item) => DataCell(Text(_price(item)))),
                  ]),
                  DataRow(cells: [
                    DataCell(Text(l10n.translate('distance'))),
                    ...list.map((item) => DataCell(Text(_distance(item)))),
                  ]),
                  DataRow(cells: [
                    DataCell(Text(l10n.translate('time'))),
                    ...list.map((item) => DataCell(Text(_time(item)))),
                  ]),
                ],
              ),
            ),
    );
  }

  String _title(dynamic item) {
    if (item is Ride) return item.passengerName;
    if (item is CatalogItem) return item.title;
    return item.toString();
  }

  String _price(dynamic item) {
    if (item is Ride) return '\$${item.price.toStringAsFixed(2)}';
    if (item is CatalogItem) return '\$${item.price.toStringAsFixed(2)}';
    return '-';
  }

  String _distance(dynamic item) {
    if (item is Ride) return '${item.distanceKm.toStringAsFixed(1)} km';
    if (item is CatalogItem) return '${item.distanceKm.toStringAsFixed(1)} km';
    return '-';
  }

  String _time(dynamic item) {
    if (item is Ride) return '${item.avgTimeMinutes} mins';
    if (item is CatalogItem) return item.meta['time'] ?? '-';
    return '-';
  }
}
