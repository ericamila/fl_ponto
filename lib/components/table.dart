import 'package:flutter/material.dart';

import '../util/app_colors.dart';

class TableCustom {
  static Table criaTabela({required List<TableRow> rows}) {
    return Table(
        border: const TableBorder(
          horizontalInside: BorderSide(color: Colors.black),
          verticalInside: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
        children: rows);
  }

  static TableRow criarLinhaTable({required String listaDados}) {
    return TableRow(
      children: listaDados.split(',').map((name) {
        return Container(
          color: (listaDados.contains('Data'))
              ? AppColor.cinzaMedio
              : AppColor.branco,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            name,
            style: (listaDados.contains('Data'))
                ? const TextStyle(fontWeight: FontWeight.bold)
                : TextStyle(
                    color: (name.contains('Entrada'))
                        ? AppColor.azul
                        : (name.contains('Saída'))
                            ? AppColor.vermelho
                            : Colors.black87),
          ),
        );
      }).toList(),
    );
  }
}
