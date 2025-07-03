import 'package:get/get.dart';
import '../data/providers/acled_provider.dart';

/// ## EventController
/// Responsável por gerenciar o estado dos eventos de conflito.
/// Este controlador lida com a busca de eventos da API ACLED e mantém a lista
/// de eventos exibida na tela principal.
class EventController extends GetxController {
  // Provedor para acessar a API ACLED.
  final AcledProvider _acledProvider = AcledProvider();

  /// Lista reativa de eventos. A UI observa esta lista para atualizações.
  final RxList<dynamic> events = <dynamic>[].obs;
  /// Estado reativo para controlar a exibição de indicadores de carregamento.
  final RxBool isLoading = false.obs;
  /// Parâmetros de busca reativos, vinculados aos campos de texto da UI.
  final RxString country = ''.obs;
  final RxString keyword = ''.obs;

  /// Busca eventos da API ACLED com base nos filtros atuais.
  ///
  /// Ativa o estado de `isLoading` durante a chamada da API e atualiza a lista
  /// `events` com os resultados. Em caso de erro, exibe um snackbar.
  void fetchEvents() async {
    isLoading.value = true;
    try {
      final response = await _acledProvider.getEvents(
        country: country.value,
        keyword: keyword.value,
      );
      events.value = response['data'] ?? [];
    } catch (e) {
      Get.snackbar('Erro na Busca', 'Não foi possível buscar os eventos: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
