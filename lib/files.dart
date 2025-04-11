import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:ultimate_cloud/video_player.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => FilesScreenState();
}

class FilesScreenState extends State<FilesScreen> {
  List<dynamic> _files = [];
  bool _isLoading = false;

  Future<void> _fetchFiles() async {
    setState(() => _isLoading = true);
    final url = Uri.parse("https://ulcloud.ru/api/v1/storage/files");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decoded);
        setState(() {
          _files = data;
        });
      } else {
        print("Ошибка загрузки: ${response.statusCode}");
      }
    } catch (e) {
      print("Ошибка: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    final uri = Uri.parse("https://ulcloud.ru/api/v1/storage/upload");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));

    final response = await request.send();
    if (response.statusCode == 200) {
      print('Файл успешно загружен');
      await _fetchFiles();
    } else {
      print('Ошибка при загрузке: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Файлы на сервере")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchFiles,
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  final name = file['name']?.toString() ?? 'Без имени';
                  final size = int.tryParse(file['size'].toString()) ?? 0;
                  final progress = int.tryParse(file['progress'].toString()) ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(progress == 100 ? Icons.insert_drive_file : Icons.cloud_download),
                      title: Text(name),
                      subtitle: progress < 100 ? Text('Загрузка: $progress%') : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoScreen(filename: name),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadFile,
        child: const Icon(Icons.upload),
      ),
    );
  }
}
