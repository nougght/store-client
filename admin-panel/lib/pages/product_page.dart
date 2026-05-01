import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {

  @override
  void initState() {
    super.initState();
    final productProvider = context.read<ProductProvider>();
    final categoryProvider = context.read<CategoryModel>();
    if (categoryProvider.categories.isEmpty) categoryProvider.loadCategories();
    if (productProvider.products.isEmpty) productProvider.fetchProducts();
  }



  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryModel>();
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            /// Список товаров
            Expanded(
              flex: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Товары'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        provider.selectProduct(
                          Product(
                            id: '',
                            name: '',
                            description: '',
                            price: 0,
                            categoryId: '',
                            // images: [],
                            quantity: 0,
                            unit: '',
                            stock: 0,
                            // isActive: true,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                body: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text('${product.price} ₽'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await provider.deleteProduct(product.id);
                              },
                            ),
                            onTap: () => provider.selectProduct(product),
                          );
                        },
                      ),
              ),
            ),

            /// Боковая панель
            if (provider.selectedProduct != null)
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey.shade100,
                  child: _ProductEditor(product: provider.selectedProduct!, categories: categoryProvider.categories),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProductEditor extends StatefulWidget {
  final Product product;
  final List<Category> categories;

  const _ProductEditor({required this.product, required this.categories});

  @override
  State<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<_ProductEditor> {
  final _formKey = GlobalKey<FormState>();
  late Product _edited;

  @override
  void initState() {
    super.initState();
    _edited = widget.product.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Container(
      decoration: BoxDecoration(border: BoxBorder.symmetric(vertical: BorderSide(width: 1))),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_edited.id.isEmpty ? 'Новый товар' : 'Редактировать товар'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => provider.selectProduct(null),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// Основная информация
                ExpansionTile(
                  title: const Text('Основная информация'),

                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: _edited.name,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        border: OutlineInputBorder(),
                        
                      ),
                      
                      onChanged: (v) => _edited = _edited.copyWith(name: v),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: _edited.description,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        border: OutlineInputBorder(),
                      ),

                      maxLines: 3,
                      onChanged: (v) => _edited = _edited.copyWith(description: v),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _edited.categoryId.isNotEmpty ? _edited.categoryId : null,
                      decoration: const InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(),
                      ),
                      items: widget.categories
                          .map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)))
                          .toList(),
                      onChanged: (v) => _edited = _edited.copyWith(categoryId: v ?? ''),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                /// Цена и склад
                ExpansionTile(
                  title: const Text('Цена и количество'),
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: _edited.price.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Цена',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _edited = _edited.copyWith(price: double.tryParse(v) ?? 0),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: _edited.quantity.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Вес/объём одного товара',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          _edited = _edited.copyWith(quantity: double.tryParse(v) ?? 0),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: _edited.unit,
                      decoration: const InputDecoration(
                        labelText: 'Единица измерения',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _edited = _edited.copyWith(unit: v),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: _edited.stock.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Количество на складе',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _edited = _edited.copyWith(stock: int.tryParse(v) ?? 0),
                    ),
                    SizedBox(height: 10),
                    SwitchListTile(
                      // value: _edited.isActive,
                      value: true,
                      title: const Text('Активен'),
                      // onChanged: (v) => setState(() => _edited = _edited.copyWith(isActive: v)),
                      onChanged: (value) {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Сохранить'),
                  onPressed: () async {
                    if (_edited.id.isEmpty) {
                      await provider.addProduct(_edited);
                    } else {
                      await provider.updateProduct(_edited);
                    }
                    provider.selectProduct(null);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
