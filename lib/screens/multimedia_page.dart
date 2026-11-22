import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class MultimediaPage extends StatefulWidget {
  const MultimediaPage({super.key});

  @override
  State<MultimediaPage> createState() => _MultimediaPageState();
}

class _MultimediaPageState extends State<MultimediaPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Uint8List? _imageBytes;
  String? _imageName;
  int? _imageSize;
  String? _audioPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _busy = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    unawaited(_playerStateSubscription?.cancel());
    unawaited(_audioRecorder.dispose());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  Future<bool> _requestPermission(
    Permission permission, {
    required String resource,
    required String reason,
  }) async {
    if (kIsWeb) return true;

    var status = await permission.status;
    if (status.isGranted) return true;

    if (!mounted) return false;
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Autorisation $resource'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Pas maintenant'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
    if (shouldRequest != true) return false;

    status = await permission.request();
    if (status.isGranted) return true;

    if (!mounted) return false;
    if (status.isPermanentlyDenied || status.isRestricted) {
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Accès $resource refusé définitivement'),
          content: Text(
            'L’autorisation a été refusée. Vous pouvez la modifier dans les '
            'paramètres de l’application.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Fermer'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ouvrir les réglages'),
            ),
          ],
        ),
      );
      if (openSettings == true) await openAppSettings();
    } else {
      _showMessage('Autorisation $resource refusée.');
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
      );
      if (!mounted) return;
      if (image == null) {
        _showMessage('Sélection annulée.');
        return;
      }

      final imageSize = await image.length();
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
        _imageSize = imageSize;
      });
    } on PlatformException catch (error) {
      _showPluginError('Impossible de récupérer cette image', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _playRecording();
      }
    } on PlatformException catch (error) {
      _showPluginError('Impossible de modifier la lecture', error);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);

    try {
      if (!await _requestPermission(
        Permission.microphone,
        resource: 'du microphone',
        reason:
            'Le microphone est utilisé uniquement pour enregistrer un mémo audio '
            'sur cet appareil.',
      )) {
        return;
      }

      if (!await _audioRecorder.hasPermission()) {
        _showMessage('Accès au microphone refusé.');
        return;
      }

      final encoder = kIsWeb ? AudioEncoder.wav : AudioEncoder.aacLc;
      final extension = kIsWeb ? 'wav' : 'm4a';
      final recordingPath = kIsWeb
          ? 'emsi_recording.$extension'
          : path.join(
              (await getTemporaryDirectory()).path,
              'question_emsi_${DateTime.now().millisecondsSinceEpoch}.$extension',
            );
      await _audioRecorder.start(
        RecordConfig(encoder: encoder),
        path: recordingPath,
      );
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _audioPath = null;
        _recordingDuration = Duration.zero;
      });
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        }
      });
    } on PlatformException catch (error) {
      _showPluginError('Impossible de démarrer l’enregistrement', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stopRecording() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final recordedPath = await _audioRecorder.stop();
      _recordingTimer?.cancel();
      _recordingTimer = null;
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _audioPath = recordedPath;
      });
      _showMessage(
        recordedPath == null
            ? 'Aucun fichier enregistré.'
            : 'Question vocale enregistrée.',
      );
    } on PlatformException catch (error) {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      if (mounted) setState(() => _isRecording = false);
      _showPluginError('Erreur lors de l’arrêt', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _playRecording() async {
    final recordingPath = _audioPath;
    if (recordingPath == null) return;

    try {
      await _audioPlayer.play(
        kIsWeb ? UrlSource(recordingPath) : DeviceFileSource(recordingPath),
      );
    } on PlatformException catch (error) {
      _showPluginError('Impossible de lire cet enregistrement', error);
    }
  }

  void _showPluginError(String action, PlatformException error) {
    debugPrint('$action: ${error.message ?? error.code}');
    _showMessage('$action. Vérifiez les autorisations et réessayez.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isRecording,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isRecording) {
          _showMessage('Arrêtez l’enregistrement avant de quitter cette page.');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Espace multimédia')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Images et audio',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez une image ou enregistrez un mémo audio. '
                'Les autorisations sont demandées uniquement au moment nécessaire.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.image_outlined),
                        title: Text('Image'),
                        subtitle: Text(
                          'Prenez une photo ou choisissez-en une.',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Prendre une photo'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galerie'),
                      ),
                      if (_imageBytes != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imageBytes!,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _imageName ?? 'Image sélectionnée',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Taille : ${_imageSize ?? 0} octets',
                          textAlign: TextAlign.center,
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () {
                                  setState(() {
                                    _imageBytes = null;
                                    _imageName = null;
                                    _imageSize = null;
                                  });
                                },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Effacer l’image'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.mic_none),
                        title: Text('Question vocale'),
                        subtitle: Text(
                          'L’enregistrement est conservé localement sur cet appareil.',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _busy ? null : _toggleRecording,
                        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                        label: Text(_isRecording ? 'Arrêter' : 'Enregistrer'),
                      ),
                      if (_isRecording || _audioPath != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Durée : ${_formatDuration(_recordingDuration)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _audioPath == null || _isRecording
                            ? null
                            : _togglePlayback,
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        label: Text(
                          _isPlaying
                              ? 'Lecture en cours'
                              : 'Écouter l’enregistrement',
                        ),
                      ),
                      if (_audioPath != null && !_isRecording) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Un enregistrement est prêt à être écouté.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_busy) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
