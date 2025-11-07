# CheckFood

O CheckFood é um aplicativo Flutter projetado para ajudar os usuários a gerenciar suas listas de compras e o planejamento de refeições.

## Estrutura do Projeto

O projeto está organizado da seguinte forma:

```
/lib
|-- /db
|   `-- database_helper.dart
|-- /model
|   |-- comida.dart
|   `-- ingrediente.dart
|   -- /repository
|   `-- food_repository.dart
|-- /ui
|   |-- food_list_screen.dart
|   |-- ingredient_list_screen.dart
|   `-- new_food_screen.dart
|-- /providers
|   `-- theme_provider.dart
`-- main.dart
```

- **`main.dart`**: O ponto de entrada da aplicação.
- **`db/database_helper.dart`**: Gerencia a criação do banco de dados SQLite e as operações de CRUD (Create, Read, Update, Delete).
- **`model/`**: Contém os modelos de dados da aplicação:
    - `comida.dart`: Representa uma refeição a ser preparada.
    - `ingrediente.dart`: Representa um ingrediente necessário para uma `Comida`.
- **`repository/food_repository.dart`**: Abstrai a camada de dados, fornecendo uma API limpa para a interface do usuário (UI) interagir com os dados. Ele utiliza o `DatabaseHelper` para realizar as operações de persistência.
- **`ui/`**: Contém as telas da aplicação.
- **`providers/theme_provider.dart`**: Gerencia o tema da aplicação (claro/escuro).

## Estrutura de Dados

A aplicação utiliza dois modelos de dados principais:

### Comida

O modelo `Comida` representa uma refeição e contém os seguintes campos:

- `id`: Identificador único.
- `o_que_e_a_comida`: Nome da comida.
- `tipo_da_comida`: Categoria da comida (e.g., almoço, jantar).
- `dia_para_fazer`: Data em que a refeição deve ser preparada.
- `ingredientes_faltando`: Quantidade de ingredientes que ainda não foram adquiridos.
- `tem_todos_ingredientes`: Um booleano que indica se todos os ingredientes foram adquiridos.
- `ingredientes`: Uma lista de objetos `Ingrediente`.

### Ingrediente

O modelo `Ingrediente` representa um item necessário para uma `Comida` e possui os seguintes campos:

- `id`: Identificador único.
- `marcado`: Um booleano que indica se o ingrediente já foi adquirido.
- `nome`: Nome do ingrediente.
- `data_de_criacao`: Data em que o ingrediente foi adicionado.
- `data_de_aquisicao`: Data em que o ingrediente foi adquirido.
- `comida_id`: O ID da `Comida` a que este ingrediente pertence.

## Lógica e Fluxo de Dados

O fluxo de dados na aplicação segue o padrão de arquitetura em camadas:

1.  **UI (Interface do Usuário)**: As telas em `lib/ui/` são responsáveis por exibir os dados e capturar as interações do usuário. Quando uma ação que requer persistência de dados é acionada (e.g., adicionar uma nova comida), a UI chama os métodos do `FoodRepository`.

2.  **Repository (Repositório)**: O `FoodRepository` em `lib/repository/food_repository.dart` atua como uma ponte entre a UI e a fonte de dados. Ele expõe métodos assíncronos (retornando `Future`s) para as operações de dados, como `addComida()`, `getComidas()`, etc. O repositório utiliza o `DatabaseHelper` para executar as operações no banco de dados.

3.  **Database (Banco de Dados)**: O `DatabaseHelper` em `lib/db/database_helper.dart` lida diretamente com o banco de dados SQLite. Ele contém os métodos para executar as queries SQL de criação de tabelas e as operações de CRUD para os modelos `Comida` e `Ingrediente`.

Este fluxo garante uma separação clara de responsabilidades, tornando o código mais organizado, testável e fácil de manter.

## Gerenciamento de Estado

O aplicativo utiliza o pacote `provider` para o gerenciamento de estado. A escolha pelo `provider` se deu por sua simplicidade e por ser a abordagem recomendada pelo Google para o gerenciamento de estado em aplicações Flutter.

O `Provider` conecta o `Repository` à `UI` da seguinte forma:

1.  **`FoodProvider` e `IngredientProvider`**: Essas classes estendem `ChangeNotifier` e são responsáveis por manter o estado da lista de comidas e ingredientes, respectivamente.
2.  **Interação com o Repositório**: Os `Providers` utilizam o `FoodRepository` para buscar e manipular os dados no banco de dados.
3.  **Notificação da UI**: Quando os dados são alterados (e.g., uma nova comida é adicionada), o `Provider` chama o método `notifyListeners()`, que notifica os widgets que estão ouvindo (usando `Consumer` ou `Provider.of()`) para que eles se reconstruam e exibam os dados atualizados.

## Navegação

O aplicativo utiliza rotas nomeadas para a navegação entre as telas. As rotas são definidas no arquivo `lib/main.dart`:

-   `/`: Rota inicial, que leva à `FoodListScreen`.
-   `/new-food`: Rota para a `NewFoodScreen`, que é utilizada tanto para criar uma nova comida quanto para editar uma existente.

Para passar o ID da comida para a tela de edição, o `Navigator.pushNamed()` é utilizado com o argumento `arguments`:

```dart
Navigator.pushNamed(context, '/new-food', arguments: food.id);
```

Na `NewFoodScreen`, o ID é recuperado usando `ModalRoute.of(context)?.settings.arguments`. Se o ID não for nulo, a tela entra em modo de edição e carrega os dados da comida correspondente.

## Como Executar o Projeto

Para executar este projeto, você precisará ter o Flutter instalado.

1.  Clone o repositório:
    ```bash
    git clone https://github.com/joashneves/app-check-food.git
    ```
2.  Navegue até o diretório do projeto:
    ```bash
    cd app-check-food.git
    ```
3.  Instale as dependências:
    ```bash
    flutter pub get
    ```
4.  Execute a aplicação:
    ```bash
    flutter run
    ```

## Testes

Para garantir a corretude da lógica de persistência de dados, foi criado um teste que valida a inserção e leitura de dados no banco de dados. O teste, localizado em `test/database_test.dart`, funciona da seguinte maneira:

1.  **Inicialização**: O ambiente de teste é configurado para usar o `sqflite_common_ffi` para executar o banco de dados em memória.
2.  **Criação de Dados**: Uma instância de `Comida` é criada com uma lista de `Ingredientes` de exemplo.
3.  **Inserção**: O objeto `Comida` e seus `Ingredientes` são inseridos no banco de dados através do `FoodRepository`.
4.  **Leitura**: Os dados recém-inseridos são lidos do banco de dados.
5.  **Verificação**: O teste verifica se os dados lidos são idênticos aos dados que foram inseridos, garantindo que a persistência está funcionando corretamente.

Para executar os testes, utilize o seguinte comando:

```bash
flutter test test/database_test.dart
```

# Demostração

![TrabalhoGif](./docs/trabalho.GIF)