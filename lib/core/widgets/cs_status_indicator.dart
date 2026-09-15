import 'package:flutter/material.dart';
import '../services/chat_operating_hours_service.dart';

/// CS Status Indicator Widget
/// Shows online/offline status with operating hours info
class CSStatusIndicator extends StatefulWidget {
  final bool showHoursAlways;
  final EdgeInsets? padding;

  const CSStatusIndicator({
    super.key,
    this.showHoursAlways = false,
    this.padding,
  });

  @override
  State<CSStatusIndicator> createState() => _CSStatusIndicatorState();
}

class _CSStatusIndicatorState extends State<CSStatusIndicator> {
  final _hoursService = ChatOperatingHoursService();
  CSStatusInfo? _statusInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final info = await _hoursService.getCSStatusInfo();
    if (mounted) {
      setState(() {
        _statusInfo = info;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _statusInfo == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _statusInfo!.isOnline
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _statusInfo!.isOnline
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _statusInfo!.isOnline ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          
          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _statusInfo!.statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _statusInfo!.isOnline
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
                if (!_statusInfo!.isOnline || widget.showHoursAlways) ...[
                  const SizedBox(height: 4),
                  Text(
                    _statusInfo!.isOnline
                        ? 'Jam operasional: ${_statusInfo!.hoursText}'
                        : 'Jam operasional:\n${_statusInfo!.hoursText}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple CS Online Badge (for app bar)
class CSOnlineBadge extends StatefulWidget {
  const CSOnlineBadge({super.key});

  @override
  State<CSOnlineBadge> createState() => _CSOnlineBadgeState();
}

class _CSOnlineBadgeState extends State<CSOnlineBadge> {
  final _hoursService = ChatOperatingHoursService();
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final online = await _hoursService.isCSOnline();
    if (mounted) {
      setState(() {
        _isOnline = online;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _isOnline ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 12,
            color: _isOnline ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// CS Offline Notice (fullscreen overlay)
class CSOfflineNotice extends StatelessWidget {
  final VoidCallback? onClose;

  const CSOfflineNotice({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 64,
                color: Colors.orange.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Customer Service Offline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FutureBuilder<String>(
                future: ChatOperatingHoursService().getOperatingHoursText(),
                builder: (context, snapshot) {
                  return Text(
                    'Jam operasional:\n${snapshot.data ?? "Senin-Jumat, 06:00-15:00"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 24),
              if (onClose != null)
                ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Mengerti'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
