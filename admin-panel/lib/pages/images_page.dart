import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../api_client.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// import 'dart:html' as html;

class ImagesPage extends StatefulWidget {
  final ApiService api;
  const ImagesPage({super.key, required this.api});

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  Product? selectedProduct;
  bool loadingImages = false;
  List<String> imageUrls = [];
  List<String> imageNames = [];

  Future<void> _loadImages() async {
    if (selectedProduct == null) return;
    setState(() => loadingImages = true);

    try {
      final data = await widget.api.getProductImages(selectedProduct!.id); // presigned GET URLs
      // debugPrint(urls.toString());
      setState(() {
        imageUrls = data.map((e) => e['url']! as String).toList();
        imageNames = data.map((e) => e['object_name']! as String).toList();
      });
    } catch (e) {
      debugPrint('Ошибка загрузки изображений: $e');
    } finally {
      setState(() => loadingImages = false);
    }
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

  // Future<Uint8List?> pickFileWeb() async {
  //     final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //     uploadInput.accept = 'image/*'; // Только изображения
  //     uploadInput.click();

  //     await uploadInput.onChange.first;

  //     if (uploadInput.files!.isNotEmpty) {
  //       final html.File file = uploadInput.files!.first;
  //       final html.FileReader reader = html.FileReader();

  //       // Читаем файл как ArrayBuffer
  //       reader.readAsArrayBuffer(file);
  //       await reader.onLoad.first;

  //       // Конвертируем в Uint8List
  //       return Uint8List.fromList(reader.result as List<int>);
  //     }
  //     return null;
  //   }
  Future<void> _pickAndUploadImage({int? replaceIndex}) async {
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
        builder: (context) => ProImageEditor.memory(
          
          fileBytes!,
          // defaultEditorMode: ImageEditorMode.crop,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (bytes) async {fileBytes = bytes;},
            onCloseEditor: (mode) {Navigator.pop(context); return;},
          ),
          configs: ProImageEditorConfigs(
            imageGeneration: ImageGenerationConfigs(
              outputFormat: OutputFormat.png,
              pngLevel: 9,
              
            ),
            emojiEditor: EmojiEditorConfigs(enabled: false),
            cropRotateEditor: CropRotateEditorConfigs(
              initAspectRatio: 1.0, // фиксируем 1:1
              showAspectRatioButton: false, // пользователь не сможет переключить формат
              // enableFlipAnimation: true
              
            ),
            
            designMode: ImageEditorDesignMode.cupertino
          ),
        ),
      ),
    );

    debugPrint('Размер файла: ${fileBytes?.length ?? 0}');
    final productId = selectedProduct!.id;
    final index = replaceIndex ?? imageUrls.length;
    // final filename = '${productId}_$index.jpg';

    
    final ext = result!.files.first.extension;
    try {
      // Получаем presigned PUT
      final putUrl = await widget.api.getProductPresignedPut(productId, index, ext!);

      // final Uint8List fileBytes = await file.readAsBytes();
      // Отправляем файл на MinIO
      await widget.api.uploadProductToPresignedUrl(
        putUrl,
        fileBytes!,
        contentType: getContentType(ext)!,
      );

      await _loadImages();
    } catch (e) {
      debugPrint('Ошибка загрузки изображения: $e');
    }
  }

  Future<void> _deleteImage(int index) async {
    try {
      // final filename = '${selectedProduct!.id}_$index.jpg';

      await widget.api.deleteProductImage(selectedProduct!.id, index, imageNames[index].split('.').last);
      await _loadImages();
    } catch (e) {
      debugPrint('Ошибка удаления изображения: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            // Список товаров
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: provider.products.length,
                itemBuilder: (context, index) {
                  final product = provider.products[index];
                  return ListTile(
                    title: Text(product.name),
                    selected: selectedProduct?.id == product.id,
                    onTap: () async {
                      setState(() {
                        selectedProduct = product;
                        imageUrls.clear();
                      });
                      await _loadImages();
                    },
                  );
                },
              ),
            ),

            // Список изображений
            Expanded(
              flex: 3,
              child: selectedProduct == null
                  ? const Center(child: Text('Выберите товар'))
                  : loadingImages
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        ListTile(
                          title: Text('Изображения товара "${selectedProduct!.name}"'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _pickAndUploadImage(),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              final url = imageUrls[index];
                              debugPrint(url);
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Image.network(url, height: 100, fit: BoxFit.cover),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _pickAndUploadImage(replaceIndex: index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteImage(index),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
