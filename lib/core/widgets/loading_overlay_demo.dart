import 'package:flutter/material.dart';
import 'loading_overlay.dart';

/// Demo widget to showcase the new Cendra loading overlay
/// This can be used for testing and demonstration purposes
class LoadingOverlayDemo extends StatefulWidget {
  const LoadingOverlayDemo({super.key});

  @override
  State<LoadingOverlayDemo> createState() => _LoadingOverlayDemoState();
}

class _LoadingOverlayDemoState extends State<LoadingOverlayDemo> {
  bool _isLoading = false;
  String _currentMessage = 'Loading...';

  final List<String> _messages = [
    'Loading...',
    'Signing you in...',
    'Preparing your workspace...',
    'Syncing restaurant data...',
    'Setting up tables...',
    'Loading menu items...',
    'Connecting to server...',
    'Almost ready...',
  ];

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
      if (_isLoading) {
        _currentMessage = _messages[0];
      }
    });
  }

  void _changeMessage() {
    if (_isLoading) {
      setState(() {
        final currentIndex = _messages.indexOf(_currentMessage);
        final nextIndex = (currentIndex + 1) % _messages.length;
        _currentMessage = _messages[nextIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cendra Loading Overlay Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: _currentMessage,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cendra Loading Overlay Demo',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Test the new animated loading overlay with custom messages',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Current Message: $_currentMessage',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _toggleLoading,
                icon: Icon(_isLoading ? Icons.stop : Icons.play_arrow),
                label: Text(_isLoading ? 'Stop Loading' : 'Start Loading'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? _changeMessage : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Change Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Smooth fade in/out animations'),
                      const Text('• Rotating gradient ring'),
                      const Text('• Breathing logo effect'),
                      const Text('• Pulsing outer ring'),
                      const Text('• Floating particle effects'),
                      const Text('• Custom loading messages'),
                      const Text('• Cendra brand integration'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
