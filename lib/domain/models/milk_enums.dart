enum MilkStorageMode { frozen, refrigerated }

enum MilkStatus {
  frozenInStock,
  refrigeratedInStock,
  thawing,
  checkedOut,
  expired,
  discarded,
}

enum PrintStatus { notPrinted, printing, printed, failed, needsUpdate }

enum MilkAction { startThawing, checkOut, markExpired, discard, undoCheckOut }

enum MilkStatusEventType {
  created,
  thawingStarted,
  checkedOut,
  checkOutUndone,
  expired,
  discarded,
}

enum ExpiryRisk {
  none,
  refrigerated,
  thawing,
  bestUseSoon,
  bestUsePassed,
  finalExpirySoon,
  expired,
}

extension MilkStatusActivity on MilkStatus {
  bool get isActive => switch (this) {
    MilkStatus.frozenInStock ||
    MilkStatus.refrigeratedInStock ||
    MilkStatus.thawing => true,
    _ => false,
  };
}
