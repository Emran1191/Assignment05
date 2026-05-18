import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'db_helper.dart';
import 'login_page.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      notes = await DbHelper.instance.getNotes(widget.user.id);
    } catch (error) {
      notes = [];
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load notes: $error')));
      }
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showEditDialog([Note? note]) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    final isNew = note == null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isNew ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter title and content.'),
                    ),
                  );
                  return;
                }

                final noteToSave = Note(
                  id: note?.id,
                  userId: widget.user.id,
                  title: title,
                  content: content,
                  createdAt: DateTime.now().toIso8601String(),
                );

                try {
                  if (isNew) {
                    await DbHelper.instance.createNote(noteToSave);
                  } else {
                    await DbHelper.instance.updateNote(noteToSave);
                  }

                  if (!mounted) return;
                  navigator.pop();
                  await _loadNotes();
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Note save failed: $error')),
                  );
                }
              },
              child: Text(isNew ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote(int noteId) async {
    try {
      await DbHelper.instance.deleteNote(noteId);
      if (!mounted) return;
      await _loadNotes();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $error')));
    }
  }

  Future<void> _deleteAccount() async {
    setState(() {
      isLoading = true;
    });

    final supabase = Supabase.instance.client;

    await DbHelper.instance.deleteNotesForUser(widget.user.id);
    await supabase.auth.signOut();

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'This will remove all your notes and sign you out. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final supabase = Supabase.instance.client;
              await supabase.auth.signOut();
              if (!mounted) return;
              navigator.pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
          PopupMenuButton<String>(
            color: Colors.grey[850],
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDeleteAccount();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete account',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${widget.user.email}',
              style: const TextStyle(fontSize: 24, color: Colors.cyan),
            ),
            const SizedBox(height: 4),
            const Text(
              'Create, edit and delete your notes below.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notes.isEmpty
                  ? const Center(
                      child: Text(
                        'No notes yet. Tap + to add one.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              note.title,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.cyan,
                                  ),
                                  onPressed: () => _showEditDialog(note),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _deleteNote(note.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
