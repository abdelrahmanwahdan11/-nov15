import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../localization/app_localizations.dart';

class AIInfoButton extends StatelessWidget {
  const AIInfoButton({
    super.key,
    required this.headlineKey,
    required this.insightsBuilder,
  });

  final String headlineKey;
  final List<String> Function(AppLocalizations l10n) insightsBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IconButton(
      icon: const Icon(Icons.smart_toy_outlined),
      onPressed: () {
        final insights = insightsBuilder(l10n);
        if (insights.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('ai_placeholder')),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        showModalBottomSheet<void>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (sheetContext) {
            final modalL10n = sheetContext.l10n;
            final theme = Theme.of(sheetContext);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 56,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Text(
                      modalL10n.translate('smart_insights'),
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modalL10n.translate(headlineKey),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...insights.map(
                      (insight) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                insight,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(modalL10n.translate('close')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      tooltip: l10n.translate('smart_insights'),
    );
  }
}
