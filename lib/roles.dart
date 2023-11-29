// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Roles extends StatefulWidget {
  const Roles({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RolesState createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  List<Map<String, dynamic>> configuraciones = [];
  List<Map<String, dynamic>> filteredConfiguraciones = [];
  final TextEditingController _rolController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _permisosController = TextEditingController();
  final TextEditingController _rolEditController = TextEditingController();
  final TextEditingController _estadoEditController = TextEditingController();
  final TextEditingController _permisosEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api-twbs.onrender.com/api/configuracion/'),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final configuracionesData = decodedData['configuraciones'] ?? [];

        setState(() {
          configuraciones = List<Map<String, dynamic>>.from(configuracionesData);
          filteredConfiguraciones = configuraciones;
        });
      } else {
        print('Error al obtener los datos. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud: $e');
    }
  }

  void _filterConfiguraciones(String query) {
    setState(() {
      filteredConfiguraciones = configuraciones.where((config) {
        final rol = config['rol'].toString().toLowerCase();
        return rol.contains(query.toLowerCase());
      }).toList();
    });
  }

 Future<void> _registrarNuevoDato() async {
  if (_rolController.text.isEmpty ||
      _estadoController.text.isEmpty ||
      _permisosController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, llena todos los campos')),
    );
    return; // Detener la ejecución si algún campo está vacío
  }

  try {
    final response = await http.post(
      Uri.parse('https://api-twbs.onrender.com/api/configuracion'),
      body: jsonEncode({
        'rol': _rolController.text,
        'estado': _estadoController.text,
        'permisos': _permisosController.text.split(',').map((e) => e.trim()).toList(),
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _rolController.clear();
        _estadoController.clear();
        _permisosController.clear();
      });
      await _fetchData(); // Actualiza los datos después de agregar uno nuevo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar el nuevo dato')),
      );
      print('Error al registrar el nuevo dato. Código de estado: ${response.statusCode}');
      print('Respuesta de la API: ${response.body}');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error en la solicitud')),
    );
    print('Error en la solicitud: $e');
  }
}


//ACTUALIZAR
Future<void> _actualizarDato(int index) async {
  try {
    final String id = configuraciones[index]['_id'];

    final response = await http.put(
      Uri.parse('https://api-twbs.onrender.com/api/configuracion/'),
      body: jsonEncode({
        '_id': id,
        'rol': _rolEditController.text,
        'estado': _estadoEditController.text,
        'permisos': _permisosEditController.text.split(',').map((e) => e.trim()).toList(),
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        configuraciones[index]['rol'] = _rolEditController.text;
        configuraciones[index]['estado'] = _estadoEditController.text;
        configuraciones[index]['permisos'] = _permisosEditController.text.split(',').map((e) => e.trim()).toList();
      });
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dato actualizado correctamente')),
      );
    } else {
      print('Error al actualizar el dato. Código de estado: ${response.statusCode}');
      print('Respuesta de la API: ${response.body}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el dato')),
      );
    }
  } catch (e) {
    print('Error en la solicitud: $e');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error en la solicitud')),
    );
  }
}
  void _mostrarDialogoEditar(int index) {
    _rolEditController.text = configuraciones[index]['rol'];
    _estadoEditController.text = configuraciones[index]['estado'];
    _permisosEditController.text = configuraciones[index]['permisos']?.join(', ') ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Datos'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _rolEditController,
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
              TextFormField(
                controller: _estadoEditController,
                decoration: const InputDecoration(labelText: 'Estado'),
              ),
              TextFormField(
                controller: _permisosEditController,
                decoration: const InputDecoration(labelText: 'Permisos'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _actualizarDato(index);
              },
              child: const Text('Guardar Cambios'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }




void _mostrarDialogoEliminar(String id, int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de eliminar este elemento?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _eliminarDato(id, index);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );
}

Future<void> _eliminarDato(String id, int index) async {
  try {
    final response = await http.delete(
      Uri.parse('https://api-twbs.onrender.com/api/configuracion/'), // Agrega el id en la URL de eliminación
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        configuraciones.removeAt(index);
        filteredConfiguraciones = List.from(configuraciones);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elemento eliminado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el elemento')),
      );
      print('Error al eliminar el elemento. Código de estado: ${response.statusCode}');
      print('Respuesta de la API: ${response.body}');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error en la solicitud')),
    );
    print('Error en la solicitud: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de roles'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onChanged: (value) {
                _filterConfiguraciones(value);
              },
              decoration: const InputDecoration(
                labelText: 'Buscar por Rol',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredConfiguraciones.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text(filteredConfiguraciones[index]['rol'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado: ${filteredConfiguraciones[index]['estado'] ?? ''}'),
                        const SizedBox(height: 4),
                        Text('Permisos: ${filteredConfiguraciones[index]['permisos']?.join(", ") ?? ''}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _mostrarDialogoEditar(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _mostrarDialogoEliminar(filteredConfiguraciones[index]['_id'], index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _rolController,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                  ),
                ),
                TextFormField(
                  controller: _estadoController,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                  ),
                ),
                TextFormField(
                  controller: _permisosController,
                  decoration: const InputDecoration(
                    labelText: 'Permisos',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _registrarNuevoDato();
                  },
                  child: const Text('Registrar Nuevo Dato'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}