import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

/// ## WatchlistController
/// Gerencia a "watchlist" (lista de favoritos) do usuário.
///
/// Este controlador é responsável por:
/// - Sincronizar a watchlist do usuário com o Firestore em tempo real.
/// - Adicionar e remover eventos da watchlist.
/// - Gerenciar as anotações associadas a cada evento na watchlist.
class WatchlistController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // O AuthController é a fonte da verdade para o estado do usuário.
  final AuthController _authController = Get.find();

  /// Lista reativa de eventos na watchlist, sincronizada com o Firestore.
  final RxList<Map<String, dynamic>> watchlist = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Reage às mudanças no estado de autenticação do usuário.
    ever(_authController.user, (User? user) {
      if (user != null) {
        // Se o usuário está logado, conecta a lista da UI ao stream do Firestore.
        // Esta é a única fonte da verdade para a watchlist.
        watchlist.bindStream(
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('watchlist')
              .snapshots()
              .map((snapshot) => snapshot.docs.map((doc) {
                    final data = doc.data();
                    // Adiciona o ID do documento ao mapa para fácil acesso posterior.
                    data['id'] = doc.id;
                    return data;
                  }).toList()),
        );
      } else {
        // Se o usuário desloga, limpa a lista.
        watchlist.clear();
      }
    });
  }

  /// Adiciona um evento à watchlist do usuário no Firestore.
  /// A UI será atualizada automaticamente pelo `bindStream`.
  void addToWatchlist(Map<String, dynamic> event) async {
    final user = _authController.user.value;
    if (user != null) {
      final eventId = event['event_id_cnty']?.toString();
      if (eventId == null || eventId.isEmpty) {
        Get.snackbar("Erro", "Não foi possível adicionar o evento por falta de um ID único.");
        return;
      }
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('watchlist')
          .doc(eventId)
          .set(event);
    }
  }

  /// Remove um evento da watchlist do usuário no Firestore.
  /// A UI será atualizada automaticamente pelo `bindStream`.
  void removeFromWatchlist(Map<String, dynamic> event) async {
    final user = _authController.user.value;
    if (user != null) {
      final eventId = event['id']?.toString();
      if (eventId == null) {
        Get.snackbar("Erro", "Não foi possível remover o evento por falta de ID.");
        return;
      }
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('watchlist')
          .doc(eventId)
          .delete();
    }
  }

  /// Adiciona uma nova nota/comentário a um evento específico na watchlist do usuário.
  void addNoteToEvent(String eventId, String note) {
    final user = _authController.user.value;
    if (user == null || user.email == null) return;

    _firestore
        .collection('users').doc(user.uid).collection('watchlist').doc(eventId).collection('notes')
        .add({'note': note, 'timestamp': FieldValue.serverTimestamp(), 'author': user.email});
  }
  
  /// Retorna um stream de notas para um evento específico da watchlist do usuário.
  /// Usado pela `EventDetailsPage` para exibir os comentários em tempo real.
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchNotesStream(String eventId) {
    final user = _authController.user.value;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('users').doc(user.uid).collection('watchlist').doc(eventId).collection('notes')
        .orderBy('timestamp', descending: true).snapshots();
  }
}
