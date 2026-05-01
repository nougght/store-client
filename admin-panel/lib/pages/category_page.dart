import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart' as editor;

class CategoriesPage extends StatefulWidget {
  final ApiService api;

  const CategoriesPage({required this.api, Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String selectedCategoryId = '';
  bool loadingImages = true;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    final categoryProvider = context.read<CategoryModel>();
    final productProvider = context.read<ProductProvider>();

    if (categoryProvider.categories.isEmpty) {
      categoryProvider.loadCategories();
    }
    if (productProvider.products.isEmpty) {
      productProvider.fetchProducts();
    }

    Future.microtask(() async => await _loadImages());
  }

  String? getContentType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _loadImages() async {
    if (mounted) {
      setState(() => loadingImages = true);
    }
    try {
      List<String> images = [];
      String temp;
      for (final category in context.read<CategoryModel>().categories) {
        temp = await widget.api.getCategoryImage(category.id);
        images.add(temp);
      }
      if (mounted) {
        setState(() {
          imageUrls = images;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки изображений: $e');
    } finally {
      setState(() => loadingImages = false);
    }
  }

  Future<void> _pickAndUploadImage({required String categoryId}) async {
    // final picker = ImagePicker();
    // final file = await picker.pickImage(source: ImageSource.gallery);
    // if (file == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    // if (result == null || result.files.isEmpty) {
    //   debugPrint('Файл не выбран');
    //   return;
    // }

    var fileBytes = result?.files.first.bytes;
    debugPrint('Размер файла: ${fileBytes?.length ?? 0}');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => editor.ProImageEditor.memory(
          fileBytes!,
          // defaultEditorMode: ImageEditorMode.crop,
          callbacks: editor.ProImageEditorCallbacks(
            onImageEditingComplete: (bytes) async {
              fileBytes = bytes;
            },
            onCloseEditor: (mode) {
              Navigator.pop(context);
              return;
            },
          ),
          configs: editor.ProImageEditorConfigs(
            emojiEditor: editor.EmojiEditorConfigs(enabled: false),
            cropRotateEditor: editor.CropRotateEditorConfigs(
              initAspectRatio: 1.0, // фиксируем 1:1
              showAspectRatioButton: false, // пользователь не сможет переключить формат
              // enableFlipAnimation: true по желанию
            ),

            designMode: editor.ImageEditorDesignMode.cupertino,
          ),
        ),
      ),
    );

    final ext = result!.files.first.extension;
    try {
      // Получаем presigned PUT
      final putUrl = await widget.api.getCategoryPresignedPut(categoryId, ext!);

      // final Uint8List fileBytes = await file.readAsBytes();
      // Отправляем файл на MinIO
      await widget.api.uploadCategoryToPresignedUrl(
        putUrl,
        fileBytes!,
        contentType: getContentType(ext)!,
      );

      await _loadImages();
    } catch (e) {
      debugPrint('Ошибка загрузки изображения: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryModel>();
    final productProvider = context.watch<ProductProvider>();

    if (categoryProvider.isLoading || productProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (selectedCategoryId.isEmpty && categoryProvider.categories.isNotEmpty) {
      selectedCategoryId = categoryProvider.categories.first.id;
    }

    final selectedCategory = categoryProvider.getById(selectedCategoryId);
    final selectedProducts = productProvider.productsByCategoryId(selectedCategoryId);
    final otherProducts = productProvider.products
        .where((p) => p.categoryId != selectedCategoryId)
        .toList();

    final isWide = MediaQuery.of(context).size.width > 800;

    return loadingImages
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
      appBar: AppBar(title: const Text("Категории и товары")),
      body: isWide
          ? Row(
              children: [
                Expanded(flex: 2, child: _buildCategories(categoryProvider)),
                VerticalDivider(width: 1),
                Expanded(
                  flex: 4,
                  child: _buildProducts(
                    selectedCategory,
                    selectedProducts,
                    otherProducts,
                    categoryProvider,
                  ),
                ),
              ],
            )
          : ListView(
              children: [
                _buildCategories(categoryProvider),
                Divider(),
                _buildProducts(selectedCategory, selectedProducts, otherProducts, categoryProvider),
              ],
            ),
    );
  }

  /// Виджет списка категорий с редактированием
  Widget _buildCategories(CategoryModel categoryProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text("Категории", style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () {
              categoryProvider.addCategory(new Category(name: "Новая категория"));
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              final cat = categoryProvider.categories[index];
              final selected = cat.id == selectedCategoryId;

              return Card(
                color: selected ? Colors.blue.shade50 : null,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                // cat.imageUrl.isNotEmpty
                                //     ? Image.network(
                                //         cat.imageUrl,
                                //         width: 60,
                                //         height: 60,
                                //         fit: BoxFit.cover,
                                //       )
                                //     :
                                Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: Image.network(imageUrls[index], fit: BoxFit.contain),
                                ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: cat.name),
                              decoration: const InputDecoration(
                                labelText: "Название категории",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onSubmitted: (val) {
                                cat.name = val;
                                categoryProvider.updateCategory(cat);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              categoryProvider.deleteCategory(cat.id);
                              if (selectedCategoryId == cat.id &&
                                  categoryProvider.categories.isNotEmpty) {
                                setState(() {
                                  selectedCategoryId = categoryProvider.categories.first.id;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.photo_camera),
                          label: const Text("Изменить фото"),
                          onPressed: () async {
                            // Здесь можно вызвать image picker
                            // Пример:
                            _pickAndUploadImage(categoryId: categoryProvider.categories[index].id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Виджет редактирования товаров категории
  Widget _buildProducts(
    Category? category,
    List<Product> selectedProducts,
    List<Product> otherProducts,
    CategoryModel categoryProvider,
  ) {
    if (category == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Товары категории "${category.name}"',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: selectedProducts.length,
            itemBuilder: (context, index) {
              final product = selectedProducts[index];
              return Card(
                child: ListTile(
                  leading:
                      // product.imageUrl.isNotEmpty
                      //     ? Image.network(product.imageUrl, width: 40, height: 40, fit: BoxFit.cover)
                      //     :
                      const Icon(Icons.image),
                  title: Text(product.name),
                  subtitle: Text("Цена: ${product.price} ₽"),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        product.categoryId = "";
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8),
          child: const Text("Доступные для добавления товары"),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: otherProducts.length,
            itemBuilder: (context, index) {
              final product = otherProducts[index];
              return Card(
                child: ListTile(
                  title: Text(
                    "${product.name} (${categoryProvider.getById(product.categoryId)?.name ?? 'Без категории'})",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        product.categoryId = selectedCategoryId;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
