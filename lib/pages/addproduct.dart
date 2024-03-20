import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  Future<void> _saveProduct() async {
    String url = 'https://642021154.pungpingcoding.online/api/product';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token') ??
        ''; // Replace 'YOUR_TOKEN_HERE' with your actual token

    Map<String, dynamic> data = {
      'pd_name': _nameController.text,
      'pd_type': int.parse(_typeController.text),
      'pd_price': double.parse(_priceController.text),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.of(context).pop();

        // Clear input fields after successful addition
        _nameController.clear();
        _priceController.clear();
      } else {
        // Failure
        // Handle failure here
      }
    } catch (error) {
      // Handle error here
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Product Type'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProduct,
              child: Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddProduct(),
  ));
}
