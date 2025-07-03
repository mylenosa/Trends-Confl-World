# TrendsConflictsWorld

**TrendsConflictsWorld** é um aplicativo móvel e web desenvolvido em Flutter para monitorar, analisar e salvar eventos de conflito global. Utilizando dados em tempo real da [API pública ACLED](https://acleddata.com/), o aplicativo permite que usuários explorem conflitos por país, favoritem eventos de interesse e adicionem anotações pessoais.

## Funcionalidades Principais

- **Autenticação Segura:** Cadastro e login de usuários com E-mail/Senha, gerenciado pelo Firebase Authentication.
- **Busca de Conflitos:** Interface para buscar eventos de conflito por país e palavra-chave, consultando diretamente a API ACLED.
- **Mapa Interativo:** Visualização geoespacial dos eventos em um mapa interativo, com marcadores para cada conflito.
- **Watchlist Pessoal:** Os usuários podem favoritar eventos para criar uma "watchlist" pessoal para acompanhamento.
- **Anotações por Evento:** Cada evento na watchlist permite que o usuário adicione múltiplos comentários ou anotações, que ficam isolados e vinculados apenas àquele evento.

## Arquitetura e Tecnologias

O projeto foi construído seguindo uma arquitetura limpa e escalável, com uma clara separação de responsabilidades.

- **Framework:** Flutter 3.x
- **Gerenciamento de Estado:** GetX (seguindo o padrão MVC)
- **Backend (BaaS):** Firebase
  - **Firebase Authentication:** Para gerenciamento de usuários.
  - **Cloud Firestore:** Para armazenamento da watchlist e das anotações dos usuários.
- **API de Dados:** ACLED (Armed Conflict Location & Event Data Project)
- **Mapas:**
  - **flutter_map:** Para a renderização do mapa no aplicativo.
  - **Mapbox:** Para o fornecimento dos tiles (mapa base).

### Estrutura do Projeto

O código está organizado da seguinte forma:

- `lib/app/controllers`: Contém a lógica de negócio e o estado da aplicação (ex: `AuthController`, `EventController`).
- `lib/app/ui/pages`: Contém os widgets que compõem as telas do aplicativo.
- `lib/app/routes`: Define as rotas de navegação.
- `lib/app/bindings`: Centraliza a inicialização das dependências (controladores).
- `lib/app/data/providers`: Isola a camada de acesso a dados externos (API ACLED).

## Como Executar o Projeto

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/SEU-USUARIO/trendsconflictsworld.git
    cd trendsconflictsworld
    ```

2.  **Configure o Firebase:**
    - Crie um novo projeto no [console do Firebase](https://console.firebase.google.com/).
    - Ative o **Authentication** (com o provedor "E-mail/Senha").
    - Ative o **Cloud Firestore**.
    - Configure seu projeto para Flutter usando o [FlutterFire CLI](https://firebase.flutter.dev/docs/cli):
      ```bash
      flutterfire configure
      ```
    - Isso irá gerar o arquivo `lib/firebase_options.dart`.

3.  **Configure as Chaves de API:**
    - **ACLED:** Abra o arquivo `lib/app/data/providers/acled_provider.dart` e substitua os placeholders `_apiKey` e `_apiUser` pelas suas credenciais da API ACLED.
    - **Mapbox:** Abra o arquivo `lib/app/ui/pages/map_page.dart` e substitua o placeholder `YOUR_MAPBOX_ACCESS_TOKEN` pelo seu token de acesso do Mapbox.

4.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

5.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

## Backlog e Próximos Passos

- [ ] **Reimplementar Login com Google:** Restaurar a funcionalidade de login com Google, garantindo a estabilidade na plataforma web.
- [ ] **Ativar Notificações Push (FCM):** Fazer o deploy da Cloud Function (requer o plano Blaze do Firebase) para que o backend possa enviar notificações sobre novos eventos nos países da watchlist do usuário.
- [ ] **Cache Offline:** Reavaliar a implementação de um cache offline (com Hive ou Isar) de forma a não gerar conflitos com o estado da aplicação.
