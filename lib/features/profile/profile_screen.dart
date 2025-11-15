
import 'package:flutter/material.dart';

import '../../core/utils/dummy_data.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _carModelController;
  late final TextEditingController _carPlateController;
  late final TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: dummyUser.name);
    _phoneController = TextEditingController(text: dummyUser.phone);
    _carModelController = TextEditingController(text: dummyUser.carModel);
    _carPlateController = TextEditingController(text: dummyUser.carPlate);
    _avatarController = TextEditingController(text: dummyUser.avatarUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _carModelController.dispose();
    _carPlateController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('profile_title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(_avatarController.text),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.translate('update_avatar')),
                          content: TextField(controller: _avatarController),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.translate('close')),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: l10n.translate('name'))),
            const SizedBox(height: 16),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: l10n.translate('phone'))),
            const SizedBox(height: 16),
            TextField(controller: _carModelController, decoration: InputDecoration(labelText: l10n.translate('car_model'))),
            const SizedBox(height: 16),
            TextField(controller: _carPlateController, decoration: InputDecoration(labelText: l10n.translate('car_plate'))),
            const SizedBox(height: 24),
            PrimaryButton(
              label: l10n.translate('save'),
              onPressed: () {
                dummyUser
                  ..name = _nameController.text
                  ..phone = _phoneController.text
                  ..carModel = _carModelController.text
                  ..carPlate = _carPlateController.text
                  ..avatarUrl = _avatarController.text;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.translate('profile_updated'))),
                );
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
