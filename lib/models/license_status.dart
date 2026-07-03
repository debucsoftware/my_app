class LicenseStatus {
  const LicenseStatus({
    required this.enabled,
    this.docExists = false,
    this.rawAktif,
    this.source,
    this.error,
    this.path = 'app_config/license',
  });

  final bool enabled;
  final bool docExists;
  final String? rawAktif;
  final String? source;
  final String? error;
  final String path;

  String get debugLog {
    final lines = <String>[
      'Yol: $path',
      'Belge var: $docExists',
      'aktif ham deger: ${rawAktif ?? '(yok)'}',
      'Kaynak: ${source ?? '-'}',
      'Sonuc: ${enabled ? 'ACIK' : 'KILITLI'}',
      if (error != null) 'Hata: $error',
    ];
    return lines.join('\n');
  }
}
