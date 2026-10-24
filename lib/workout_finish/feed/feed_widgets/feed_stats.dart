part of '../feed_page.dart';

class _WorkoutStatsPanel extends StatelessWidget {
  final String distanceText;
  final String durationText;
  final String paceText;
  final String speedText;

  const _WorkoutStatsPanel({
    required this.distanceText,
    required this.durationText,
    required this.paceText,
    required this.speedText,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 340;

          return GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 9,
            crossAxisSpacing: 9,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: compact ? 1.88 : 2.15,
            children: [
              _WorkoutMetricTile(
                icon: Icons.route_outlined,
                label: '거리',
                value: distanceText,
              ),
              _WorkoutMetricTile(
                icon: Icons.timer_outlined,
                label: '시간',
                value: durationText,
              ),
              _WorkoutMetricTile(
                icon: Icons.directions_run_outlined,
                label: '페이스',
                value: paceText,
              ),
              _WorkoutMetricTile(
                icon: Icons.speed_outlined,
                label: '속도',
                value: speedText,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkoutMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WorkoutMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _accent,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
