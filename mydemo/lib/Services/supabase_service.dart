import 'dart:io';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mydemo/models/price.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Price>> fetchPrices() async {
    final response = await _client.from('price').select().execute();

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Price.fromJson(json)).toList();
  }

  Future<void> addPrice(String content, File? imageFile) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      final response = await _client
          .from('price')
          .insert({'content': content, 'imageUrl': imageUrl}).execute();

      if (response.error != null) {
        throw Exception(response.error!.message);
      }
    } catch (e) {
      print('Error adding price: $e');
      rethrow;
    }
  }

  Future<void> deletePrice(String id) async {
    final response =
        await _client.from('price').delete().eq('id', id).execute();

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  Future<String> uploadImage(File file) async {
    final fileName = basename(file.path);
    final response =
        await _client.storage.from('images').upload(fileName, file);

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    return getPublicUrl(fileName);
  }

  Future<String> getPublicUrl(String fileName) async {
    final urlResponse =
        await _client.storage.from('images').getPublicUrl(fileName);

    if (urlResponse.error != null) {
      throw Exception(urlResponse.error!.message);
    }

    return urlResponse.data!;
  }
}
