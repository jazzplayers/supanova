import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_rounded,
  bool isError = false,
}) {
  final Color accentColor =
      isError ? const Color(0xFFFF6B6B) : const Color(0xFF64D2C8);

  final Color backgroundColor =
      isError ? const Color(0xFF4A1E24) : const Color(0xFF12333A);

  final media = MediaQuery.maybeOf(context);
  final bottomSafeArea = media?.padding.bottom ?? 0;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          18 + bottomSafeArea,
        ),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 2),
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withAlpha(166),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withAlpha(46),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(115),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(46),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withAlpha(115),
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}