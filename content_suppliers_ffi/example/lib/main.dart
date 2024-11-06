import 'package:content_suppliers_ffi/ffi_bridge.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FFIBridge _bridge;

  bool loading = false;
  String result = "";

  @override
  void initState() {
    super.initState();
    _bridge = FFIBridge.load(
      dir: "../rust/target/debug/",
      libName: "libcontent_suppliers_ffi",
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (loading) const CircularProgressIndicator() else Text(result),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  final res = _bridge.supportedLanguages("dummy");
                  setState(() {
                    loading = false;
                    result = res.join(",");
                  });
                },
                child: const Text("test"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
