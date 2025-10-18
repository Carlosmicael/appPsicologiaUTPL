import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:psicologia_app_liid/config/local_notifications/local_notifications.dart';
import 'package:psicologia_app_liid/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:psicologia_app_liid/features/home/controllers/home_controller.dart';
import 'package:psicologia_app_liid/features/home/controllers/controller_services.dart';
import 'package:psicologia_app_liid/features/home/controllers/controller_inicio.dart';
import 'package:psicologia_app_liid/shared/services/audio_player_service.dart';
import 'package:psicologia_app_liid/features/auth/login/login_form_provider.dart';
import 'package:psicologia_app_liid/features/home/views/Tematicas.dart';
import 'package:flutter/services.dart';



// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Notificación recibida en segundo plano: ${message.notification?.title}");
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  await initializeDateFormatting('es_ES', '');
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  WidgetsFlutterBinding.ensureInitialized();

  //este es el nuevo
  //nota eliminar todos los FlutterNativeSplash.remove(); de las clases solo dejarlo en el main.
  //FlutterNativeSplash.remove();

  // void _onNotificationTapped(NotificationResponse response) {
  //   print("Notificación tocada: ${response.payload}");
  // }

  // await LocalNotifications.initializeLocalNotifications(_onNotificationTapped);


  // --- COMIENZO DE LA MODIFICACIÓN PARA OCULTAR PANTALLA ROJA ---
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('*** ERROR CAPTURADO GLOBALMENTE (Pantalla Roja Suprimida) ***');
    debugPrint('Excepción: ${details.exception}');
    debugPrint('Stack Trace: ${details.stack}');

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.orange,
            size: 50,
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Ups! Estas entrando a funcionalidades no disponibles.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Si el problema persiste, contacta a soporte para regresar dale al boton.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {Get.back();},
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text(
              'Regresar Atrás',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4475D5),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  };

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await _requestNotificationPermission();

  Get.lazyPut<ControllerInicio>(() => ControllerInicio(), fenix: true);
  Get.put(ControllerServices(), permanent: true);
  Get.put<HomeController>(HomeController());
  Get.put<AudioService>(AudioService());


  runApp(MultiBlocProvider(
      providers: [BlocProvider(create: (_) => NotificationsBloc())],
      child: const MainApp()));
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      smartManagement: SmartManagement.keepFactory,
      home: AuthWrapper(),
    );
  }
}

/*class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('Usuario autenticado: ${snapshot.data!.uid}');
            homeController.goToTematicasP();
            });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('Usuario NO autenticado');
            homeController.goToInicioSesion();
          });
        }
        return SizedBox.fromSize();
      },
    );
  }
}*/



class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: Text("Esperando redirección...")),
          );
        }
        print('Inicio del AuthWrapper');
        final ControllerServices controllerServices = Get.find<ControllerServices>();
        controllerServices.verificarPermisoAlarmas(context);
        if (snapshot.hasData && snapshot.data != null) {
          print('Esperando conexión a Firebase...');
          return const Tematicas_P();
        } else {
          print('Usuario NO autenticado');
          return const Intermediario();
        }
      },
    );
  }
}


Future<void> _requestNotificationPermission() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  if (Platform.isAndroid) {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("Permiso de notificaciones denegado.");
    } else {
      print("Permiso de notificaciones concedido: ${settings.authorizationStatus}");
    }
  }
}



/*class PantallaDePrueba extends StatelessWidget {
  const PantallaDePrueba({super.key});
  @override
  Widget build(BuildContext context) {
    print("llegamos");
    FlutterNativeSplash.remove();
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          "✅ Pantalla de Prueba Renderizada",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}*/











