import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart' as picker;
import '../services/file_service.dart';
import '../models/file_post.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();

  picker.PlatformFile? _selectedFile;
  FileType? _selectedType;
  bool _loading = false;
  String? _error;
  String? _success;

  final Map<String, FileType> _fileTypeOptions = {
    'Documento': FileType.document,
    'Imagen': FileType.image,
    'Guía': FileType.guide,
    'Apuntes': FileType.apuntes,
    'Otro': FileType.otro,
  };

  Future<void> _pickFile() async {
    setState(() {
      _error = null;
      _success = null;
    });
    try {
      final result = await picker.FilePicker.platform.pickFiles(
        type: picker.FileType.any,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al seleccionar archivo: $e';
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null || _selectedType == null) {
      setState(() {
        _error = 'Completa todos los campos y selecciona un archivo y tipo.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _loading = false;
        _error = 'No has iniciado sesión.';
      });
      return;
    }
    try {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final file = File(_selectedFile!.path!);

      await FileService().uploadFileAndCreatePost(
        file: file,
        uploaderUid: currentUser.uid,
        uploaderName: currentUser.displayName ?? 'Anónimo',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        tags: tags,
        fileType: _selectedType!,
      );
      setState(() {
        _success = '¡Archivo subido correctamente!';
        _selectedFile = null;
        _titleController.clear();
        _descController.clear();
        _tagsController.clear();
        _selectedType = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al subir archivo: $e';
      });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text("Subir archivo o apunte",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<FileType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: "Tipo de archivo",
                border: OutlineInputBorder(),
              ),
              items: _fileTypeOptions.entries
                  .map((entry) => DropdownMenuItem(
                value: entry.value,
                child: Text(entry.key),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              validator: (value) =>
              value == null ? 'Selecciona el tipo de archivo' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: "Etiquetas (separadas por coma)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFile == null
                  ? "Seleccionar archivo"
                  : "Archivo: ${_selectedFile!.name}"),
              onPressed: _pickFile,
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "Seleccionado: ${_selectedFile!.name}",
                  style: const TextStyle(fontSize: 13, color: Colors.green),
                ),
              ),
            const SizedBox(height: 18),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_success != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_success!,
                    style: const TextStyle(color: Colors.green)),
              ),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Subir archivo"),
              onPressed: _upload,
            ),
          ],
        ),
      ),
    );
  }
}