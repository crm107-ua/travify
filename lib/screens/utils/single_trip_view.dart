import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travify/constants/env.dart';
import 'package:travify/constants/images.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/screens/trip_screen.dart';

class SingleTripFullScreen extends StatefulWidget {
  final Trip trip;
  final Widget Function(String?) buildAppBarBackground;

  const SingleTripFullScreen({
    super.key,
    required this.trip,
    required this.buildAppBarBackground,
  });

  @override
  State<SingleTripFullScreen> createState() => _SingleTripFullScreenState();
}

class _SingleTripFullScreenState extends State<SingleTripFullScreen> {
  late Duration _remaining;
  late Timer _timer;
  bool _showConfetti = false;
  bool _confettiAlreadyShown = false;

  @override
  void initState() {
    super.initState();

    if (!AppEnv.production) {
      widget.trip.dateStart = DateTime.now().add(const Duration(seconds: 3));
    }
    _loadConfettiShownFlag();
    _updateCountdown();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  Future<void> _loadConfettiShownFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'confetti_show_${widget.trip.id}';
    final alreadyShown = prefs.getBool(key) ?? false;
    setState(() {
      _confettiAlreadyShown = alreadyShown;
    });
  }

  void _updateCountdown() async {
    final now = DateTime.now();
    final diff = widget.trip.dateStart.difference(now);

    setState(() {
      _remaining = diff;
    });

    if (!_confettiAlreadyShown && diff <= Duration.zero && !_showConfetti) {
      setState(() {
        _showConfetti = true;
      });

      await Future.delayed(const Duration(seconds: 4));

      final prefs = await SharedPreferences.getInstance();
      final key = 'confetti_show_${widget.trip.id}';
      await prefs.setBool(key, true);

      if (mounted) {
        setState(() {
          _showConfetti = false;
          _confettiAlreadyShown = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final time =
        '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';

    return days > 0 ? '${days}d $time' : time;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final now = DateTime.now();
    final isUpcoming = trip.dateStart.isAfter(now);
    final locale = context.locale.toString();
    final dateFormat = DateFormat('dd MMM', locale);

    String subtitle = '';
    if (isUpcoming) {
      subtitle = 'get_ready'.tr();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.buildAppBarBackground(trip.image),
        Container(color: Colors.black.withOpacity(0.1)),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.1)),
        ),
        if (_showConfetti)
          Positioned.fill(
            child: Lottie.asset(
              AppImages.readyLottie,
              fit: BoxFit.cover,
              repeat: false,
            ),
          ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpcoming) ...[
                  Text(
                    _formatDuration(_remaining),
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black45,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Hero(
                  tag: 'trip-title-${trip.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      trip.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black45,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  trip.countries.map((c) => c.name).join(', '),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      '${dateFormat.format(trip.dateStart)}'
                      '${trip.dateEnd != null ? ' - ${dateFormat.format(trip.dateEnd!)}' : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailPage(trip: trip),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  label: Text('see'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
