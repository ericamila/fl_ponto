import 'package:flutter/material.dart';
import 'package:ponto_eletronico/extensions/date_time.dart';
import 'package:ponto_eletronico/model/registro.dart';
import 'package:ponto_eletronico/services/firestore_service.dart';
import 'package:ponto_eletronico/services/session_service.dart';
import 'package:ponto_eletronico/util/app_colors.dart';

import '../util/common.dart';

class FormRegister extends StatefulWidget {
  final String month;

  const FormRegister({super.key, required this.month});

  @override
  State<FormRegister> createState() => _FormRegisterState();
}

class _FormRegisterState extends State<FormRegister> {
  final _globalKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool _isEntrada = true;
  int monthSelected = DateTime.now().month;
  int year = DateTime.now().year;
  DateTime? _pickedDate;
  late TimeOfDay _pickedTime = TimeOfDay.now();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Posterior'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18.0),
            child: Icon(Icons.edit),
          )
        ],
      ),
      body: Form(
        key: _globalKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Preenchimento obrigatório';
                  }
                  return null;
                },
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_today),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preenchimento obrigatório';
                    }
                    return null;
                  },
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Hora',
                    filled: true,
                    prefixIcon: Icon(Icons.timer_outlined),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  onTap: _selectTime,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Entrada'),
                  Switch(
                    activeThumbColor: AppColor.azul,
                    activeTrackColor: AppColor.cinzaMedio,
                    value: _isEntrada,
                    onChanged: (value) => setState(() => _isEntrada = value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        if (_globalKey.currentState!.validate()) {
          final success = await _registrarPonto();
          if (mounted) {
            Navigator.pop(context, success);
          }
        }
      },
      label: const Text(
        'SALVAR',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      icon: const Icon(Icons.more_time),
    );
  }

  Future<void> _selectDate() async {
    _pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2044),
      locale: const Locale('pt', 'BR'),
    );

    if (_pickedDate != null) {
      setState(() {
        _dateController.text = _pickedDate!.formatBrazilianDate.split(" ")[0];
        monthSelected = _pickedDate!.month;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _pickedTime,
    );
    if (timeOfDay != null) {
      setState(() {
        _pickedTime = timeOfDay;
        _timeController.text = "${_pickedTime.hour.toString().padLeft(2, '0')}:${_pickedTime.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<bool> _registrarPonto() async {
    final token = SessionService().token;
    if (token == null) return false;

    final registro = Registro(
      data: '*${_dateController.text}',
      hora: _timeController.text,
      mes: monthSelected,
      ano: year,
      isEntrada: _isEntrada,
    );

    try {
      await FirestoreService().registrarPonto(token, registro);
      return true;
    } catch (error) {
      if (mounted) {
        showSnackBarDefault(context,
            message: 'Falha ao registrar!\n${error.toString()}');
      }
      return false;
    }
  }
}
