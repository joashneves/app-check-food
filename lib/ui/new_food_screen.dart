import 'package:checkfood/model/comida.dart';
import 'package:checkfood/providers/food_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// Tela para criar uma nova comida ou editar uma existente.
class NewFoodScreen extends StatefulWidget {
  const NewFoodScreen({Key? key}) : super(key: key);

  @override
  _NewFoodScreenState createState() => _NewFoodScreenState();
}

class _NewFoodScreenState extends State<NewFoodScreen> {
  final _oQueEController = TextEditingController();
  final _tipoController = TextEditingController();
  Comida? _existingComida;

  // Chamado quando as dependências do estado mudam.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtém o ID da comida passado como argumento da rota.
    final comidaId = ModalRoute.of(context)?.settings.arguments as String?;
    // Se um ID for passado, a tela está em modo de edição.
    if (comidaId != null) {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      // Encontra a comida existente na lista do provider.
      _existingComida = foodProvider.comidas.firstWhere((c) => c.id == comidaId);
      // Preenche os controladores do formulário com os dados da comida existente.
      _oQueEController.text = _existingComida!.o_que_e_a_comida;
      _tipoController.text = _existingComida!.tipo_da_comida;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Altera o título da tela dependendo se está em modo de edição ou criação.
        title: Text(_existingComida != null ? 'Editar Comida' : 'Nova Comida'),
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
                  // Se a tela estiver em modo de edição, atualiza a comida existente.
                  if (_existingComida != null) {
                    final updatedComida = Comida(
                      id: _existingComida!.id,
                      o_que_e_a_comida: oQueE,
                      tipo_da_comida: tipo,
                      dia_para_fazer: _existingComida!.dia_para_fazer,
                      ingredientes_faltando: _existingComida!.ingredientes_faltando,
                      tem_todos_ingredientes: _existingComida!.tem_todos_ingredientes,
                      ingredientes: _existingComida!.ingredientes,
                    );
                    await Provider.of<FoodProvider>(context, listen: false).updateComida(updatedComida);
                  } else {
                    // Se a tela estiver em modo de criação, cria uma nova comida.
                    final newFood = Comida(
                      id: Uuid().v4(),
                      o_que_e_a_comida: oQueE,
                      tipo_da_comida: tipo,
                      dia_para_fazer: DateTime.now(),
                      ingredientes_faltando: 0,
                      tem_todos_ingredientes: false,
                      ingredientes: [],
                    );
                    await Provider.of<FoodProvider>(context, listen: false).addComida(newFood);
                  }

                  // Fecha a tela após salvar.
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
