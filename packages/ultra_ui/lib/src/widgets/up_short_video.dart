import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import 'up_icon.dart';
import 'up_tabs.dart';

/// Port of u-short-video / up-short-video.
class UPShortVideo extends StatefulWidget {
  const UPShortVideo({
    super.key,
    this.tabsList = const [
      {'name': '推荐'},
      {'name': '关注'},
      {'name': '朋友'},
      {'name': '本地'},
    ],
    this.videoList = const [],
    this.currentTab = 0,
    this.currentVideo = 0,
    this.videoBuilder,
    this.onTabChange,
    this.onUpdateCurrentTab,
    this.onUpdateCurrentVideo,
    this.onUpdateModelValue,
    this.onVideoChange,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onCollect,
    this.onVideoPlay,
    this.onVideoPause,
    this.onVideoEnded,
    this.onTimeUpdate,
    this.onProgressChange,
    this.onProgressChanging,
    this.onLoadedMetadata,
    this.menuSlot,
    this.searchSlot,
    this.actionsBuilder,
    this.tabbarSlot,
    this.customStyle,
  });

  final List tabsList;
  final List videoList;
  final int currentTab;
  final int currentVideo;

  /// Host-injectable real player. Receives item/index/playing state.
  final Widget Function(dynamic item, int index, bool playing)? videoBuilder;
  final ValueChanged<int>? onTabChange;
  final ValueChanged<int>? onUpdateCurrentTab;
  final ValueChanged<int>? onVideoChange;
  final ValueChanged<int>? onUpdateCurrentVideo;

  /// Source-compatible modelValue alias (maps to current video index).
  final ValueChanged<int>? onUpdateModelValue;
  final void Function(dynamic item, int index)? onLike;
  final void Function(dynamic item, int index)? onComment;
  final void Function(dynamic item, int index)? onShare;
  final void Function(dynamic item, int index)? onCollect;
  final void Function(int index)? onVideoPlay;
  final void Function(int index)? onVideoPause;
  final void Function(int index)? onVideoEnded;
  final void Function(int index, double progress)? onTimeUpdate;
  final void Function(int index, double progress)? onProgressChange;
  final void Function(int index, double progress)? onProgressChanging;
  final void Function(int index)? onLoadedMetadata;

  /// Source `menu` slot — leading header button, default a `grid` icon.
  final Widget? menuSlot;

  /// Source `search` slot — trailing header button, default a `search` icon.
  final Widget? searchSlot;

  /// Source `actions` slot, scoped `{item, index}` — replaces the whole
  /// right-hand action column (like / comment / share / collect).
  final Widget Function(BuildContext context, dynamic item, int index)?
      actionsBuilder;

  /// Source `tabbar` slot — bottom bar overlaying the player. The source default
  /// is a `u-tabbar`; this port renders nothing unless a slot is supplied,
  /// because a tabbar belongs to the host's navigation, not to the player.
  final Widget? tabbarSlot;

  final BoxDecoration? customStyle;
  @override
  State<UPShortVideo> createState() => UPShortVideoState();
}

class UPShortVideoState extends State<UPShortVideo> {
  late int tabIndex;
  late int videoIndex;
  late PageController pageController;
  final liked = <int>{};
  final collected = <int>{};
  bool playing = true;
  double progress = 0;
  double playbackRate = 1.0;

  /// Source data.
  double get progressValue => progress;
  bool showSpeedSheet = false;
  int currentSpeedVideoIndex = -1;

  @override
  void initState() {
    super.initState();
    tabIndex = widget.currentTab;
    videoIndex = widget.currentVideo;
    pageController = PageController(initialPage: videoIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (playing) widget.onVideoPlay?.call(videoIndex);
      widget.onLoadedMetadata?.call(videoIndex);
    });
  }

  @override
  void didUpdateWidget(covariant UPShortVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTab != widget.currentTab) tabIndex = widget.currentTab;
    if (oldWidget.currentVideo != widget.currentVideo &&
        pageController.hasClients) {
      videoIndex = widget.currentVideo;
      pageController.jumpToPage(videoIndex);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Map asMap(dynamic item, int i) {
    if (item is Map) return Map<dynamic, dynamic>.from(item);
    return {'title': '视频 $i'};
  }

  String titleOf(Map item, int i) =>
      '${item['title'] ?? item['desc'] ?? item['name'] ?? '视频 $i'}';
  String authorOf(Map item) => '${item['author'] ?? item['nickname'] ?? ''}';
  int likeCountOf(Map item, int i) {
    final base = int.tryParse('${item['likeCount'] ?? 0}') ?? 0;
    return liked.contains(i) ? base + 1 : base;
  }

  /// Source-compatible play API.
  void playVideo([int? index]) {
    final target = index ?? videoIndex;
    setState(() {
      if (index != null && index != videoIndex && pageController.hasClients) {
        videoIndex = index;
        pageController.jumpToPage(index);
      }
      playing = true;
    });
    widget.onVideoPlay?.call(target);
  }

  /// Source-compatible pause API.
  void pauseCurrentVideo() {
    setState(() => playing = false);
    widget.onVideoPause?.call(videoIndex);
  }

  void togglePlay() {
    if (playing) {
      pauseCurrentVideo();
    } else {
      playVideo();
    }
  }

  /// Source event aliases.
  void handleLike([int? index]) => likeAt(index ?? videoIndex);
  void handleComment([int? index]) {
    final i = index ?? videoIndex;
    final list = widget.videoList;
    final item = asMap(list.isEmpty ? {'title': '暂无视频'} : list[i], i);
    widget.onComment?.call(item, i);
  }

  void handleShare([int? index]) {
    final i = index ?? videoIndex;
    final list = widget.videoList;
    final item = asMap(list.isEmpty ? {'title': '暂无视频'} : list[i], i);
    widget.onShare?.call(item, i);
  }

  void handleCollect([int? index]) => collectAt(index ?? videoIndex);
  void handleTabChange(int index) => switchTab(index);
  void handleSwiperChange(int index) => switchVideo(index);
  void onProgressChanging(double v) => setProgress(v);
  void onProgressChangeAlias(double v) => setProgress(v);

  /// Source retained speed option list.
  List get speedOptions => const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  bool showingSpeedOptions = false;
  void showSpeedOptions([dynamic _]) {
    showingSpeedOptions = true;
    if (mounted) setState(() {});
  }

  void hideSpeedOptions([dynamic _]) {
    showingSpeedOptions = false;
    if (mounted) setState(() {});
  }

  void selectSpeed(double rate) {
    hideSpeedOptions();
    setPlaybackRate(rate);
  }

  /// Source event method aliases.
  void onVideoPlay([int? index]) => playVideo(index);
  void onVideoPause([int? index]) {
    if (index != null && index != videoIndex && pageController.hasClients) {
      videoIndex = index;
    }
    pauseCurrentVideo();
  }

  void onVideoEnded([int? index]) {
    if (index != null) videoIndex = index;
    endCurrent();
  }

  void onTimeUpdate([double? p, int? index]) {
    if (index != null) videoIndex = index;
    setProgress(p ?? progress);
  }

  void onProgressChange([double? p, int? index]) => onTimeUpdate(p, index);
  void onLoadedMetadata([int? index]) {
    final i = index ?? videoIndex;
    widget.onLoadedMetadata?.call(i);
  }

  void onVideoPlayAlias() => playVideo();
  void onVideoPauseAlias() => pauseCurrentVideo();

  void likeAt(int index) {
    final list = widget.videoList;
    final item = asMap(list.isEmpty ? {'title': '暂无视频'} : list[index], index);
    setState(() {
      if (liked.contains(index)) {
        liked.remove(index);
      } else {
        liked.add(index);
      }
    });
    widget.onLike?.call(item, index);
  }

  void collectAt(int index) {
    final list = widget.videoList;
    final item = asMap(list.isEmpty ? {'title': '暂无视频'} : list[index], index);
    setState(() {
      if (collected.contains(index)) {
        collected.remove(index);
      } else {
        collected.add(index);
      }
    });
    widget.onCollect?.call(item, index);
  }

  void setProgress(double value) {
    setState(() => progress = value.clamp(0, 1));
    widget.onTimeUpdate?.call(videoIndex, progress);
    widget.onProgressChange?.call(videoIndex, progress);
  }

  void setPlaybackRate(double rate) {
    setState(() => playbackRate = rate);
  }

  void endCurrent() {
    widget.onVideoEnded?.call(videoIndex);
  }

  void switchTab(int index) {
    setState(() => tabIndex = index);
    widget.onTabChange?.call(index);
    widget.onUpdateCurrentTab?.call(index);
  }

  void switchVideo(int index) {
    if (!pageController.hasClients) {
      setState(() {
        videoIndex = index;
        playing = true;
        progress = 0;
      });
      widget.onVideoChange?.call(index);
      widget.onUpdateCurrentVideo?.call(index);
      widget.onUpdateModelValue?.call(index);
      widget.onVideoPlay?.call(index);
      return;
    }
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final list = widget.videoList;
    Widget root = SizedBox(
      height: 480,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: list.isEmpty ? 1 : list.length,
            onPageChanged: (i) {
              setState(() {
                videoIndex = i;
                playing = true;
                progress = 0;
              });
              widget.onVideoChange?.call(i);
              widget.onUpdateCurrentVideo?.call(i);
              widget.onUpdateModelValue?.call(i);
              widget.onVideoPlay?.call(i);
              widget.onLoadedMetadata?.call(i);
            },
            itemBuilder: (context, i) {
              final item = asMap(list.isEmpty ? {'title': '暂无视频'} : list[i], i);
              final isLiked = liked.contains(i) || item['isLiked'] == true;
              final isCollected =
                  collected.contains(i) || item['isCollected'] == true;
              final active = i == videoIndex && playing;
              final rate =
                  double.tryParse('${item['playbackRate']}') ?? playbackRate;
              return GestureDetector(
                onTap: togglePlay,
                onDoubleTap: () => likeAt(i),
                child: Container(
                  color: const Color(0xFF111111),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: widget.videoBuilder != null
                            ? KeyedSubtree(
                                key: ValueKey('short-player-$i-$active'),
                                child: widget.videoBuilder!(item, i, active),
                              )
                            : Center(
                                child: Icon(
                                  playing
                                      ? Icons.play_circle_outline
                                      : Icons.pause_circle_outline,
                                  size: 72,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                      ),
                      if (rate != 1.0)
                        Positioned(
                          right: 16,
                          top: 64,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${rate}x',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 16,
                        right: 72,
                        bottom: 48,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (authorOf(item).isNotEmpty)
                              Text(
                                '@${authorOf(item)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              titleOf(item, i),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 80,
                        child: widget.actionsBuilder?.call(context, item, i) ??
                            Column(
                              children: [
                                action(
                                  isLiked ? 'thumb-up-fill' : 'thumb-up',
                                  '${likeCountOf(item, i)}',
                                  () => likeAt(i),
                                  key: ValueKey('short-like-$i'),
                                ),
                                const SizedBox(height: 16),
                                action(
                                  'chat',
                                  '${item['commentCount'] ?? '评'}',
                                  () => widget.onComment?.call(item, i),
                                ),
                                const SizedBox(height: 16),
                                action(
                                  isCollected ? 'star-fill' : 'star',
                                  '${item['collectCount'] ?? '藏'}',
                                  () => collectAt(i),
                                ),
                                const SizedBox(height: 16),
                                action(
                                  'share',
                                  '${item['shareCount'] ?? '享'}',
                                  () => widget.onShare?.call(item, i),
                                ),
                              ],
                            ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 18,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5,
                            ),
                          ),
                          child: Slider(
                            value: progress.clamp(0, 1),
                            onChanged: (v) {
                              setState(() => progress = v);
                              widget.onTimeUpdate?.call(i, v);
                              widget.onProgressChanging?.call(i, v);
                            },
                            onChangeEnd: (v) {
                              setState(() => progress = v);
                              widget.onProgressChange?.call(i, v);
                            },
                            activeColor: tokens.primary,
                            inactiveColor: Colors.white24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black26,
              // Source header is menu | tabs | search on one row. The icons are
              // slot defaults, so they render even without a slot.
              child: Row(
                children: [
                  widget.menuSlot ??
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: UPIcon(
                            name: 'grid',
                            size: 24,
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                      ),
                  Expanded(
                    child: UPTabs(
                      list: widget.tabsList,
                      current: tabIndex,
                      lineWidth: 20,
                      lineColor: '#ffffff',
                      activeStyle: const {'color': '#ffffff'},
                      inactiveStyle: const {'color': '#dddddd'},
                      onChange: (i) {
                        setState(() => tabIndex = i);
                        widget.onTabChange?.call(i);
                        widget.onUpdateCurrentTab?.call(i);
                      },
                    ),
                  ),
                  widget.searchSlot ??
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: UPIcon(
                            name: 'search',
                            size: 24,
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
          if (widget.tabbarSlot != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: widget.tabbarSlot!,
            ),
        ],
      ),
    );
    return root;
  }

  Widget action(String icon, String label, VoidCallback onTap, {Key? key}) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          UPIcon(name: icon, size: 28, color: const Color(0xFFEEEEEE)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
