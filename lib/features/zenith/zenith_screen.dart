import 'package:flutter/material.dart';

import '../../controllers/zenith_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/models.dart';
import '../../core/widgets/ai_info_button.dart';

class ZenithScreen extends StatefulWidget {
  const ZenithScreen({super.key});

  @override
  State<ZenithScreen> createState() => _ZenithScreenState();
}

class _ZenithScreenState extends State<ZenithScreen> {
  final ZenithController _controller = ZenithController.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller.init().then((_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    await _controller.refreshPulse();
  }

  String _modeKeyForLabel(String mode) {
    if (mode == zenithModes.first) {
      return 'zenith_mode_launch';
    }
    if (mode == zenithModes[1]) {
      return 'zenith_mode_navigation';
    }
    return 'zenith_mode_resonance';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('zenith_studio')),
        actions: [
          AIInfoButton(
            headlineKey: 'zenith_ai_headline',
            insightsBuilder: (localizations) {
              final pulse = _controller.pulse.value;
              final focus = _controller.focusVector.value;
              return [
                '${localizations.translate('zenith_ai_clarity')}: ${(pulse.clarity * 100).round()}%',
                '${localizations.translate('zenith_ai_momentum')}: ${(pulse.momentum * 100).round()}%',
                '${localizations.translate('zenith_ai_altitude')}: ${(pulse.altitude * 100).round()}%',
                if (focus != null)
                  '${localizations.translate('zenith_ai_focus')}: ${focus.title}',
              ];
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.translate('zenith_refresh'),
            onPressed: _controller.refreshPulse,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      ValueListenableBuilder<ZenithPulse>(
                        valueListenable: _controller.pulse,
                        builder: (_, pulse, __) {
                          return _ZenithPulseCard(pulse: pulse);
                        },
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<String>(
                        valueListenable: _controller.focusMode,
                        builder: (_, mode, __) {
                          return _ZenithModeSelector(
                            selectedMode: mode,
                            labelBuilder: _modeKeyForLabel,
                            onChanged: _controller.setMode,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<List<ZenithVector>>(
                        valueListenable: _controller.vectors,
                        builder: (_, vectors, __) {
                          return ValueListenableBuilder<ZenithVector?>(
                            valueListenable: _controller.focusVector,
                            builder: (_, focus, __) {
                              return _ZenithVectorBoard(
                                vectors: vectors,
                                focus: focus,
                                onSelect: _controller.setFocusVector,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<List<ZenithPath>>(
                        valueListenable: _controller.paths,
                        builder: (_, paths, __) {
                          return _ZenithPathList(
                            paths: paths,
                            onToggle: _controller.togglePath,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<List<ZenithSignal>>(
                        stream: _controller.signalsStream,
                        initialData: const <ZenithSignal>[],
                        builder: (_, snapshot) {
                          final signals = snapshot.data ?? const <ZenithSignal>[];
                          return _ZenithSignalPanel(
                            signals: signals,
                            onAcknowledge: _controller.acknowledgeSignal,
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ZenithPulseCard extends StatelessWidget {
  const _ZenithPulseCard({required this.pulse});

  final ZenithPulse pulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('zenith_pulse_title'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(pulse.headline, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricPill(
                label: l10n.translate('zenith_clarity'),
                value: (pulse.clarity * 100).round(),
                icon: Icons.brightness_5,
              ),
              _MetricPill(
                label: l10n.translate('zenith_acceleration'),
                value: (pulse.acceleration * 100).round(),
                icon: Icons.speed,
              ),
              _MetricPill(
                label: l10n.translate('zenith_altitude'),
                value: (pulse.altitude * 100).round(),
                icon: Icons.terrain,
              ),
              _MetricPill(
                label: l10n.translate('zenith_momentum'),
                value: (pulse.momentum * 100).round(),
                icon: Icons.auto_graph,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.timelapse, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.translate('zenith_window_label')}: ${pulse.window}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(pulse.message, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ZenithModeSelector extends StatelessWidget {
  const _ZenithModeSelector({
    required this.selectedMode,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String selectedMode;
  final String Function(String) labelBuilder;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('zenith_mode_section'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: zenithModes.map((mode) {
            final selected = mode == selectedMode;
            return ChoiceChip(
              label: Text(l10n.translate(labelBuilder(mode))),
              selected: selected,
              onSelected: (_) => onChanged(mode),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ZenithVectorBoard extends StatelessWidget {
  const _ZenithVectorBoard({
    required this.vectors,
    required this.focus,
    required this.onSelect,
  });

  final List<ZenithVector> vectors;
  final ZenithVector? focus;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('zenith_vector_section'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...vectors.map((vector) {
          final isActive = focus?.id == vector.id;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(vector.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vector.title,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () => onSelect(vector.id),
                      child: Text(
                        isActive
                            ? l10n.translate('zenith_focus_active')
                            : l10n.translate('zenith_focus_cta'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(vector.summary, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: vector.momentum,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ZenithPathList extends StatelessWidget {
  const _ZenithPathList({required this.paths, required this.onToggle});

  final List<ZenithPath> paths;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('zenith_paths_section'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...paths.map((path) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          path.title,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => onToggle(path.id),
                        icon: Icon(path.active ? Icons.pause : Icons.play_arrow),
                        label: Text(
                          path.active
                              ? l10n.translate('zenith_pause_path')
                              : l10n.translate('zenith_activate_path'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.translate('zenith_window_label')}: ${path.window} • ${path.distanceKm.toStringAsFixed(1)} km',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: path.progress,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ZenithSignalPanel extends StatelessWidget {
  const _ZenithSignalPanel({required this.signals, required this.onAcknowledge});

  final List<ZenithSignal> signals;
  final ValueChanged<String> onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('zenith_signals_section'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (signals.isEmpty)
          Text(l10n.translate('zenith_signals_empty'),
              style: theme.textTheme.bodySmall)
        else
          ...signals.map((signal) {
            final acknowledged = signal.acknowledged;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 240),
              opacity: acknowledged ? 0.5 : 1,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.12 * signal.severity),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${l10n.translate('zenith_signal_badge')} ${signal.severity}',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              signal.title,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            tooltip: l10n.translate('zenith_acknowledge_signal'),
                            onPressed: acknowledged
                                ? null
                                : () => onAcknowledge(signal.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(signal.detail, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.primary.withOpacity(0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text('$label • $value%', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
