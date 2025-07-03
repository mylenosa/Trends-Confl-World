import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'watchlist_controller.dart';
import 'auth_controller.dart';

/// ## EventDetailsController
/// Gerencia o estado e a lógica de uma **única** página de detalhes de evento.
///
/// Uma nova instância deste controlador é criada para cada página de detalhes
/// visitada e destruída quando a página é fechada. Isso garante que o estado,
/// como as anotações de um evento, não vaze para outro.
class EventDetailsController extends GetxController {
  // Encontra os controladores globais que já foram inicializados.
  final WatchlistController watchlistController = Get.find();
  final AuthController authController = Get.find();

  // Estado específico desta instância da página.
  late final Map<String, dynamic> event;
  late final String eventId;
  
  // Assinatura do stream de notas, para ser cancelada quando o controlador for destruído.
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notesSubscription;
  /// Lista reativa de anotações para o evento atual.
  final RxList<Map<String, dynamic>> notes = <Map<String, dynamic>>[].obs;
  /// Estado reativo para controlar o carregamento das notas.
  final RxBool isLoadingNotes = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Obtém os dados do evento passados como argumento na navegação.
    final rawEvent = Get.arguments as Map;
    event = Map<String, dynamic>.from(rawEvent);

    // Usa o ID do documento da watchlist, que é mais confiável.
    final idFromWatchlist = event['id']?.toString();
    if (idFromWatchlist == null) {
      isLoadingNotes.value = false;
      return;
    }
    eventId = idFromWatchlist;
    
    // Inicia a escuta do stream de anotações para este evento.
    _subscribeToNotes();
  }

  /// Inscreve-se no stream de notas do Firestore.
  void _subscribeToNotes() {
    isLoadingNotes.value = true;
    _notesSubscription = watchlistController.fetchNotesStream(eventId).listen(
      (snapshot) {
        notes.value = snapshot.docs.map((doc) => doc.data()).toList();
        isLoadingNotes.value = false;
      },
      onError: (error) {
        isLoadingNotes.value = false;
      },
    );
  }

  /// Chamado pelo GetX quando o controlador é removido da memória.
  /// Essencial para cancelar a assinatura do stream e evitar vazamentos de memória.
  @override
  void onClose() {
    _notesSubscription?.cancel();
    super.onClose();
  }
}
