import 'package:flutter/material.dart';

import '../../controllers/ride_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../core/widgets/transaction_tile.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final RideController _controller = RideController.instance;
  final ScrollController _scrollController = ScrollController();
  List<TransactionItem> _transactions = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller.transactionsStream.listen((event) {
      setState(() {
        _transactions = event;
        _loading = false;
      });
    });
    _controller.loadInitial();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 80) {
        _controller.paginateTransactions(_transactions.length);
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
      appBar: AppBar(title: Text(l10n.translate('my_earnings_title'))),
      body: RefreshIndicator(
        onRefresh: () => _controller.refreshTransactions(),
        child: _loading
            ? const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(24),
                child: SkeletonList(),
              )
            : ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.translate('available_balance'), style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        const Text('\$2,485.75', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(l10n.translate('add_new_card')),
                  ),
                  const SizedBox(height: 24),
                  ..._transactions.map((item) => TransactionTile(transaction: item)),
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ),
      ),
    );
  }
}
