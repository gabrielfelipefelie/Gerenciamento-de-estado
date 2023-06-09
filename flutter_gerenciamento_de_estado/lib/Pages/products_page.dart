

import 'package:flutter/material.dart';
import 'package:flutter_gerenciamento_de_estado/components/app_drawer.dart';
import 'package:flutter_gerenciamento_de_estado/components/product_item.dart';

import 'package:flutter_gerenciamento_de_estado/models/product_list.dart';
import 'package:provider/provider.dart';

import '../utils/app_routes.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);


 Future<void> _refreshProducts(BuildContext context){
 return Provider.of<ProductList>(context,listen: false).loadProducts();
 }
  @override
  Widget build(BuildContext context) {
    final ProductList products = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Produtos'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.productForm);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: products.itemsCount,
            itemBuilder: (ctx, i) => Column(
              children: [
                ProductItem(products.items[i]),
                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
