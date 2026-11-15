import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/models/health_data.dart';
import 'package:stresspredictor/models/live_multimodal_result.dart';
import 'package:stresspredictor/providers/stress_provider.dart';
import 'package:stresspredictor/services/api_service.dart';
import 'package:stresspredictor/services/health_service.dart';

class LiveAnalysisScreen extends StatefulWidget {
  const LiveAnalysisScreen({super.key, this.initialData});

  final HealthData? initialData;

  @override
  State<LiveAnalysisScreen> createState() => _LiveAnalysisScreenState();
}

class _LiveAnalysisScreenState extends State<LiveAnalysisScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  HealthData? _healthData;
  LiveMultimodalResult? _result;
  Timer? _captureTimer;
  Completer<void>? _captureCompleted;
  bool _cameraLoading = true;
  bool _healthLoading = true;
  bool _isAnalyzing = false;
  bool _requestInFlight = false;
  String? _cameraError;
  String? _analysisError;
  final Map<String, TextEditingController> _inputControllers = {};

  static const _inputDefinitions = <(String, String, String)>[
    ('snoring_rate', 'Snoring rate', 'events/hour'),
    ('respiration_rate', 'Respiration rate', 'breaths/min'),
    ('body_temperature', 'Body temperature', '°F'),
    ('limb_movement_rate', 'Limb movement rate', 'events/hour'),
    ('blood_oxygen', 'Blood oxygen', '%'),
    ('eye_movement', 'Eye movement', 'events/hour'),
    ('sleep_hours', 'Sleep hours', 'hours'),
    ('heart_rate', 'Heart rate', 'bpm'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _healthData =
        widget.initialData ?? context.read<StressProvider>().currentHealthData;
    if (_healthData != null) _initializeInputControllers(_healthData!);
    _healthLoading = _healthData == null;
    if (_healthData == null) _loadHealthData();
    _initializeCamera();
  }

  Future<void> _loadHealthData() async {
    try {
      final data = await HealthService.instance.fetchHealthData();
      if (!mounted) return;
      setState(() {
        _healthData = data;
        _initializeInputControllers(data);
        _healthLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _healthLoading = false;
        _analysisError = 'Could not load your current health data: $error';
      });
    }
  }

  void _initializeInputControllers(HealthData data) {
    final values = <String, double>{
      'snoring_rate': data.snoringRate,
      'respiration_rate': data.respirationRate,
      'body_temperature': data.bodyTemperature,
      'limb_movement_rate': data.limbMovementRate,
      'blood_oxygen': data.bloodOxygen,
      'eye_movement': data.eyeMovement,
      'sleep_hours': data.sleepHours,
      'heart_rate': data.heartRate,
    };
    for (final (key, _, _) in _inputDefinitions) {
      _inputControllers[key]?.dispose();
      _inputControllers[key] = TextEditingController(
        // Existing HealthData values are useful editable prototype defaults.
        // The user can change any field before starting analysis.
        text: _formatInput(values[key]!),
      );
    }
  }

  String _formatInput(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  double? _readInput(String key) =>
      double.tryParse(_inputControllers[key]?.text.trim() ?? '');

  bool get _hasCompleteInputs => _inputDefinitions.every((field) {
    final value = _readInput(field.$1);
    return value != null && value.isFinite;
  });

  HealthData? _healthDataWithEnteredValues() {
    final data = _healthData;
    if (data == null || !_hasCompleteInputs) return null;
    return data.copyWith(
      snoringRate: _readInput('snoring_rate'),
      respirationRate: _readInput('respiration_rate'),
      bodyTemperature: _readInput('body_temperature'),
      limbMovementRate: _readInput('limb_movement_rate'),
      bloodOxygen: _readInput('blood_oxygen'),
      eyeMovement: _readInput('eye_movement'),
      sleepHours: _readInput('sleep_hours'),
      heartRate: _readInput('heart_rate'),
    );
  }

  Future<void> _initializeCamera() async {
    if (mounted) {
      setState(() {
        _cameraLoading = true;
        _cameraError = null;
      });
    }
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      final frontCameras = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.front)
          .toList();
      if (frontCameras.isEmpty) {
        throw CameraException(
          'NoFrontCamera',
          'This device does not have a front-facing camera.',
        );
      }

      controller = CameraController(
        frontCameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _cameraLoading = false;
      });
    } on CameraException catch (error) {
      await controller?.dispose();
      if (!mounted) return;
      setState(() {
        _cameraLoading = false;
        _cameraError = _cameraExceptionMessage(error);
      });
    } catch (error) {
      await controller?.dispose();
      if (!mounted) return;
      setState(() {
        _cameraLoading = false;
        _cameraError = 'Could not open the front camera: $error';
      });
    }
  }

  String _cameraExceptionMessage(CameraException error) {
    return switch (error.code) {
      'CameraAccessDenied' =>
        'Camera permission was denied. Allow camera access in system settings, then try again.',
      'CameraAccessDeniedWithoutPrompt' =>
        'Camera permission is off. Allow camera access in system settings, then try again.',
      'CameraAccessRestricted' => 'Camera access is restricted on this device.',
      'NoFrontCamera' => error.description ?? 'No front camera is available.',
      _ => error.description ?? 'Could not open the camera (${error.code}).',
    };
  }

  Future<void> _startAnalysis() async {
    if (_isAnalyzing || _healthLoading) return;
    if (_healthData == null) {
      setState(() => _analysisError = 'Health data is not available yet.');
      return;
    }
    final enteredData = _healthDataWithEnteredValues();
    if (enteredData == null) {
      setState(() => _analysisError = 'Enter all eight physiological values.');
      return;
    }
    _healthData = enteredData;
    if (_cameraController == null) {
      await _initializeCamera();
      if (_cameraController == null || !mounted) return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });
    _captureTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _captureAndAnalyze(),
    );
    _captureAndAnalyze();
  }

  Future<void> _stopAnalysis() async {
    _captureTimer?.cancel();
    _captureTimer = null;
    if (mounted && _isAnalyzing) {
      setState(() => _isAnalyzing = false);
    }

    final captureCompleted = _captureCompleted;
    if (captureCompleted != null) await captureCompleted.future;

    final controller = _cameraController;
    _cameraController = null;
    if (mounted) setState(() {});
    await controller?.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isAnalyzing || _requestInFlight) return;
    final controller = _cameraController;
    final healthData = _healthDataWithEnteredValues();
    if (controller == null ||
        !controller.value.isInitialized ||
        healthData == null) {
      return;
    }

    _requestInFlight = true;
    XFile? imageFile;
    final captureCompleted = Completer<void>();
    _captureCompleted = captureCompleted;
    if (mounted) setState(() => _analysisError = null);

    try {
      imageFile = await controller.takePicture();
      final imageBytes = await imageFile.readAsBytes();
      if (!captureCompleted.isCompleted) captureCompleted.complete();
      if (mounted) setState(() {});

      final result = await ApiService.instance.analyzeLiveMultimodal(
        imageBytes,
        healthData,
      );
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) setState(() => _analysisError = _formatError(error));
    } finally {
      if (!captureCompleted.isCompleted) captureCompleted.complete();
      if (identical(_captureCompleted, captureCompleted)) {
        _captureCompleted = null;
      }
      if (imageFile != null) {
        try {
          await File(imageFile.path).delete();
        } catch (_) {
          // Temporary camera image cleanup is best effort.
        }
      }
      _requestInFlight = false;
      if (mounted) setState(() {});
    }
  }

  String _formatError(Object error) {
    if (error is TimeoutException) {
      return 'The backend timed out. Check your connection and try again.';
    }
    if (error is SocketException) {
      return 'Cannot reach the backend. Check that your device is on the project network.';
    }
    if (error is FormatException || error is TypeError) {
      return 'The backend returned an invalid response. Please try again.';
    }
    if (error is CameraException) return _cameraExceptionMessage(error);
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_stopAnalysis());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureTimer?.cancel();
    final controller = _cameraController;
    final captureCompleted = _captureCompleted;
    if (controller != null) {
      if (captureCompleted != null) {
        captureCompleted.future.whenComplete(controller.dispose);
      } else {
        controller.dispose();
      }
    }
    for (final controller in _inputControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    final result = _result;
    final scheme = Theme.of(context).colorScheme;
    final missingInputs = _inputDefinitions
        .where((field) {
          final value = _readInput(field.$1);
          return value == null || !value.isFinite;
        })
        .map((field) => field.$2)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Live Stress Analysis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: controller?.value.isInitialized == true
                  ? controller!.value.aspectRatio
                  : 4 / 3,
              child: controller?.value.isInitialized == true
                  ? CameraPreview(controller!)
                  : _cameraPlaceholder(context),
            ),
          ),
          if (_cameraError != null) ...[
            const SizedBox(height: 10),
            _NoticeCard(message: _cameraError!, isError: true),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _cameraLoading ? null : _initializeCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry camera'),
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _cameraLoading || _healthLoading
                ? null
                : _isAnalyzing
                ? _stopAnalysis
                : !_hasCompleteInputs
                ? null
                : _startAnalysis,
            icon: _cameraLoading || _healthLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isAnalyzing
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                  ),
            label: Text(
              _cameraLoading
                  ? 'Opening camera…'
                  : _healthLoading
                  ? 'Loading health data…'
                  : _isAnalyzing
                  ? 'Stop Analysis'
                  : 'Start Analysis',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: _isAnalyzing ? AppColors.error : scheme.primary,
              foregroundColor: _isAnalyzing ? Colors.white : scheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isAnalyzing
                ? _requestInFlight
                      ? 'Analyzing the latest frame…'
                      : 'Sampling at up to one frame per second.'
                : 'Press Start Analysis to begin. Camera frames are not sent before you start.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (_requestInFlight && _isAnalyzing) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(minHeight: 2),
          ],
          if (_healthData != null) ...[
            const SizedBox(height: 16),
            _PhysiologicalInputs(
              controllers: _inputControllers,
              onChanged: () => setState(() => _analysisError = null),
            ),
          ],
          if (missingInputs.isNotEmpty) ...[
            const SizedBox(height: 10),
            _NoticeCard(
              message: 'Enter a value for: ${missingInputs.join(', ')}.',
              isError: false,
            ),
          ],
          if (_analysisError != null) ...[
            const SizedBox(height: 12),
            _NoticeCard(message: _analysisError!, isError: true),
          ],
          if (result != null) ...[
            const SizedBox(height: 18),
            _ResultSection(result: result),
          ],
        ],
      ),
    );
  }

  Widget _cameraPlaceholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: _cameraLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _cameraError == null
                      ? Icons.camera_alt_outlined
                      : Icons.no_photography_outlined,
                  size: 42,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  _cameraError == null
                      ? 'Camera preview is paused'
                      : 'Front camera unavailable',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
    );
  }
}

class _PhysiologicalInputs extends StatelessWidget {
  const _PhysiologicalInputs({
    required this.controllers,
    required this.onChanged,
  });

  final Map<String, TextEditingController> controllers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Physiological inputs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 3),
            Text(
              'Enter measured values for this analysis.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ..._LiveAnalysisScreenState._inputDefinitions.map((field) {
              final (key, label, unit) = field;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: controllers[key],
                  onChanged: (_) => onChanged(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: label,
                    suffixText: unit,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.result});

  final LiveMultimodalResult result;

  String _metric(double? value, {int digits = 3}) =>
      value == null ? '—' : value.toStringAsFixed(digits);

  String _humanizeMachineValue(String? value) {
    if (value == null || value.isEmpty) return '—';
    final words = value.replaceAll('_', ' ').trim();
    if (words.isEmpty) return '—';
    return '${words[0].toUpperCase()}${words.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final vision = result.vision;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latest result', style: theme.textTheme.titleLarge),
        const SizedBox(height: 10),
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FINAL STRESS', style: theme.textTheme.labelSmall),
                      const SizedBox(height: 4),
                      Text(
                        result.finalStress.label,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Level ${result.finalStress.level} / 4',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${result.finalStress.level}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _ResultRow(
                  label: 'Physiological stress',
                  value:
                      '${result.physiologicalStress.label} · ${result.physiologicalStress.level}/4',
                ),
                _ResultRow(
                  label: 'Face detected',
                  value: vision.faceDetected ? 'Yes' : 'No',
                ),
                _ResultRow(
                  label: 'Facial expression',
                  value: _humanizeMachineValue(vision.dominantExpression),
                ),
                _ResultRow(
                  label: 'Expression stability',
                  value: _metric(vision.expressionStability),
                ),
                _ResultRow(
                  label: 'Average EAR',
                  value: _metric(vision.averageEar),
                ),
                _ResultRow(
                  label: 'Closed-eye ratio',
                  value: _metric(vision.closedEyeRatio),
                ),
                _ResultRow(
                  label: 'Longest eye closure',
                  value: '${_metric(vision.longestEyeClosure)} s',
                ),
                _ResultRow(
                  label: 'Fatigue indicator',
                  value: _humanizeMachineValue(vision.fatigueIndicator),
                  multilineValue: true,
                ),
                _ResultRow(
                  label: 'Frames analyzed',
                  value: '${vision.framesAnalyzed}',
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        if (!vision.faceDetected) ...[
          const SizedBox(height: 8),
          const _NoticeCard(
            message:
                'No face was detected. Face the camera and keep your face well lit.',
            isError: false,
          ),
        ],
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.isLast = false,
    this.multilineValue = false,
  });

  final String label;
  final String value;
  final bool isLast;
  final bool multilineValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
      child: multilineValue
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    value,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
