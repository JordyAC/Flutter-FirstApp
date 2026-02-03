import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';  // Para JSON

final usuariosProvider = FutureProvider<List>((ref)
  async{
    final dio = Dio();
    final response = await dio.get("https://jsonplaceholder.typicode.com/users");
    //Se busca modificar el manejo de errore con un try catch que muestre un mensaje más amigable con el usuario
    try{
      if(response.statusCode == 200){
        return response.data;
      } else {
        throw Exception('Error HTTP código: ${response.statusCode}');
      }
    } catch (e){
      throw Exception('Error de red: $e');
    }
  }
);

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 194, 181, 65),
        ),
      ),
      home: const MyHomePage(title: 'Pantalla Inicial'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Aquí se debe agregar un paddind al text para que el texto no llegue hasta los bordes del dispositivo
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(

              'Bienvenido a la app de registro de productos.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            ),
            const SizedBox(height: 16),
            //Se debe agregar una separación ligera entre los botones que se encuentran a continuación
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaRegistro(),
                  ),
                );
              },
              child: const Text('Registrar Producto'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaUsuarios(),
                  ),
                );
              },
              child: const Text('Ver Usuarios'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaDioPlusRiverPod(),
                  ),
                );
              },
              child: const Text(' Ver Usuarios \n con Dio + RiverPod'),
            ),
          ],
        ),
      ),
    );
  }
}

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _guardarProducto() async {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final precioTexto = _precioController.text.trim();

    // Tus validaciones (mejoro mensajes)
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del producto es requerido')),
      );
      return;
    }
    if (precioTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio del producto es requerido')),
      );
      return;
    }
    final precio = double.tryParse(precioTexto);
    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un precio válido > 0')),
      );
      return;
    }

    // **GUARDADO REAL LOCAL**
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> productos = [];
    // Carga lista existente (o vacía)
    String? productosJson = prefs.getString('productos');
    if (productosJson != null) {
      productos = jsonDecode(productosJson);
    }
    // Agrega nuevo
    productos.add({
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
    });
    // Guarda
    await prefs.setString('productos', jsonEncode(productos));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Guardado: $nombre - \$${precio.toStringAsFixed(2)}!')),
    );
    // Limpia campos
    _nombreController.clear();
    _descripcionController.clear();
    _precioController.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Productos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Producto',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del Producto',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(
                labelText: 'Precio del Producto',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _guardarProducto,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class PantallaUsuarios extends StatefulWidget{
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  final Dio _dio = Dio();
  List<dynamic> _usuarios = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios Registrados'),
      ),
      body: (){
        if(_cargando){
          return const Center(child: CircularProgressIndicator());
        }
        if(_error != null){
          return Center(child: Text('Error: $_error'));
        }
        if (_usuarios.isEmpty){
          return const Center(child: Text('No hay usuarios disponibles.'));
        }
        return ListView.builder(
          itemCount: _usuarios.length,
          itemBuilder: (context, index){
            final usuario = _usuarios[index];
            final nombre = usuario['name'] ?? '';
            final email = usuario['email'] ?? '';
            return ListTile(
              title: Text(nombre),
              subtitle: Text(email),
            );
          },
          padding: const EdgeInsets.all(16.0),
        );
      }(
      ),
    );
  }

  Future<void> _cargarUsuarios() async {
    _cargando = true;
    _error = null;
    try{
      final response = await _dio.get('https://jsonplaceholder.typicode.com/users');
      if (response.statusCode == 200) {
        _usuarios = response.data;
      } else {
        _error = 'Error HTTP código: ${response.statusCode}';
      }
    }
    catch (e) {
      _error = 'Error de red: $e';
    }
    setState((){
      _cargando = false;
    });
  }
}

class PantallaDioPlusRiverPod extends ConsumerWidget{
  const PantallaDioPlusRiverPod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosProvider);
    
      return Scaffold(
        appBar: AppBar(
          title: const Text('Usuarios con Dio + RiverPod'),
        ),
        body: usuariosAsync.when(
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text('Algo salió mal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('No pudimos cargar los usuarios en este momento. Por favor, intenta de nuevo más tarde.', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          data: (usuarios){
            if(usuarios.isEmpty){
              return const Center(child: Text('No hay usuarios disponibles.'));
            }
            return ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index){
                final usuario = usuarios[index];
                final nombre = usuario['name'] ?? '';
                final email = usuario['email'] ?? '';
                return ListTile(
                  title: Text(nombre),
                  subtitle: Text(email),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          )
      );
  }
}