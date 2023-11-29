import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roless/roles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        // ignore: deprecated_member_use
        backgroundColor: const Color.fromARGB(255, 100, 0, 0),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({Key? key}) : super(key: key);

  Future<void> _login(BuildContext context) async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  try {
    final response = await http.get(
      Uri.parse('http://api-twbs.onrender.com/api/usuario'),
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      // Verifica si la respuesta es una lista, si no, intenta obtener la lista de usuarios del mapa
      List<dynamic> users = responseData is List ? responseData : responseData['usuarios'];

      var userFound = users.firstWhere(
        (user) => user['nombreUsu'] == username && user['password'] == password,
        orElse: () => null,
      );

      if (userFound != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        _showErrorDialog(context);
      }
    } else {
      print('Error al obtener usuarios. Código de estado: ${response.statusCode}');
    }
  } catch (e) {
    print('Error en la solicitud: $e');
  }
}

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de inicio de sesión'),
          content: const Text('Usuario o contraseña incorrectos.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de sesión'),
        backgroundColor: const Color.fromARGB(255, 100, 0, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset(
              'assets/logo-twbs-negro.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                _login(context);
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página principal'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú de navegación',
                style: TextStyle(
                  color: Color.fromARGB(255, 100, 0, 0),
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Roles'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Roles()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/logo-twbs-negro.png',
                height: 200,
                width: 200,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 100, 0, 0),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}