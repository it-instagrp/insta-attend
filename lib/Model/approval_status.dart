enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

extension ApprovalStatusExtension on ApprovalStatus {
  String get value {
    switch (this) {
      case ApprovalStatus.pending:
        return 'PENDING';
      case ApprovalStatus.approved:
        return 'APPROVED';
      case ApprovalStatus.rejected:
        return 'REJECTED';
    }
  }

  bool get isPending => this == ApprovalStatus.pending;
  bool get isApproved => this == ApprovalStatus.approved;
  bool get isRejected => this == ApprovalStatus.rejected;
}

// Static method outside of extension
ApprovalStatus approvalStatusFromString(String status) {
  switch (status.toUpperCase()) {
    case 'APPROVED':
      return ApprovalStatus.approved;
    case 'REJECTED':
      return ApprovalStatus.rejected;
    case 'PENDING':
    default:
      return ApprovalStatus.pending;
  }
}