import 'package:flutter/material.dart';

import '../../controllers/ride_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ride_card.dart';
import '../../core/routing/route_names.dart';
import '../../core/widgets/search_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RideController _controller = RideController.instance;
  final ScrollController _scrollController = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.loadInitial();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 80) {
        _controller.paginateRides();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('history'))),
      body: StreamBuilder<List<Ride>>(
        stream: _controller.ridesStream,
        builder: (context, snapshot) {
          final rides = snapshot.data ?? [];
          final filtered = _controller.filterRides(_query);
          return RefreshIndicator(
            onRefresh: _controller.refreshRides,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                DebouncedSearchBar(
                  hintText: l10n.translate('search_history'),
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(l10n.translate('no_rides_found')),
                  ))
                else
                  ...filtered.map((ride) => RideCard(
                        ride: ride,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            RouteNames.tripDetails,
                            arguments: ride,
                          );
                        },
                      )),
                if (rides.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
