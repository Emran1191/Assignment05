import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

class DbHelper {
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Note>> getNotes(String userId) async {
    final data = await _supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((row) => Note.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> createNote(Note note) async {
    await _supabase.from('notes').insert({
      'user_id': note.userId,
      'title': note.title,
      'content': note.content,
      'created_at': note.createdAt,
    });
  }

  Future<void> updateNote(Note note) async {
    if (note.id == null) return;

    await _supabase
        .from('notes')
        .update({
          'title': note.title,
          'content': note.content,
          'created_at': note.createdAt,
        })
        .eq('id', note.id!);
  }

  Future<void> deleteNote(int id) async {
    await _supabase.from('notes').delete().eq('id', id);
  }

  Future<void> deleteNotesForUser(String userId) async {
    await _supabase.from('notes').delete().eq('user_id', userId);
  }
}
