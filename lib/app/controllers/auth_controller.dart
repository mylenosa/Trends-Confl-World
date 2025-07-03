import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart'; // 1. Import AppRoutes

/// ## AuthController
/// Gerencia o estado de autenticação da aplicação, cuidando do login,
/// registro e logout do usuário. Serve como a única fonte da verdade para
/// o status de autenticação do usuário atual em todo o app.
class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Vincula a variável interna `user` ao stream do Firebase.
    user.bindStream(_auth.authStateChanges());
    // 2. CRITICAL FIX: Add the reactive worker to handle navigation.
    // This listener will automatically navigate the user when the auth state changes.
    ever(user, _setInitialScreen);
  }

  /// Navega o usuário para a tela apropriada com base no estado de login.
  void _setInitialScreen(User? user) {
    if (user == null) {
      // If the user is signed out, navigate to the Login page.
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      // If the user is signed in, navigate to the Home page.
      Get.offAllNamed(AppRoutes.HOME);
    }
  }

  /// Tenta fazer o login de um usuário com o e-mail e senha fornecidos.
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Navigation is handled by the `ever` worker in onInit.
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erro no Login', e.message ?? 'Ocorreu um erro desconhecido.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Tenta criar uma nova conta de usuário com o e-mail e senha fornecidos.
  Future<void> register(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Navigation is handled by the `ever` worker in onInit.
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erro no Cadastro', e.message ?? 'Ocorreu um erro desconhecido.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Desloga o usuário atual do Firebase.
  Future<void> logout() async {
    await _auth.signOut();
    // Navigation is handled by the `ever` worker in onInit.
  }
}
