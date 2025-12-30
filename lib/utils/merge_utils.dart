// lib/utils/merge_utils.dart

/// Interface to ensure objects have an ID for merging
abstract class Identifiable {
  String get id;
}

class MergeUtils {
  static List<T> mergeLists<T extends Identifiable>({
    required List<T> current,
    required List<T> incoming,
    bool prependNew = true,
  }) {
    final Map<String, T> currentMap = {for (var item in current) item.id: item};
    final Set<String> incomingIds = incoming.map((e) => e.id).toSet();

    final List<T> result = [];

    // 1. Process Incoming (Updates & New Items)
    for (final newItem in incoming) {
      final existingItem = currentMap[newItem.id];

      if (existingItem != null) {
        // UPDATE: Replace existing item with new server data
        result.add(newItem);
      } else {
        // INSERT: New item
        result.add(newItem);
      }
    }

    // 2. Keep existing items that were NOT in the incoming batch
    for (final existing in current) {
      if (!incomingIds.contains(existing.id)) {
        result.add(existing);
      }
    }

    return result;
  }
}
