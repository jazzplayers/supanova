part of '../feed_page.dart';

class _FeedMediaSection extends StatelessWidget {
  final List<String> imageUrls;
  final String? thumbnailUrl;
  final List<LatLng> routePoints;
  final bool hasImages;
  final bool hasRoute;

  const _FeedMediaSection({
    required this.imageUrls,
    required this.thumbnailUrl,
    required this.routePoints,
    required this.hasImages,
    required this.hasRoute,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasImages && !hasRoute) {
      return const _NoImageWorkoutBanner();
    }

    return Column(
      children: [
        if (hasImages)
          FeedImage(
            imageUrls: imageUrls,
            thumbnailUrl: thumbnailUrl,
          ),
        if (hasImages && hasRoute) const SizedBox(height: 10),
        if (hasRoute)
          _FeedRoutePreviewMap(
            routePoints: routePoints,
          ),
      ],
    );
  }
}

class FeedImage extends StatefulWidget {
  final List<String> imageUrls;
  final String? thumbnailUrl;
  final double? height;
  final double borderRadius;
  final double indicatorBottom;

  const FeedImage({
    super.key,
    required this.imageUrls,
    this.thumbnailUrl,
    this.height,
    this.borderRadius = 18,
    this.indicatorBottom = 12,
  });

  @override
  State<FeedImage> createState() => _FeedImageState();
}

class _FeedImageState extends State<FeedImage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String? _lastPrecacheSignature;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);

  List<String> get _validImageUrls {
    return widget.imageUrls
        .map((url) => url.trim())
        .where(_isValidNetworkImageUrl)
        .toList();
  }

  String? get _validThumbnailUrl {
    final thumbnailUrl = widget.thumbnailUrl?.trim();

    if (!_isValidNetworkImageUrl(thumbnailUrl)) {
      return null;
    }

    return thumbnailUrl;
  }

  @override
  void didUpdateWidget(covariant FeedImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrls.join('|') != widget.imageUrls.join('|')) {
      setState(() {
        _currentIndex = 0;
        _lastPrecacheSignature = null;
      });

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToImage({
    required int targetIndex,
    required int imageCount,
  }) {
    if (imageCount <= 1) return;

    final safeIndex = targetIndex.clamp(0, imageCount - 1);

    if (safeIndex == _currentIndex) return;

    setState(() {
      _currentIndex = safeIndex;
    });

    if (!_pageController.hasClients) return;

    _pageController.animateToPage(
      safeIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNextImage(int imageCount) {
    if (imageCount <= 1) return;

    final nextIndex = _currentIndex >= imageCount - 1 ? 0 : _currentIndex + 1;

    _goToImage(
      targetIndex: nextIndex,
      imageCount: imageCount,
    );
  }

  void _goToPreviousImage(int imageCount) {
    if (imageCount <= 1) return;

    final previousIndex = _currentIndex <= 0 ? imageCount - 1 : _currentIndex - 1;

    _goToImage(
      targetIndex: previousIndex,
      imageCount: imageCount,
    );
  }

  void _handleHorizontalSwipe({
    required DragEndDetails details,
    required int imageCount,
  }) {
    if (imageCount <= 1) return;

    final velocity = details.primaryVelocity ?? 0;

    if (velocity < -120) {
      _goToNextImage(imageCount);
      return;
    }

    if (velocity > 120) {
      _goToPreviousImage(imageCount);
    }
  }

  void _precacheCurrentAndNextImages(List<String> imageUrls) {
    if (imageUrls.isEmpty) return;

    final signature = '${imageUrls.join('|')}::$_currentIndex';

    if (_lastPrecacheSignature == signature) {
      return;
    }

    _lastPrecacheSignature = signature;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final indexesToPrecache = <int>{
        _currentIndex,
        _currentIndex + 1,
        _currentIndex - 1,
      };

      for (final index in indexesToPrecache) {
        if (index < 0 || index >= imageUrls.length) {
          continue;
        }

        precacheImage(
          CachedNetworkImageProvider(imageUrls[index]),
          context,
        );
      }

      final thumbnailUrl = _validThumbnailUrl;

      if (thumbnailUrl != null) {
        precacheImage(
          CachedNetworkImageProvider(thumbnailUrl),
          context,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = _validImageUrls;

    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    _precacheCurrentAndNextImages(imageUrls);

    final image = Container(
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
          PageView.builder(
            key: ValueKey(imageUrls.join(',')),
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _CachedFeedImage(
                imageUrl: imageUrls[index],
                placeholderImageUrl: index == 0 ? _validThumbnailUrl : null,
              );
            },
          ),
          if (imageUrls.length > 1)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  _handleHorizontalSwipe(
                    details: details,
                    imageCount: imageUrls.length,
                  );
                },
                onTapUp: (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  final width = box?.size.width ?? 0;

                  if (width <= 0) return;

                  final dx = details.localPosition.dx;

                  if (dx > width * 0.74) {
                    _goToNextImage(imageUrls.length);
                    return;
                  }

                  if (dx < width * 0.26) {
                    _goToPreviousImage(imageUrls.length);
                  }
                },
              ),
            ),
          if (imageUrls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: widget.indicatorBottom,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (index) {
                  final selected = _currentIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: selected ? 7 : 5,
                    height: selected ? 7 : 5,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withAlpha(107),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );

    if (widget.height != null) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: image,
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: image,
    );
  }
}

class _CachedFeedImage extends StatelessWidget {
  final String imageUrl;
  final String? placeholderImageUrl;

  const _CachedFeedImage({
    required this.imageUrl,
    required this.placeholderImageUrl,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        final rawCacheSize = constraints.maxWidth * devicePixelRatio;

        // 피드 상세 이미지는 그리드보다 크게 보이므로 720~1440px 정도로 제한합니다.
        // 원본 3~8MB 이미지를 그대로 디코딩하지 않게 해서 첫 표시와 재방문 속도를 개선합니다.
        final cacheSize = rawCacheSize.isFinite && rawCacheSize > 0
            ? rawCacheSize.round().clamp(720, 1440).toInt()
            : 1080;

        final thumbnailUrl = placeholderImageUrl?.trim();
        final hasThumbnailPlaceholder =
            _isValidNetworkImageUrl(thumbnailUrl) && thumbnailUrl != imageUrl;

        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          memCacheWidth: cacheSize,
          memCacheHeight: cacheSize,
          maxWidthDiskCache: cacheSize,
          maxHeightDiskCache: cacheSize,
          fadeInDuration: const Duration(milliseconds: 120),
          fadeOutDuration: const Duration(milliseconds: 60),
          useOldImageOnUrlChange: true,
          imageBuilder: (context, imageProvider) {
            return DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            );
          },
          placeholder: (context, url) {
            if (hasThumbnailPlaceholder) {
              return _ThumbnailPlaceholder(
                thumbnailUrl: thumbnailUrl!,
              );
            }

            return const _FeedImageLoadingPlaceholder();
          },
          errorWidget: (context, url, error) {
            debugPrint('Feed image load failed: $error');
            debugPrint('Feed image url: $url');

            return const _FeedImageErrorPlaceholder();
          },
        );
      },
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  final String thumbnailUrl;

  const _ThumbnailPlaceholder({
    required this.thumbnailUrl,
  });

  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: thumbnailUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          memCacheWidth: 420,
          memCacheHeight: 420,
          maxWidthDiskCache: 420,
          maxHeightDiskCache: 420,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          imageBuilder: (context, imageProvider) {
            return DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                ),
              ),
            );
          },
          placeholder: (context, url) {
            return const _FeedImageLoadingPlaceholder();
          },
          errorWidget: (context, url, error) {
            return const _FeedImageLoadingPlaceholder();
          },
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(22),
            ),
          ),
        ),
        const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: _accent,
              strokeWidth: 2,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedImageLoadingPlaceholder extends StatelessWidget {
  const _FeedImageLoadingPlaceholder();

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: _surface,
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: _accent,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _FeedImageErrorPlaceholder extends StatelessWidget {
  const _FeedImageErrorPlaceholder();

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: _surface,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: _secondaryText,
          size: 42,
        ),
      ),
    );
  }
}

class _NoImageWorkoutBanner extends StatelessWidget {
  final double height;
  final double borderRadius;

  const _NoImageWorkoutBanner({
    this.height = 190,
    this.borderRadius = 18,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_run_rounded,
            color: _accent,
            size: 38,
          ),
          SizedBox(height: 11),
          Text(
            '운동 기록',
            style: TextStyle(
              color: _primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '사진 없이 업로드된 운동입니다.',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
