import 'package:flutter/material.dart';
import 'package:ponto_eletronico/extensions/date_time.dart';
import 'package:ponto_eletronico/model/registro.dart';
import 'package:ponto_eletronico/screens/search.dart';
import 'package:ponto_eletronico/services/firestore_service.dart';
import 'package:ponto_eletronico/services/session_service.dart';
import '../components/confirmation_dialog.dart';
import '../components/confirmation_dialog_consultar.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _feedback = '';
  final _firestoreService = FirestoreService();
  final _sessionService = SessionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_feedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(_feedback, textAlign: TextAlign.center),
              ),
            ElevatedButton(
                onPressed: _registrarPonto, child: const Text('Registrar')),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: _consultarPonto,
                child: const Text('Consultar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registrarPonto() async {
    final now = DateTime.now();
    
    final result = await showConfirmationDialog(
      context,
      negativeOption: 'Entrada',
      affirmativeOption: 'Saída',
      content: 'Registrar Entrada ou Saída?',
    );

    if (result != null) {
      final isEntrada = !result; // Assuming true was 'Saída' and false was 'Entrada' in the previous logic
      
      final token = _sessionService.token;
      if (token == null) return;

      final novoRegistro = Registro(
        data: now.formatBrazilianDate,
        hora: now.formatBrazilianTime,
        mes: now.month,
        ano: now.year,
        isEntrada: isEntrada,
      );

      try {
        await _firestoreService.registrarPonto(token, novoRegistro);
        setState(() {
          _feedback = '${isEntrada ? 'ENTRADA' : 'SAÍDA'} REGISTRADA:\n '
              '${now.formatBrazilianDate} - ${now.formatBrazilianTime}';
        });
      } catch (error) {
        setState(() {
          _feedback = "Erro ao registrar: $error";
        });
      }
    }
  }

  void _consultarPonto() async {
    final value = await showConfirmationDialogConsulta(context);
    if (value != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Consulta(month: value),
        ),
      );
    }
  }
}
