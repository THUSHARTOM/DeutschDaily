import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';

/// A floating popup overlay showing the translation for a tapped German word.
class WordPopup extends StatelessWidget {
  final DictionaryEntry entry;
  final VoidCallback onClose;

  const WordPopup({
    super.key,
    required this.entry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        entry.lemma,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (entry.pos.toLowerCase() != 'unknown') ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.pos.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Divider(height: 24),
                Text(
                  entry.english,
                  style: const TextStyle(fontSize: 18),
                ),
                if (entry.example != null && entry.example!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.example!,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
