import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/logger.dart';

class SupabaseClientWrapper {
  SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      AppLogger.warning('Supabase not initialized', 'SupabaseClient');
      return null;
    }
  }

  bool get isInitialized => client != null;

  Future<List<Map<String, dynamic>>> fetch(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    if (!isInitialized) return [];

    var query = client!.from(table).select(select ?? '*');

    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    final response = await query
        .order(orderBy ?? 'created_at', ascending: ascending)
        .limit(limit ?? 100);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchOne(
    String table,
    String id, {
    String? select,
  }) async {
    if (!isInitialized) return null;

    final response = await client!
        .from(table)
        .select(select ?? '*')
        .eq('id', id)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    if (!isInitialized) return null;

    final response = await client!.from(table).insert(data).select().single();

    return response;
  }

  Future<Map<String, dynamic>?> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    if (!isInitialized) return null;

    final response =
        await client!.from(table).update(data).eq('id', id).select().single();

    return response;
  }

  Future<void> delete(String table, String id) async {
    if (!isInitialized) return;

    await client!.from(table).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> upsert(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    if (!isInitialized) return [];

    final response = await client!.from(table).upsert(data).select();

    return List<Map<String, dynamic>>.from(response);
  }

  RealtimeChannel? subscribeToTable(
    String table,
    void Function(Map<String, dynamic>) onInsert,
    void Function(Map<String, dynamic>) onUpdate,
    void Function(Map<String, dynamic>) onDelete,
  ) {
    if (!isInitialized) return null;

    return client!
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }
}
