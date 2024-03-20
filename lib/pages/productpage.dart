import 'dart:convert';
import 'dart:io';

import 'package:fonend/pages/addproduct.dart';
import 'package:fonend/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final int id;
  final String productName;
  final int productType;
  final double price;

  Product({
    required this.id,
    required this.productName,
    required this.productType,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"] ?? 0,
      productName: json["product_name"] ?? '',
      productType: json["product_type"] ?? 0,
      price: (json["price"] ?? 0).toDouble(),
    );
  }
}

class productpages extends StatefulWidget {
  @override
  State<productpages> createState() => _productpagesState();
}

class _productpagesState extends State<productpages> {
  List<Product> products = [];
  String _token = '';

  int _userId = 0;
  String _name = '';

  // เมธอดสำหรับโหลดข้อมูลสินค้า
  Future<void> _loadProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    var url = Uri.parse("https://642021154.pungpingcoding.online/api/product");
    var response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token",
    });

    if (response.statusCode == 200) {
      _loadProducts();
      var jsonData = jsonDecode(response.body);

      setState(() {
        products = (jsonData['payload'] as List)
            .map<Product>((json) => Product.fromJson(json))
            .toList();
      });
    } else {
      print("Error: Failed to load products (${response.statusCode})");
    }
  }

  Future<void> _deleteProduct(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    var url =
        Uri.parse('https://642021154.pungpingcoding.online/api/product/$id');

    var response = await http.delete(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "Bearer $token"
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        products!.removeWhere((product) => product.id == id);
      });
    }
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    // Perform logout API call
    setState(() {
      _token = token!;
      _userId = prefs.getInt('userId') ?? 0;
      _name = prefs.getString('userName') ?? '';
    });
    var logoutUrl =
        Uri.parse('https://642021154.pungpingcoding.online/api/logout');
    var logoutResponse = await http.post(
      logoutUrl,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "Bearer $_token"
      },
    );

    if (logoutResponse.statusCode == 200) {
      prefs.remove("token");

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LoginPage(), // Replace LoginPage() with your actual login page
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts(); // เรียกเมธอดโหลดข้อมูลทันทีเมื่อหน้าเริ่มโหลด
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product List"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: products == null || products!.isEmpty
                  ? const CircularProgressIndicator()
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Column(
                              children: [
                                Text(products[index].productName),
                              ],
                            ),
                            subtitle: Column(
                              children: [
                                Text("ประเภท: ${products[index].productType}"),
                                Text(
                                  "ราคา: ${products[index].price.toStringAsFixed(2)} บาท",
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteProduct(products[index].id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('เพิ่มสินค้า:'),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddProduct()),
                    );
                  },
                  label: const Text('Add'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
