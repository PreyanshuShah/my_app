import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mydemo/blocs/internet_bloc/internet_bloc.dart';
import 'package:mydemo/blocs/internet_bloc/internet_state.dart';
import 'package:mydemo/models/price.dart';
import 'package:mydemo/services/supabase_service.dart';
import 'package:supabase/supabase.dart';
import 'package:path/path.dart' as path;

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
    required this.client,
  }) : super(key: key);

  final String title;
  final SupabaseClient client;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Price>> _prices;
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<PriceEntry> _priceEntries = [];
  bool _uploadingImage = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    try {
      final prices = await _supabaseService.fetchPrices();
      setState(() {
        _prices = Future.value(prices);
      });
    } catch (e) {
      print('Error fetching prices: $e');
      setState(() {
        _prices = Future.error('Failed to fetch prices.');
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _uploadingImage = true;
      });
      try {
        final fileName =
            '${path.basename(pickedFile.path)}_${DateTime.now().millisecondsSinceEpoch}';
        final imageUrl =
            await _supabaseService.uploadImage(File(pickedFile.path), fileName);
        _addPriceEntry(_contentController.text, File(pickedFile.path));
        setState(() {
          _uploadingImage = false;
        });
        print('Uploaded image URL: $imageUrl');
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

  void _addPriceEntry(String price, File image) {
    _priceEntries.add(PriceEntry(price: price, image: image));
    _contentController.clear(); // Clear text field after adding price
    setState(() {});
    print('Price entry added: $price');
  }

  Future<void> _submitEntries() async {
    try {
      for (var entry in _priceEntries) {
        await _supabaseService.addPrice(entry.price, entry.image);
        print('Price submitted: ${entry.price}');
      }
      _priceEntries.clear(); // Clear entries after successful submission
      setState(() {});
    } catch (e) {
      setState(() {
        _uploadError = 'Error adding price: $e';
      });
      print('Error adding price: $e');
    }
  }

  void _viewItems() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('View Items'),
            ),
            body: FutureBuilder<List<Price>>(
              future: _prices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No prices found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final priceItem = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(priceItem.content),
                          leading: priceItem.imageUrl != null
                              ? Image.network(
                                  priceItem.imageUrl!,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                              : null,
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await _supabaseService.deletePrice(priceItem.id);
                              _fetchPrices(); // Refresh prices after deletion
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetBloc, InternetState>(
      listener: (context, state) {
        if (state is InternetGainedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Internet is connected")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            ElevatedButton(
              onPressed: _viewItems,
              child: Text('View Items'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Price',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              if (_uploadingImage)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              if (_uploadError != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _uploadError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: _submitEntries,
                child: const Text('Add Price'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _priceEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _priceEntries[index];
                    return ListTile(
                      title: Text(entry.price),
                      leading: entry.image != null
                          ? Image.file(
                              entry.image!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PriceEntry {
  final String price;
  final File? image;

  PriceEntry({required this.price, required this.image});
}
