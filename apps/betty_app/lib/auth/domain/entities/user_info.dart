class UserInfo {
  final bool authenticated;
  final DateTime? tokenIssuedAt;
  final DateTime? tokenExpiresAt;

  const UserInfo({
    required this.authenticated,
    this.tokenIssuedAt,
    this.tokenExpiresAt,
  });

  bool get isTokenValid {
    if (tokenExpiresAt == null) return authenticated;
    return authenticated && DateTime.now().isBefore(tokenExpiresAt!);
  }

  Duration? get timeUntilExpiry {
    if (tokenExpiresAt == null) return null;
    final now = DateTime.now();
    return tokenExpiresAt!.isAfter(now)
        ? tokenExpiresAt!.difference(now)
        : null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo &&
        other.authenticated == authenticated &&
        other.tokenIssuedAt == tokenIssuedAt &&
        other.tokenExpiresAt == tokenExpiresAt;
  }

  @override
  int get hashCode =>
      authenticated.hashCode ^ tokenIssuedAt.hashCode ^ tokenExpiresAt.hashCode;

  @override
  String toString() =>
      'UserInfo(authenticated: $authenticated, tokenIssuedAt: $tokenIssuedAt, tokenExpiresAt: $tokenExpiresAt)';
}
