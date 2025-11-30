import 'package:flutter/material.dart';
import 'package:phoenix/services/supabase_journal_service.dart';
import 'package:phoenix/widgets/confirm_dialog.dart';

typedef OnEditCallback = void Function();
typedef OnDeletedCallback = void Function();

class JournalOptionsMenu extends StatelessWidget {
  final String journalId;
  final OnEditCallback? onEdit;
  final OnDeletedCallback? onDeleted;
  final bool showEdit;
  final bool showDelete;
  const JournalOptionsMenu({
    super.key,
    required this.journalId,
    this.onEdit,
    this.onDeleted,
    this.showEdit = true,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
      onPressed: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (ctx) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Journal',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 18),
                            if (showEdit)
                              _SheetButton(
                                text: 'Edit',
                                onTap: () => Navigator.of(ctx).pop('edit'),
                              ),
                            if (showDelete)
                              _SheetButton(
                                text: 'Delete',
                                textColor: Colors.red,
                                onTap: () => Navigator.of(ctx).pop('delete'),
                              ),
                            _SheetButton(
                              text: 'Cancel',
                              onTap: () => Navigator.of(ctx).pop('cancel'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
        if (!context.mounted) return;
        if (result == 'edit') {
          if (onEdit != null) onEdit!();
        } else if (result == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => ConfirmDialog(
              message: 'Do you want to delete the journal?',
              confirmText: 'Delete',
              cancelText: 'Cancel',
            ),
          );
          if (!context.mounted) return;
          if (confirm == true) {
            await SupabaseJournalService().deleteJournal(journalId);
            if (onDeleted != null) onDeleted!();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal deleted.')));
            }
          }
        }
      },
    );
  }

}

class _SheetButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final VoidCallback onTap;
  const _SheetButton({
    required this.text,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}