part of '../feed_page.dart';

class _RouteFullscreenPage extends StatelessWidget {
  final List<LatLng> routePoints;

  const _RouteFullscreenPage({
    required this.routePoints,
  });

  static const Color _bg = Color(0xFF000000);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '이동 경로',
          style: TextStyle(
            color: _primaryText,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _primaryText,
            size: 18,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.7),
          child: Divider(
            color: _line,
            height: 0.7,
            thickness: 0.7,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(14),
              child: _FeedRoutePreviewMap(
                routePoints: routePoints,
                height: constraints.maxHeight,
                borderRadius: 24,
                showLabel: true,
                compact: false,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeedRoutePreviewMap extends StatefulWidget {
  final List<LatLng> routePoints;
  final double height;
  final double borderRadius;
  final bool showLabel;
  final bool compact;
  final VoidCallback? onTap;

  const _FeedRoutePreviewMap({
    required this.routePoints,
    this.height = 190,
    this.borderRadius = 18,
    this.showLabel = true,
    this.compact = false,
    this.onTap,
  });

  @override
  State<_FeedRoutePreviewMap> createState() => _FeedRoutePreviewMapState();
}

class _FeedRoutePreviewMapState extends State<_FeedRoutePreviewMap> {
  GoogleMapController? _controller;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _accent = Color(0xFF5DADEC);

  static const LatLng _defaultCenter = LatLng(35.8714, 128.6014);

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FeedRoutePreviewMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.routePoints.length != widget.routePoints.length) {
      _fitCameraToRoute();
    }
  }

  Future<void> _fitCameraToRoute() async {
    final controller = _controller;
    final points = widget.routePoints;

    if (controller == null || points.isEmpty) return;

    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    try {
      if (points.length == 1) {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: points.first,
              zoom: 16,
            ),
          ),
        );
        return;
      }

      final bounds = _boundsFromLatLngList(points);

      final sameLat = bounds.southwest.latitude == bounds.northeast.latitude;
      final sameLng = bounds.southwest.longitude == bounds.northeast.longitude;

      if (sameLat && sameLng) {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: points.last,
              zoom: 16,
            ),
          ),
        );
        return;
      }

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          42,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: points.last,
            zoom: 16,
          ),
        ),
      );
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Set<Polyline> _buildPolylines() {
    final points = widget.routePoints;

    if (points.length < 2) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('feed_route'),
        points: points,
        width: widget.compact ? 4 : 6,
        color: _accent,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    final points = widget.routePoints;

    if (points.isEmpty) {
      return {};
    }

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('feed_start'),
        position: points.first,
        infoWindow: const InfoWindow(title: '시작'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
      ),
    };

    if (points.length >= 2) {
      markers.add(
        Marker(
          markerId: const MarkerId('feed_finish'),
          position: points.last,
          infoWindow: const InfoWindow(title: '종료'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.routePoints;
    final initialTarget = points.isNotEmpty ? points.first : _defaultCenter;

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _controller = controller;
              _fitCameraToRoute();
            },
            polylines: _buildPolylines(),
            markers: _buildMarkers(),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
          ),
          if (widget.showLabel)
            Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(170),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withAlpha(18),
                  width: 0.8,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.route_outlined,
                    size: 15,
                    color: _accent,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '이동 경로',
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.onTap != null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
