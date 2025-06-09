import 'package:flutter/material.dart';
import '../widgets/search_bar.dart'; // Importa tu widget personalizado
import '../widgets/file_post_card.dart';
import '../services/file_service.dart';
import '../models/file_post.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FilePost> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Aquí puedes adaptar para buscar por materias, carreras o tags
      final List<FilePost> files = await FileService().getFilesByTags([query.trim()]);
      setState(() {
        _results = files;
      });
      if (files.isEmpty) {
        setState(() {
          _error = 'No se encontraron archivos con ese criterio.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al buscar: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSearchBar(
          controller: _searchController,
          onChanged: (value) {
            if (value.trim().isEmpty) {
              setState(() => _results = []);
              return;
            }
            _search(value);
          },
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty && _error == null
              ? const Center(child: Text('Busca por materia, etiqueta, carrera, etc.'))
              : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) => FilePostCard(filePost: _results[index]),
          ),
        ),
      ],
    );
  }
}