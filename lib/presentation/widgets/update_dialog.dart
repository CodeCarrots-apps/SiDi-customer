import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sidi/constant/constants.dart';

class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    super.key,
    required this.storeUrl,
    required this.forceUpdate,
    this.whatsNew,
    this.latestVersion,
  });

  final String storeUrl;
  final bool forceUpdate;
  final String? whatsNew;
  final String? latestVersion;

  Future<void> _openStore(BuildContext context) async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (forceUpdate) {
      // Keep dialog open; user must update
    } else {
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !forceUpdate,
      child: AlertDialog(
        backgroundColor: kIvoryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: kPrimaryColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.system_update_rounded,
                color: kAccentGold,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Update Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kEspressoColor,
              ),
            ),
            if (latestVersion != null) ...[
              const SizedBox(height: 4),
              Text(
                'v$latestVersion',
                style: TextStyle(
                  fontSize: 13,
                  color: kAccentGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              whatsNew ?? 'A new version of SiDi is available. Please update to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: kMutedColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => _openStore(context),
                style: FilledButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: kEspressoColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                child: const Text('Update Now'),
              ),
            ),
            if (!forceUpdate) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: kMutedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Maybe Later'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
