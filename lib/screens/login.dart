import 'package:flutter/material.dart';
import 'package:ponto_eletronico/services/auth_service.dart';
import 'package:ponto_eletronico/services/firestore_service.dart';
import 'package:ponto_eletronico/services/session_service.dart';

import '../util/format_txt.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.punch_clock,
                    size: 64,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 16),
                  const Text("Insira o Token"),
                  TextFormField(
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Preencha este campo'
                          : null;
                    },
                    controller: _tokenController,
                    decoration: const InputDecoration(label: Text("Token")),
                    inputFormatters: [UppCase()],
                  ),
                  TextFormField(
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Preencha este campo'
                          : null;
                    },
                    controller: _nameController,
                    decoration: const InputDecoration(
                      label: Text("Nome"),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FilledButton(
                              onPressed: _login,
                              child: const Text("Continuar")),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = _tokenController.text.trim();
    final name = _nameController.text.trim();

    try {
      final firestoreService = FirestoreService();
      final authService = AuthService();
      final sessionService = SessionService();

      await firestoreService.saveUserInfo(token, name);
      await authService.saveUser(token, name);
      sessionService.setSession(token, name);

      if (mounted) {
        Navigator.pushReplacementNamed(context, "home");
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
            context: context, message: "Erro ao entrar: $e", sucess: false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

void showSnackBar(
    {required BuildContext context,
    required String message,
    required bool sucess}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: (sucess) ? Colors.teal : Colors.orangeAccent,
    behavior: SnackBarBehavior.floating,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
