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
