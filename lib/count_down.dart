import 'dart:async';
import 'package:flutter/material.dart';

class CountDown extends StatefulWidget {
  final Duration duration;
  final Widget? replacement;
  final TextStyle? style;
  final TextStyle? separatorStyle;
  final VoidCallback? onDone;
  final bool showMinutes;
  final bool showSeconds;

  const CountDown({
    super.key,
    required this.duration,
    this.replacement,
    this.style,
    this.separatorStyle,
    this.onDone,
    this.showMinutes = true,
    this.showSeconds = true,
  });

  @override
  State<CountDown> createState() => CountDownState();
}

class CountDownState extends State<CountDown> {
  late Timer _timer;
  late Duration _remainingDuration;
  bool _isDone = false;

  void restart() {
    _timer.cancel();
    setState(() {
      _isDone = false;
      _remainingDuration = widget.duration;
    });
    _startTimer();
  }

  @override
  void initState() {
    super.initState();
    _remainingDuration = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingDuration.inSeconds > 0) {
            _remainingDuration =
                _remainingDuration - const Duration(seconds: 1);
          } else {
            _isDone = true;
            timer.cancel();
            widget.onDone?.call();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    if (_isDone && widget.replacement != null) {
      return widget.replacement!;
    }

    final minutes = _remainingDuration.inMinutes;
    final seconds = _remainingDuration.inSeconds % 60;

    final defaultStyle = widget.style ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        );

    final defaultSeparatorStyle = widget.separatorStyle ?? defaultStyle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showMinutes) ...[
          Text(
            _formatNumber(minutes),
            style: defaultStyle,
          ),
          Text(
            ':',
            style: defaultSeparatorStyle,
          ),
        ],
        if (widget.showSeconds)
          Text(
            _formatNumber(seconds),
            style: defaultStyle,
          ),
      ],
    );
  }
}
