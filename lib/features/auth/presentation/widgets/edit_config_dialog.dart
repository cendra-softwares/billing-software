import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:seo_biling/features/auth/presentation/providers/dashboard_providers.dart';
import 'package:seo_biling/features/auth/presentation/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditConfigDialog extends ConsumerStatefulWidget {
  const EditConfigDialog({super.key});

  @override
  ConsumerState<EditConfigDialog> createState() => _EditConfigDialogState();
}

class _EditConfigDialogState extends ConsumerState<EditConfigDialog> {
  late Color pickerColor;
  late Color secondaryColor;
  late Color accentColor;
  bool autoAssignColor = false;
  PlatformFile? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final restaurantConfig = ref.read(restaurantConfigProvider);
    pickerColor = hexToColor(
      restaurantConfig.value?['primary_color'] ?? '#3B82F6',
    );
    secondaryColor = hexToColor(
      restaurantConfig.value?['secondary_color'] ?? '#6366F1',
    );
    accentColor = hexToColor(
      restaurantConfig.value?['accent_color'] ?? '#FACC15',
    );
  }

  Future<void> _updateColorsFromImage() async {
    if (_image == null) return;

    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      FileImage(File(_image!.path!)),
    );

    setState(() {
      pickerColor = paletteGenerator.dominantColor?.color ?? pickerColor;
      secondaryColor =
          paletteGenerator.lightVibrantColor?.color ?? secondaryColor;
      accentColor = paletteGenerator.vibrantColor?.color ?? accentColor;
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _image = result.files.single;
      });

      if (autoAssignColor) {
        await _updateColorsFromImage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ref.watch(restaurantProvider);
    final restaurantConfig = ref.watch(restaurantConfigProvider);

    return AlertDialog(
      title: const Text('Edit Configuration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_image != null) Image.file(File(_image!.path!), height: 150),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColorDisplay('Primary', pickerColor),
                _buildColorDisplay('Secondary', secondaryColor),
                _buildColorDisplay('Accent', accentColor),
              ],
            ),
            const SizedBox(height: 20),
            AbsorbPointer(
              absorbing: autoAssignColor,
              child: Opacity(
                opacity: autoAssignColor ? 0.5 : 1.0,
                child: ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (color) =>
                      setState(() => pickerColor = color),
                  enableAlpha: false,
                  displayThumbColor: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Choose Logo'),
            ),
            SwitchListTile(
              title: const Text('Auto-assign colors from logo'),
              value: autoAssignColor,
              onChanged: (value) async {
                setState(() {
                  autoAssignColor = value;
                });
                if (autoAssignColor) {
                  await _updateColorsFromImage();
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final primaryColorHex =
                        '#${pickerColor.value.toRadixString(16).substring(2)}';
                    final secondaryColorHex =
                        '#${secondaryColor.value.toRadixString(16).substring(2)}';
                    final accentColorHex =
                        '#${accentColor.value.toRadixString(16).substring(2)}';

                    String? imageUrl;
                    if (_image != null) {
                      final imageFile = File(_image!.path!);
                      final restaurantId = restaurant.value!['id'];
                      final fileName = '$restaurantId.png';
                      final config = ref.read(restaurantConfigProvider).value;
                      final existingLogoUrl = config?['logo_url'] as String?;

                      if (existingLogoUrl != null &&
                          existingLogoUrl.isNotEmpty) {
                        // A logo exists, so we update it.
                        await Supabase.instance.client.storage
                            .from('logos')
                            .update(
                              fileName,
                              imageFile,
                              fileOptions: const FileOptions(
                                cacheControl: 'max-age=0',
                              ),
                            );
                      } else {
                        // No logo exists, so we upload a new one.
                        await Supabase.instance.client.storage
                            .from('logos')
                            .upload(
                              fileName,
                              imageFile,
                              fileOptions: const FileOptions(
                                cacheControl: 'max-age=0',
                              ),
                            );
                      }

                      final publicUrl = Supabase.instance.client.storage
                          .from('logos')
                          .getPublicUrl(fileName);
                      imageUrl =
                          '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
                    }

                    final updates = {
                      'primary_color': primaryColorHex,
                      'secondary_color': secondaryColorHex,
                      'accent_color': accentColorHex,
                      if (imageUrl != null) 'logo_url': imageUrl,
                    };

                    if (restaurant.value != null) {
                      await Supabase.instance.client
                          .from('restaurant_config')
                          .update(updates)
                          .eq('restaurant_id', restaurant.value!['id']);
                    }

                    ref.invalidate(restaurantConfigProvider);
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error saving configuration: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildColorDisplay(String title, Color color) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 4),
        CircleAvatar(backgroundColor: color, radius: 20),
      ],
    );
  }
}
