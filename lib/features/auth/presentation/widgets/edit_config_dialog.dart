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
  bool autoAssignColor = false;
  PlatformFile? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final restaurantConfig = ref.read(restaurantConfigProvider);
    pickerColor =
        hexToColor(restaurantConfig.value?['primary_color'] ?? '#3B82F6');
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _image = result.files.single;
      });

      if (autoAssignColor) {
        final paletteGenerator = await PaletteGenerator.fromImageProvider(
          FileImage(File(_image!.path!)),
        );
        if (paletteGenerator.dominantColor != null) {
          setState(() {
            pickerColor = paletteGenerator.dominantColor!.color;
          });
        }
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
            if (_image != null)
              Image.file(
                File(_image!.path!),
                height: 150,
              ),
            const SizedBox(height: 20),
            const Text('Primary Color'),
            const SizedBox(height: 10),
            ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => setState(() => pickerColor = color),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Choose Logo'),
            ),
            SwitchListTile(
              title: const Text('Auto-assign color from logo'),
              value: autoAssignColor,
              onChanged: (value) {
                setState(() {
                  autoAssignColor = value;
                });
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
                    final color =
                        '#${pickerColor.value.toRadixString(16).substring(2)}';
                    String? imageUrl;
                    if (_image != null) {
                      final imageFile = File(_image!.path!);
                      final fileName =
                          '${DateTime.now().millisecondsSinceEpoch}.png';
                      await Supabase.instance.client.storage
                          .from('logos')
                          .upload(fileName, imageFile);
                      imageUrl = Supabase.instance.client.storage
                          .from('logos')
                          .getPublicUrl(fileName);
                    }

                    final updates = {
                      'primary_color': color,
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
}