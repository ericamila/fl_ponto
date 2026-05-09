import 'package:flutter/material.dart';
import 'package:ponto_eletronico/components/table.dart';
import 'package:ponto_eletronico/screens/add.dart';
import 'package:ponto_eletronico/services/firestore_service.dart';
import 'package:ponto_eletronico/services/session_service.dart';
import '../model/registro.dart';
import '../util/common.dart';
import '../util/month.dart';

class Consulta extends StatelessWidget {
  final String month;

  const Consulta({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final sessionService = SessionService();
    final mes = Month.string(monthString: month).month;
    final token = sessionService.token ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta $month'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: TableCustom.criaTabela(rows: [
            TableCustom.criarLinhaTable(listaDados: "Data, Hora, Registro")
          ]),
        ),
      ),
      body: StreamBuilder<List<Registro>>(
        stream: firestoreService.getRegistros(token, mes),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          final registros = snapshot.data ?? [];

          if (registros.isEmpty) {
            return noData();
          }

          final rows = registros.map((model) {
            return TableCustom.criarLinhaTable(
                listaDados:
                    "${model.data}, ${model.hora}, ${model.isEntrada ? 'Entrada' : 'Saída'}");
          }).toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: SingleChildScrollView(
              child: TableCustom.criaTabela(rows: rows),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormRegister(
              month: month,
            ),
          ),
        ).then((value) {
          if (value != null) {
            (value == true)
                ? showSnackBarDefault(context)
                : showSnackBarDefault(context,
                    message: "Houve uma falha ao registrar.");
          }
        });
      },
      label: const Text(
        'ADICIONAR',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      icon: const Icon(Icons.more_time),
    );
  }

  Widget noData() {
    return const Center(
      child: Text('Nenhum registro encontrado para este mês.'),
    );
  }
}
