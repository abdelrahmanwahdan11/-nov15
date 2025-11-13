import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/drawer_controller.dart';
import '../localization/localization_extensions.dart';
import '../routing/route_names.dart';
import '../utils/dummy_data.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppDrawerController.instance;
    final appController = AppController.instance;
    final l10n = context.l10n;
    final menuItems = <_DrawerItem>[
      _DrawerItem('home', l10n.translate('home'), RouteNames.home),
      _DrawerItem('profile', l10n.translate('profile'), RouteNames.profile),
      _DrawerItem('earnings', l10n.translate('earnings'), RouteNames.earnings),
      _DrawerItem('rides', l10n.translate('my_rides'), RouteNames.myRides),
      _DrawerItem('performance', l10n.translate('performance'), RouteNames.performance),
      _DrawerItem('insights', l10n.translate('insights_center'), RouteNames.insights),
      _DrawerItem('strategyLab', l10n.translate('strategy_lab'), RouteNames.strategyLab),
      _DrawerItem('momentum', l10n.translate('momentum_hub'), RouteNames.momentum),
      _DrawerItem('community', l10n.translate('community_lounge'), RouteNames.community),
      _DrawerItem('impact', l10n.translate('impact_studio'), RouteNames.impact),
      _DrawerItem('wellness', l10n.translate('wellness_studio'), RouteNames.wellness),
      _DrawerItem('chat', l10n.translate('chats'), RouteNames.chatList),
      _DrawerItem('documents', l10n.translate('documents'), RouteNames.documents),
      _DrawerItem('help', l10n.translate('help'), RouteNames.help),
      _DrawerItem('settings', l10n.translate('settings'), RouteNames.settings),
    ];
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(dummyUser.avatarUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dummyUser.name, style: Theme.of(context).textTheme.titleMedium),
                        Text(dummyUser.phone, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: controller.selectedItem,
                builder: (_, selected, __) {
                  return ListView(
                    children: menuItems.map((item) {
                      final isSelected = selected == item.key;
                      return ListTile(
                        leading: Icon(Icons.circle, size: 12, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
                        title: Text(item.title),
                        selected: isSelected,
                        onTap: () {
                          Navigator.of(context).pop();
                          controller.select(item.key);
                          if (ModalRoute.of(context)?.settings.name != item.route) {
                            Navigator.of(context).pushNamed(item.route);
                          }
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const Divider(),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: appController.themeMode,
              builder: (_, mode, __) {
                return SwitchListTile(
                  value: mode == ThemeMode.dark,
                  onChanged: (value) {
                    appController.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                  title: Text(l10n.translate('dark_mode')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.translate('logout')),
              onTap: () {
                appController.setLoggedIn(false);
                Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  const _DrawerItem(this.key, this.title, this.route);

  final String key;
  final String title;
  final String route;
}
