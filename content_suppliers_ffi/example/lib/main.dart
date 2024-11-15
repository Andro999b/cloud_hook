import 'package:flutter/material.dart';
import 'package:content_suppliers_ffi/ffi_bridge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FFI Test",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _result = "";
  late FFIBridge bridge;

  @override
  void initState() {
    bridge = FFIBridge.load(libPath: "libcontent_suppliers_ffi.so");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              _result,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            FilledButton(
              onPressed: () {
                try {
                  final sups = bridge.avalaibleSuppliers();
                  setState(() {
                    _result = sups.join(",");
                  });
                } catch (e) {
                  setState(() {
                    _result = "Error: $e";
                  });
                }
              },
              child: const Text("Test"),
            )
          ],
        ),
      ),
    );
  }
}
