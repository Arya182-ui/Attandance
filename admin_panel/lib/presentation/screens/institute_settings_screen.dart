import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/institute_provider.dart';

class InstituteSettingsScreen extends ConsumerStatefulWidget {
  const InstituteSettingsScreen({super.key});

  @override
  ConsumerState<InstituteSettingsScreen> createState() => _InstituteSettingsScreenState();
}

class _InstituteSettingsScreenState extends ConsumerState<InstituteSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(instituteSettingsProvider);

    return Scaffold(
      body: settingsAsync.when(
        data: (settings) {
          // Populate controllers if they're empty
          if (_latitudeController.text.isEmpty) {
            _latitudeController.text = settings.latitude.toString();
            _longitudeController.text = settings.longitude.toString();
            _radiusController.text = settings.radius.toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Institute Settings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Geo-Fencing Configuration',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Set the institute location and allowed radius for attendance.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _latitudeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Latitude',
                                    border: OutlineInputBorder(),
                                    helperText: 'e.g., 40.7128',
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Required';
                                    final number = double.tryParse(value!);
                                    if (number == null) return 'Invalid number';
                                    if (number < -90 || number > 90) return 'Must be between -90 and 90';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _longitudeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Longitude',
                                    border: OutlineInputBorder(),
                                    helperText: 'e.g., -74.0060',
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Required';
                                    final number = double.tryParse(value!);
                                    if (number == null) return 'Invalid number';
                                    if (number < -180 || number > 180) return 'Must be between -180 and 180';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _radiusController,
                            decoration: const InputDecoration(
                              labelText: 'Allowed Radius (meters)',
                              border: OutlineInputBorder(),
                              helperText: 'e.g., 100',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Required';
                              final number = double.tryParse(value!);
                              if (number == null) return 'Invalid number';
                              if (number <= 0) return 'Must be greater than 0';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => _saveSettings(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                            child: const Text('Save Settings'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Settings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _SettingRow(
                          label: 'Latitude',
                          value: settings.latitude.toStringAsFixed(6),
                          icon: Icons.place,
                        ),
                        const SizedBox(height: 12),
                        _SettingRow(
                          label: 'Longitude',
                          value: settings.longitude.toStringAsFixed(6),
                          icon: Icons.place,
                        ),
                        const SizedBox(height: 12),
                        _SettingRow(
                          label: 'Radius',
                          value: '${settings.radius.toStringAsFixed(0)} meters',
                          icon: Icons.radar,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(instituteNotifierProvider.notifier).updateSettings(
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        radius: double.parse(_radiusController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SettingRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }
}
