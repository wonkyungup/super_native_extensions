import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_native_extensions/raw_clipboard.dart' as raw;

import 'model.dart';

export 'package:super_native_extensions/raw_clipboard.dart'
    show
        VirtualFolderEntry,
        VirtualFolderListProvider,
        VirtualFolderFileProvider;

/// Represent single item being dragged in a [DragSession].
class DragItem extends DataWriterItem {
  DragItem({
    super.suggestedName,
    this.localData,
  });

  @override
  bool get virtualFileSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Whether [addVirtualFolder] is supported on this platform.
  bool get virtualFolderSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// Adds a virtual folder (named by [suggestedName]) to this item. The
  /// receiver gets the whole tree: [listProvider] lists it (called right after
  /// the drag starts; the drag does not wait for it) and [fileProvider]
  /// produces each file when the receiver asks for it.
  ///
  /// Windows and macOS (see [virtualFolderSupported]). On Windows entries
  /// whose `folder\path` exceeds 259 UTF-16 units are left out by the
  /// platform. On macOS the folder is a file promise: Finder creates it and
  /// the files are written into it one after another after the drop.
  void addVirtualFolder({
    required FileFormat format,
    required raw.VirtualFolderListProvider listProvider,
    required raw.VirtualFolderFileProvider fileProvider,
    VirtualFileStorage? storageSuggestion,
  }) {
    assert(virtualFolderSupported);
    add(EncodedData([
      raw.DataRepresentation.virtualFolder(
        format: format.providerFormat,
        listProvider: listProvider,
        fileProvider: fileProvider,
        storageSuggestion: storageSuggestion,
      )
    ]));
  }

  /// Data associated with this drag item that can be only read when dropping
  /// within same application. The data must be serializable with
  /// [StandardMessageCodec]. It is possible to read [localData] from
  /// one isolate in another isolate.
  final Object? localData;
}

/// Single item of [DragConfiguration] consisting of drag item and corresponding
/// image.
class DragConfigurationItem {
  DragConfigurationItem({
    required this.item,
    required this.image,
    this.liftImage,
  });

  final DragItem item;
  final TargetedWidgetSnapshot image;
  final TargetedWidgetSnapshot? liftImage;
}

/// Additional options for drag session.
class DragOptions {
  const DragOptions({
    this.animatesToStartingPositionOnCancelOrFail = true,
    this.prefersFullSizePreviews = true,
  });

  /// macOS specific
  final bool animatesToStartingPositionOnCancelOrFail;

  /// iOS specific
  final bool prefersFullSizePreviews;
}

/// Initial configuration of a drag session.
class DragConfiguration {
  DragConfiguration({
    required this.items,
    required this.allowedOperations,
    this.options = const DragOptions(),
  });

  /// List of items in this session.
  final List<DragConfigurationItem> items;

  /// Allowed drop operation for this session.
  final List<DropOperation> allowedOperations;

  /// Additional platform specific options.
  final DragOptions options;
}
