import 'dart:core';

import 'dart:io';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mydemo/models/price.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService() : _client = Supabase.instance.client;

  Future<List<Price>> fetchPrices() async {
    try {
      final response = await _client.from('price').select();

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

      print('Price successfully added: $content, Image URL: $imageUrl');
    } catch (e) {
      print('Error adding price: $e');
      rethrow;
    }
  }

  Future<void> deletePrice(String id) async {}

  Future<String> uploadImage(File file, String fileName) async {
    final publicUrlResponse =
        _client.storage.from('images').getPublicUrl(fileName);

    return publicUrlResponse;
  }
}
