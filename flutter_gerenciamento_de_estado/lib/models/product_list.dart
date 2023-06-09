import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'package:flutter_gerenciamento_de_estado/models/product.dart';
import 'package:flutter_gerenciamento_de_estado/utils/contants.dart';
import 'package:http/http.dart' as http;

class ProductList with ChangeNotifier {
 
  final List<Product> _items = [];

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();

  
  Future<void> loadProducts() async{
    _items.clear();
   final response = await http.get(Uri.parse('${Constantes.productBaseUrl}.json'));
   if(response.body == 'null') return;
   Map<String,dynamic> data = jsonDecode(response.body);
   data.forEach((productId, productData) {
    _items.add(Product(
      id: productId,
       name:productData['name'] ,
        description:productData['description'] ,
         price:productData['price'] ,
          imageUrl:productData['imageUrl'] ,
          isFavorite:productData['isFavorite'] ,
          ),
          );
   });
   notifyListeners();
  }



  Future<void> saveProduct(Map<String,Object> data) {
    bool hasId = data['id'] != null;
   
    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );
    if(hasId){
      return updateProduct(product);

    }else{
      return addProduct(product);
    }
    
  }

  Future<void> addProduct(Product product) async {
    final response =
     await http.post(
    Uri.parse('${Constantes.productBaseUrl}.json'),
    body: jsonEncode({
      "name":product.name,
      "description":product.description,
      "price":product.price,
      "imageUrl":product.imageUrl,
      "isFavorite":product.isFavorite,
    },
    ),
    );
   
   final id = jsonDecode(response.body)['name'];
      _items.add(Product(
        id: id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl
        ));
      
      notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
  int index = _items.indexWhere((p) => p.id == product.id);

    if(index >= 0){
     await http.patch(
      Uri.parse('${Constantes.productBaseUrl}/${product.id}.json'),
      body:  jsonEncode({
        "name":product.name,
        "description":product.description,
        "price":product.price,
        "imageUrl":product.imageUrl,
      },),
    ); 
    _items[index] = product;
    notifyListeners();
    }
    return Future.value();
  }

  Future<void> removeProduct(Product product) async{
   int index = _items.indexWhere((p) => p.id == product.id);

   if(index >= 0){
    final product = _items[index];
    _items.remove(product);
    notifyListeners();
    final response = await http.delete(
      Uri.parse('${Constantes.productBaseUrl}/${product.id}.json'),
      
    ); 
    if(response.statusCode >= 400) {
       _items.insert(index, product);
       notifyListeners();
       throw const HttpException(
        'Não foi possivel excluir o produto',
        
        );
    }
    }
  
  }

  int get itemsCount {
    return _items.length;
  }

  // bool _showFavoriteOnly = false;

  // List<Product> get items {
  //   if (_showFavoriteOnly) {
  //     return _items.where((prod) => prod.isFavorite).toList();
  //   }
  //   return [...items];
  // }

  // void showFavoriteOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }
}
