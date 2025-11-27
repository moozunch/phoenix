import 'package:flutter/material.dart';
import 'package:phoenix/services/supabase_journal_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhotoArchivePage extends StatefulWidget {
  const PhotoArchivePage({super.key});

  @override
  State<PhotoArchivePage> createState() => _PhotoArchivePageState();
}

class _PhotoArchivePageState extends State<PhotoArchivePage> {
  List<String> photoUrls = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final journals = await SupabaseJournalService().fetchJournals(user.uid);
      photoUrls = journals
        .where((j) => j['photo_url'] != null && (j['photo_url'] as String).isNotEmpty)
        .map<String>((j) => j['photo_url'] as String)
        .toList();
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Center(
                child: Container(
                  width: 38,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: const [
                    Text('Archived', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : photoUrls.isEmpty
                    ? const Center(child: Text('No photos uploaded yet.'))
                    : GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: photoUrls.length,
                        itemBuilder: (context, idx) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              photoUrls[idx],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
