part of '../feed_page.dart';

class _FullScreenFeedHero extends StatelessWidget {
  final double height;
  final List<String> imageUrls;
  final String? thumbnailUrl;
  final List<LatLng> routePoints;
  final bool hasImages;
  final bool hasRoute;
  final String distanceText;
  final String durationValue;
  final String durationUnit;
  final String paceValue;
  final String speedValue;

  const _FullScreenFeedHero({
    required this.height,
    required this.imageUrls,
    required this.thumbnailUrl,
    required this.routePoints,
    required this.hasImages,
    required this.hasRoute,
    required this.distanceText,
    required this.durationValue,
    required this.durationUnit,
    required this.paceValue,
    required this.speedValue,
  });

  void _openRouteFullscreen(BuildContext context) {
    if (routePoints.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _RouteFullscreenPage(
          routePoints: routePoints,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeroMediaBackground(
            height: height,
            imageUrls: imageUrls,
            thumbnailUrl: thumbnailUrl,
            routePoints: routePoints,
            hasImages: hasImages,
            hasRoute: hasRoute,
            onRouteTap: hasRoute ? () => _openRouteFullscreen(context) : null,
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x22000000),
                      Color(0x10000000),
                      Color(0xEC000000),
                    ],
                    stops: [0.0, 0.48, 1.0],
                  ),
                ),
              ),
            ),
          ),
          if (hasImages && hasRoute)
            Positioned(
              right: 14,
              top: 14,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openRouteFullscreen(context),
                child: SizedBox(
                  width: 126,
                  height: 106,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(125),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _FeedRoutePreviewMap(
                      routePoints: routePoints,
                      height: 106,
                      borderRadius: 20,
                      showLabel: false,
                      compact: true,
                      onTap: () => _openRouteFullscreen(context),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: IgnorePointer(
              child: _HeroStatsOverlay(
                distanceText: distanceText,
                durationValue: durationValue,
                durationUnit: durationUnit,
                paceValue: paceValue,
                speedValue: speedValue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _HeroMediaBackground extends StatelessWidget {
  final double height;
  final List<String> imageUrls;
  final String? thumbnailUrl;
  final List<LatLng> routePoints;
  final bool hasImages;
  final bool hasRoute;
  final VoidCallback? onRouteTap;

  const _HeroMediaBackground({
    required this.height,
    required this.imageUrls,
    required this.thumbnailUrl,
    required this.routePoints,
    required this.hasImages,
    required this.hasRoute,
    this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (hasImages) {
      return FeedImage(
        imageUrls: imageUrls,
        thumbnailUrl: thumbnailUrl,
        height: height,
        borderRadius: 28,
        indicatorBottom: 152,
      );
    }

    if (hasRoute) {
      return _FeedRoutePreviewMap(
        routePoints: routePoints,
        height: height,
        borderRadius: 28,
        onTap: onRouteTap,
      );
    }

    return _NoImageWorkoutBanner(
      height: height,
      borderRadius: 28,
    );
  }
}


class _HeroStatsOverlay extends StatelessWidget {
  final String distanceText;
  final String durationValue;
  final String durationUnit;
  final String paceValue;
  final String speedValue;

  const _HeroStatsOverlay({
    required this.distanceText,
    required this.durationValue,
    required this.durationUnit,
    required this.paceValue,
    required this.speedValue,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFFB9B9BE);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _accent.withAlpha(44),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _accent.withAlpha(98),
              width: 0.8,
            ),
          ),
          child: const Text(
            'TODAY WORKOUT',
            style: TextStyle(
              color: _primaryText,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distanceText,
                style: const TextStyle(
                  color: _primaryText,
                  fontSize: 58,
                  height: 0.88,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2.1,
                  shadows: [
                    Shadow(
                      color: Color(0xAA000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'km',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    shadows: [
                      Shadow(
                        color: Color(0xAA000000),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        _GlassStatsStrip(
          durationValue: durationValue,
          durationUnit: durationUnit,
          paceValue: paceValue,
          speedValue: speedValue,
        ),
      ],
    );
  }
}

class _GlassStatsStrip extends StatelessWidget {
  final String durationValue;
  final String durationUnit;
  final String paceValue;
  final String speedValue;

  const _GlassStatsStrip({
    required this.durationValue,
    required this.durationUnit,
    required this.paceValue,
    required this.speedValue,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFFB9B9BE);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(122),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(28),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(70),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverlayMiniStat(
              label: '시간',
              value: durationValue,
              unit: durationUnit,
            ),
          ),
          const _OverlayStatDivider(),
          Expanded(
            child: _OverlayMiniStat(
              label: '페이스',
              value: paceValue,
              unit: '/km',
            ),
          ),
          const _OverlayStatDivider(),
          Expanded(
            child: _OverlayMiniStat(
              label: '속도',
              value: speedValue,
              unit: 'km/h',
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _OverlayMiniStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFFB9B9BE);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _secondaryText,
            fontSize: 10.8,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  color: _primaryText,
                  fontSize: 20.5,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.65,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    maxLines: 1,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 10.5,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OverlayStatDivider extends StatelessWidget {
  const _OverlayStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withAlpha(22),
    );
  }
}

class _HeroMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroMetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFFB9B9BE);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 82),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(136),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withAlpha(24),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _accent,
            size: 15,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 12.4,
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
