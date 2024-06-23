import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mydemo/models/price.dart';
import 'package:mydemo/services/supabase_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Price>> _prices;
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageUrl;
  bool _uploadingImage = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _prices = _supabaseService.fetchPrices();
  }

  Future<void> _pickImage() async {
    setState(() {
      _uploadingImage = true;
      _uploadError = null;
    });

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      try {
        final imageUrl = await _supabaseService.uploadImage(file);
        setState(() {
          _uploadedImageUrl = imageUrl;
          _uploadingImage = false;
        });
        print('Uploaded image URL: $_uploadedImageUrl'); // Debug print
      } catch (e) {
        setState(() {
          _uploadingImage = false;
          _uploadError = 'Error uploading image: $e';
        });
        print('Error uploading image: $e');
      }
    } else {
      setState(() {
        _uploadingImage = false;
        _uploadError = 'No image selected.';
      });
    }
  }

  Future<void> _addPrice() async {
    try {
      await _supabaseService.addPrice(
        _contentController.text,
      );
      setState(() {
        _prices = _supabaseService.fetchPrices();
        _contentController.clear();
        _uploadedImageUrl = null;
      });
    } catch (e) {
      setState(() {
        _uploadError = 'Error adding price: $e';
      });
      print('Error adding price: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Enter Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0), // Add space between widgets
            ElevatedButton(
              onPressed: _addPrice,
              child: const Text('Add Price'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16.0),
            if (_uploadingImage)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(),
              ),
            if (_uploadError != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _uploadError!,
                  style: const TextStyle(color: Colors.yellow),
                ),
              ),
            Expanded(
              child: FutureBuilder<List<Price>>(
                future: _prices,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No prices found.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final priceItem = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(priceItem.content),
                            subtitle: priceItem.imageUrl != null
                                ? Image.network(
                                    priceItem.imageUrl!,
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_forever_rounded),
                              onPressed: () async {
                                await _supabaseService
                                    .deletePrice(priceItem.id);
                                setState(() {
                                  _prices = _supabaseService.fetchPrices();
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
