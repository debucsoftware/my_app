import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/services/locale_service.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeService = context.watch<LocaleService>();

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: (locale) => localeService.setLocale(locale),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('tr'),
          child: Text(l10n.turkish),
        ),
        PopupMenuItem(
          value: const Locale('nl'),
          child: Text(l10n.dutch),
        ),
      ],
    );
  }
}
