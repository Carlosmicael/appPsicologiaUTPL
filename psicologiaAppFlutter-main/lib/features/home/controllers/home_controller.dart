import 'package:get/get.dart';
import 'package:psicologia_app_liid/features/auth/login/login_form_provider.dart' as login;
import 'package:psicologia_app_liid/features/auth/register/register_user.dart' as register;
import 'package:psicologia_app_liid/features/home/views/estres/activity_three/ResumenEjercicioEE.dart';
import 'package:psicologia_app_liid/features/home/views/estres/activity_two/ResumenEjercicio.dart';
import '../views/Cuestionario_Entrada.dart';
import '../views/Tematicas.dart';
import '../views/Complete_Cuestionario.dart';
import '../views/revision.dart';
import '../views/Menu.dart';
import '../views/estres/activity_one/Tecnicas.dart';
import '../views/Logros.dart';
import '../views/PantallaCarga.dart';
import '../views/loadingTematicas.dart';
import '../views/loadingMenu.dart';
import '../views/estres/activity_two/EjercicioGratitud.dart';
import '../views/estres/activity_one/Estadistica.dart';
import '../views/estres/activity_three/EscrituraExpresiva.dart';
import 'dart:async';

class HomeController extends GetxController {
  bool delay = true;


  //causa del error//
  void goToInicioSesion() async {
    print("Redirigiendo a Inicio de secion");
    if (delay) await Future.delayed(const Duration(seconds: 2));
    delay=false;
    Get.offAll(() => const login.Intermediario(),transition: Transition.fade,duration: const Duration(milliseconds: 500));
  }

  void goToRegistro() {
    Get.to(() => const register.RegistroUsuario(), 
      transition: Transition.fade, 
      duration: const Duration(milliseconds: 500),
    );
  }

  void goToTematicasP() {
    print("Redirigiendo a Temáticas");
    Get.offAll(() => const Tematicas_P(),transition: Transition.fade,duration: const Duration(milliseconds: 500),
    );
  }

  void goToCuestionario(String categoryId) {
    Get.to(() => PantallaCuestionario(categoryId: categoryId),
      transition: Transition.fade, 
      duration: const Duration(milliseconds: 500),
    );
  }

  void goToComplete(int totalScore, String categoryId) {
    Get.offAll(() => Complete(totalScore: totalScore, categoryId: categoryId),
        transition: Transition.upToDown,
        duration: const Duration(milliseconds: 500));
  }


  //otro error identificado
  void goToInforme(String categoryId) {
    Get.offAll(() => PantallaInforme(categoryId: categoryId),
        transition: Transition.circularReveal,
        duration: const Duration(milliseconds: 1000));
  }

  void goToMenu(String categoryId) {
    Get.to(() => Menu(categoryId: categoryId));
  }

  void goToT1(String categoryId, String methodId) {
    print(categoryId);
    print("controladorrrrrrrrrrrrrrrrr");
    Get.to(() => Tecnicas(categoryId: categoryId.toLowerCase(), methodId: methodId.toLowerCase(),categoryIdNormal:categoryId),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 500)); 
  }

  void goToEstadistica(String categoryId, String methodId){
    Get.off(()=> ResumenEjercicioScreen(categoryId: categoryId.toLowerCase(), methodId: methodId.toLowerCase()), transition: Transition.downToUp, duration: const Duration(milliseconds: 1000));
  }

  void goToLogros(String categoryId, String methodId) {
    Get.to(
      () => LogrosScreen(categoryId: categoryId, methodId: methodId),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 1000),
    );
  }


  void goToResumenGratitud(String categoryId, String methodId) {
    Get.off(
      () => ResumenGratitudScreen(
        categoryId: categoryId,
        methodId: methodId,
      ),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void goToEjercicioG(String categoryId, String methodId){
    Get.to(() => GratitudScreen(categoryId: categoryId.toLowerCase(), methodId: methodId.toLowerCase()),transition: Transition.zoom,duration: const Duration(microseconds: 1000));
  }

  void goToResumenExpresiva(String categoryId, String methodId , String categoryIdNormal) {
    Get.to(() => ResumenExpresivaScreen(categoryId: categoryId, methodId: methodId,categoryIdNormal:categoryIdNormal),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void goToEspresivo(String categoryId, String methodId){
    Get.to(()=> EscrituraExpresivaScreen(categoryId: categoryId.toLowerCase(), methodId: methodId.toLowerCase(),categoryIdNormal:categoryId),transition: Transition.zoom,duration: const Duration(microseconds: 1000));
  }

  void goToCarga() async {
    delay = false;
    Get.offAll(() => const PantallaCarga(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
    await Future.delayed(const Duration(seconds: 5));
    goToInicioSesion();
  }
  void goToTema() async {
    Get.offAll(() => const loadingCarga(), transition: Transition.fade, duration: const Duration(milliseconds: 100));
    await Future.delayed(const Duration(seconds: 1));
    goToTematicasP();
  }
  void goToMennu(String categoryId) async {
    Get.offAll(() => const loadingMe(), transition: Transition.fade, duration: const Duration(milliseconds: 100));
    await Future.delayed(const Duration(seconds: 2));
    goToMenu(categoryId);
  }


}


















