import 'dart:io';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mydemo/models/price.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService() : _client = Supabase.instance.client;

  Future<List<Price>> fetchPrices() async {
    try {
      final response = await _client.from('price').select().execute();

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Price.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching prices: $e');
      throw Exception('Error fetching prices: $e');
    }
  }

  Future<void> addPrice(String content, File? imageFile) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        final fileName =
            '${basename(imageFile.path)}_${DateTime.now().millisecondsSinceEpoch}';
        imageUrl = await uploadImage(imageFile, fileName);
      }

      final response = await _client
          .from('price')
          .insert({'content': content, 'imageUrl': imageUrl}).execute();

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      print('Price successfully added: $content, Image URL: $imageUrl');
    } catch (e) {
      print('Error adding price: $e');
      rethrow;
    }
  }

  Future<void> deletePrice(String id) async {
    try {
      final response =
          await _client.from('price').delete().eq('id', id).execute();

      if (response.error != null) {
        throw Exception(response.error!.message);
      }
    } catch (e) {
      print('Error deleting price: $e');
      rethrow;
    }
  }

  Future<String> uploadImage(File file, String fileName) async {
    try {
      final storageResponse =
          await _client.storage.from('images').upload(fileName, file);

      if (storageResponse.error != null) {
        throw Exception(storageResponse.error!.message);
      }

      final publicUrlResponse =
          _client.storage.from('images').getPublicUrl(fileName);
      if (publicUrlResponse.error != null) {
        throw Exception(publicUrlResponse.error!.message);
      }

      return publicUrlResponse.data!;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }
}
