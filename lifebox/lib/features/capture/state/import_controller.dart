import 'dart:collection';
import 'package:flutter/material.dart'; 
import 'package:photo_manager/photo_manager.dart';
import 'package:lifebox/l10n/app_localizations.dart';

enum ImportPhotoType { all, screenshots, photos }

extension ImportPhotoTypeX on ImportPhotoType {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      ImportPhotoType.all => l10n.importTypeAll,
      ImportPhotoType.screenshots => l10n.importTypeScreenshots,
      ImportPhotoType.photos => l10n.importTypePhotos,
    };
  }
}

class ImportController extends ChangeNotifier {
  // ---- UI State ----
  bool permissionGranted = false;
  bool loading = false;

  ImportPhotoType type = ImportPhotoType.all;
  DateTimeRange? range;

  // ---- Albums ----
  AssetPathEntity? allPhotosPath;
  AssetPathEntity? screenshotsPath;

  // ---- Paging ----
  final List<AssetEntity> assets = [];
  int _page = 0;
  final int pageSize = 120;
  bool hasMore = true;

  // ---- Selection ----
  final Set<String> selectedAssetIds = <String>{};

  // ---- For excluding screenshots when type=photos ----
  final Set<String> _screenshotAssetIds = <String>{};

  Future<void> init() async {
    loading = true;
    notifyListeners();

    final ps = await PhotoManager.requestPermissionExtend();
    permissionGranted = ps.isAuth || ps.isLimited;

    if (!permissionGranted) {
      loading = false;
      notifyListeners();
      return;
    }

    await _loadPaths();
    await _preloadScreenshotIds(); // only for "photos" mode
    await reloadAssets();

    loading = false;
    notifyListeners();
  }

  FilterOptionGroup _buildFilter() {
    final group = FilterOptionGroup(
      orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
    );

    if (range != null) {
      group.createTimeCond = DateTimeCond(min: range!.start, max: range!.end);
    }
    return group;
  }

  Future<void> _loadPaths() async {
    final filter = _buildFilter();

    // "All"
    final allList = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filter,
      hasAll: true,
    );

    allPhotosPath = _firstWhereOrNull(allList, (p) => p.isAll) ?? (allList.isNotEmpty ? allList.first : null);

    // Search screenshots album by name keywords
    final allPaths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filter,
      hasAll: false,
    );

    screenshotsPath = _findScreenshotsAlbum(allPaths);
  }

  AssetPathEntity? _findScreenshotsAlbum(List<AssetPathEntity> paths) {
    bool match(String? name) {
      if (name == null) return false;
      final t = name.toLowerCase();
      const keys = [
        'screenshots',
        'screenshot',
        'スクリーンショット',
        '屏幕快照',
        '截图',
        '截圖',
      ];
      return keys.any((k) => t.contains(k.toLowerCase()));
    }

    for (final p in paths) {
      if (match(p.name)) return p;
    }
    return null;
  }

  Future<void> _preloadScreenshotIds() async {
    _screenshotAssetIds.clear();
    if (screenshotsPath == null) return;

    int page = 0;
    const int size = 500;
    while (true) {
      final list = await screenshotsPath!.getAssetListPaged(page: page, size: size);
      if (list.isEmpty) break;
      for (final a in list) {
        _screenshotAssetIds.add(a.id);
      }
      if (list.length < size) break;
      page++;
    }
  }

  Future<void> setType(ImportPhotoType t) async {
    type = t;
    await reloadAssets();
  }

  Future<void> setRange(DateTimeRange? r) async {
    range = r;
    // range 变化后，需要重新加载 path/filter
    await _loadPaths();
    await reloadAssets();
  }

  Future<void> reloadAssets() async {
    assets.clear();
    _page = 0;
    hasMore = true;
    notifyListeners();
    await loadMore();
  }

  Future<void> loadMore() async {
    if (!permissionGranted || loading || !hasMore) return;

    loading = true;
    notifyListeners();

    try {
      final filter = _buildFilter();

      if (type == ImportPhotoType.screenshots) {
        final path = screenshotsPath ?? allPhotosPath;
        if (path == null) {
          hasMore = false;
          return;
        }
        final pageList = await path.getAssetListPaged(page: _page, size: pageSize);
        assets.addAll(pageList);
        _page++;
        hasMore = pageList.length == pageSize;
      } else {
        // all/photos: always page from "All" with filter
        final allWithFilter = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          filterOption: filter,
          hasAll: true,
        );

        final allPath = _firstWhereOrNull(allWithFilter, (p) => p.isAll) ?? (allWithFilter.isNotEmpty ? allWithFilter.first : null);

        if (allPath == null) {
          hasMore = false;
          return;
        }

        final pageList = await allPath.getAssetListPaged(page: _page, size: pageSize);

        if (type == ImportPhotoType.photos && _screenshotAssetIds.isNotEmpty) {
          // exclude screenshot assets
          final filtered = pageList.where((a) => !_screenshotAssetIds.contains(a.id)).toList();
          assets.addAll(filtered);
        } else {
          assets.addAll(pageList);
        }

        _page++;
        hasMore = pageList.length == pageSize;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void toggleSelect(String assetId) {
    if (selectedAssetIds.contains(assetId)) {
      selectedAssetIds.remove(assetId);
    } else {
      selectedAssetIds.add(assetId);
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedAssetIds.clear();
    notifyListeners();
  }

  void selectAllVisible() {
    for (final a in assets) {
      selectedAssetIds.add(a.id);
    }
    notifyListeners();
  }

  bool isSelected(String assetId) => selectedAssetIds.contains(assetId);

  // 为了方便 ImportPage 显示
  String? get screenshotsAlbumName => screenshotsPath?.name;

  // 可选：让 ImportPage 使用一个只读的截图ID集合（调试用）
  UnmodifiableSetView<String> get screenshotAssetIds => UnmodifiableSetView(_screenshotAssetIds);
}

T? _firstWhereOrNull<T>(List<T> list, bool Function(T) test) {
  for (final x in list) {
    if (test(x)) return x;
  }
  return null;
}