import '../../entities/portable_session/portable_session.dart';

/// A self-contained, relocatable transport bundle produced by `export` and
/// consumed by `import` (spec FR-007 / FR-008 / FR-010 / FR-011).
///
/// Hand-written (not `zfa`-generated) so the wire format stays stable and
/// independent of the generated entity stack (see research.md Decision 7).
/// Wraps exactly one [PortableSession].
class PortableSessionArtifact {
  /// Current schema version emitted by this package (spec FR-011).
  static const int version = 1;

  /// Schema version of the wrapped session. Unsupported versions are rejected
  /// on import.
  final int formatVersion;

  /// Epoch milliseconds when the artifact was exported.
  final int exportedAt;

  /// Integrity hash over the canonical [session] JSON (spec FR-010).
  final String checksum;

  /// The exactly one wrapped session.
  final PortableSession session;

  const PortableSessionArtifact({
    required this.formatVersion,
    required this.exportedAt,
    required this.checksum,
    required this.session,
  });

  PortableSessionArtifact copyWith({
    int? formatVersion,
    int? exportedAt,
    String? checksum,
    PortableSession? session,
  }) => PortableSessionArtifact(
    formatVersion: formatVersion ?? this.formatVersion,
    exportedAt: exportedAt ?? this.exportedAt,
    checksum: checksum ?? this.checksum,
    session: session ?? this.session,
  );

  factory PortableSessionArtifact.fromJson(Map<String, dynamic> json) =>
      PortableSessionArtifact(
        formatVersion: _asInt(json['formatVersion'], 'formatVersion'),
        exportedAt: _asInt(json['exportedAt'], 'exportedAt'),
        checksum: _asString(json['checksum'], 'checksum'),
        session: json['session'] is Map<String, dynamic>
            ? PortableSession.fromJson(json['session'] as Map<String, dynamic>)
            : throw const FormatException('artifact.session must be an object'),
      );

  static int _asInt(dynamic value, String field) {
    if (value is! num) {
      throw FormatException('artifact.$field must be an int');
    }
    return value.toInt();
  }

  static String _asString(dynamic value, String field) {
    if (value is! String) {
      throw FormatException('artifact.$field must be a String');
    }
    return value;
  }

  Map<String, dynamic> toJson() => {
    'formatVersion': formatVersion,
    'exportedAt': exportedAt,
    'checksum': checksum,
    'session': session.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortableSessionArtifact &&
          formatVersion == other.formatVersion &&
          exportedAt == other.exportedAt &&
          checksum == other.checksum &&
          session == other.session;

  @override
  int get hashCode => Object.hash(formatVersion, exportedAt, checksum, session);

  @override
  String toString() =>
      'PortableSessionArtifact(formatVersion: $formatVersion, '
      'exportedAt: $exportedAt, checksum: $checksum, session: $session)';
}
