import 'package:checkfood/db/database_helper.dart';
import 'package:checkfood/model/ingrediente.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class IngredientListScreen extends StatefulWidget {
  final String foodId;
  final String foodName;

  const IngredientListScreen({Key? key, required this.foodId, required this.foodName}) : super(key: key);

  @override
  _IngredientListScreenState createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> {
  late Future<List<Ingrediente>> _ingredientList;

  @override
  void initState() {
    super.initState();
    _refreshIngredientList();
  }

  void _refreshIngredientList() {
    setState(() {
      _ingredientList = DatabaseHelper.instance.getIngredientesPorComida(widget.foodId);
    });
  }

  void _showAddIngredientDialog() {
    final _formKey = GlobalKey<FormState>();
    String _nome = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Novo Ingrediente'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(labelText: 'Nome'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome';
                }
                return null;
              },
              onSaved: (value) {
                _nome = value!;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newIngredient = Ingrediente(
                    id: Uuid().v4(),
                    nome: _nome,
                    marcado: false,
                    data_de_criacao: DateTime.now(),
                    comida_id: widget.foodId,
                  );
                  await DatabaseHelper.instance.insertIngrediente(newIngredient);
                  Navigator.pop(context);
                  _refreshIngredientList();
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodName),
      ),
      body: FutureBuilder<List<Ingrediente>>(
        future: _ingredientList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum ingrediente cadastrado.'));
          } else {
            final ingredientList = snapshot.data!;
            return ListView.builder(
              itemCount: ingredientList.length,
              itemBuilder: (context, index) {
                final ingredient = ingredientList[index];
                return ListTile(
                  title: Text(ingredient.nome),
                  subtitle: Text(ingredient.marcado && ingredient.data_de_aquisicao != null
                      ? 'Adquirido em: ${ingredient.data_de_aquisicao!.toLocal().toString().split(' ')[0]}'
                      : 'Criado em: ${ingredient.data_de_criacao.toLocal().toString().split(' ')[0]}'),
                  trailing: Checkbox(
                    value: ingredient.marcado,
                    onChanged: (bool? value) {
                      setState(() {
                        ingredient.marcado = value!;
                        if (ingredient.marcado) {
                          ingredient.data_de_aquisicao = DateTime.now();
                        } else {
                          ingredient.data_de_aquisicao = null;
                        }
                      });
                      DatabaseHelper.instance.updateIngrediente(ingredient);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIngredientDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}