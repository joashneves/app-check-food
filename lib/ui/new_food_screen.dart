
import 'package:checkfood/db/database_helper.dart';
import 'package:checkfood/model/comida.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NewFoodScreen extends StatefulWidget {
  const NewFoodScreen({Key? key}) : super(key: key);

  @override
  _NewFoodScreenState createState() => _NewFoodScreenState();
}

class _NewFoodScreenState extends State<NewFoodScreen> {
  final _oQueEController = TextEditingController();
  final _tipoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Comida'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _oQueEController,
              decoration: InputDecoration(
                labelText: 'O que é a comida',
              ),
            ),
            TextField(
              controller: _tipoController,
              decoration: InputDecoration(
                labelText: 'Tipo da comida',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final oQueE = _oQueEController.text;
                final tipo = _tipoController.text;

                if (oQueE.isNotEmpty && tipo.isNotEmpty) {
                  final newFood = Comida(
                    id: Uuid().v4(),
                    o_que_e_a_comida: oQueE,
                    tipo_da_comida: tipo,
                    dia_para_fazer: DateTime.now(),
                    ingredientes_faltando: 0,
                    tem_todos_ingredientes: false,
                    ingredientes: [],
                  );

                  await DatabaseHelper().insertComida(newFood);

                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
