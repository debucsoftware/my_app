import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/license_status.dart';

class AppLockedScreen extends StatelessWidget {
  const AppLockedScreen({
    super.key,
    this.status,
    this.onRetry,
    this.checking = false,
  });

  final LicenseStatus? status;
  final VoidCallback? onRetry;
  final bool checking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 72,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.appLocked,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appLockedHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: checking ? null : onRetry,
                      icon: checking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(l10n.retryCheck),
                    ),
                  ],
                  if (status != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        status!.debugLog,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: status!.debugLog));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.logCopied)),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text(l10n.copyLog),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
