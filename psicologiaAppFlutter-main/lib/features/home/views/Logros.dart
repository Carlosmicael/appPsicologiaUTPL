import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:psicologia_app_liid/presentation/blocs/notifications/notifications_bloc.dart';
import '../controllers/home_controller.dart';
import '../controllers/controller_services.dart';

class LogrosScreen extends StatefulWidget {
  final String categoryId;
  final String methodId;

  const LogrosScreen({
    super.key,
    required this.categoryId,
    required this.methodId,
  });

  @override
  LogrosScreenState createState() => LogrosScreenState();
}

class LogrosScreenState extends State<LogrosScreen> {
  final HomeController homeController = Get.find<HomeController>();
  final ControllerServices service = Get.find<ControllerServices>();
  bool _hasShownReminderSnackBar = false;


  TimeOfDay? selectedTime;
  DateTime? selectedDateTime;
  String selectedFrequency = "Diariamente";
  List<int> selectedDays = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4475D5), Color(0x8C61C6FF), Color(0xFF3D496F)],
            stops: [0.0, 0.53, 1.0],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
          future: service.getTechniqueAchievements(widget.methodId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error al cargar los logros', style: TextStyle(color: Colors.white)),
              );
            }

            final data = snapshot.data ?? {};
            final completados = List<String>.from(data["completados"] ?? []);
            final desafios = List<String>.from(data["desafios"] ?? []);
            final int puntosTotales = data["puntos"] ?? 0;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          onPressed: () {Get.back();},
                        ),
                        const Spacer(),
                        const Text(
                          'LOGROS',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.white),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "🎖️ Total de puntos ganados: $puntosTotales",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  const SizedBox(height: 20),
                  _buildAchievementsSection('✅ Ejercicios Completados', completados),
                  const SizedBox(height: 20),
                  _buildAchievementsSection('⚡ Desafíos Logrados', desafios),
                  const SizedBox(height: 30),
                  _buildReminderSection(widget.categoryId,widget.methodId),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      homeController.goToMenu(widget.categoryId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('MENÚ', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        )
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(String title, List<String> achievements) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: achievements.isNotEmpty
                  ? achievements.map((e) => Text('- $e', style: const TextStyle(fontSize: 16, color: Colors.black))).toList()
                  : [const Text('No hay logros aún.', style: TextStyle(fontSize: 16, color: Colors.black))],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection(String catego,String meto) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            const Text(
              '📅 RECORDATORIO',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFrequencyButton("Diariamente"),
                _buildFrequencyButton("Semanal"),
                _buildFrequencyButton("Personalizado"),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Fecha y Hora", style: TextStyle(fontSize: 18, color: Colors.black)),
                      GestureDetector(
                        onTap: _pickDateTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedDateTime == null
                                ? "Seleccionar"
                                : "${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} "
                                "${selectedDateTime!.hour}:${selectedDateTime!.minute}",
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (selectedFrequency == "Personalizado") _buildDaySelection(),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                _scheduleNotification(catego, meto);
              },
              child: const Text("Guardar Recordatorio"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyButton(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFrequency = text;
          if (text != "Personalizado") {
            selectedDays.clear();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: selectedFrequency == text ? Colors.blue : Colors.white),
          borderRadius: BorderRadius.circular(10),
          color: selectedFrequency == text ? Colors.blue[300] : Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(color: selectedFrequency == text ? Colors.white : Colors.white70, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDaySelection() {
    return Column(
      children: [
        const Text("Selecciona los días:", style: TextStyle(fontSize: 18, color: Colors.black)),
        Wrap(
          spacing: 5,
          children: List.generate(7, (index) {
            final daysOfWeek = ["L", "M", "X", "J", "V", "S", "D"];
            final dayIndex = index + 1;
            final isSelected = selectedDays.contains(dayIndex);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedDays.remove(dayIndex);
                  } else {
                    selectedDays.add(dayIndex);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  daysOfWeek[index],
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _pickDateTime() async {
    DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? now),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });

        // Mostrar SnackBar después de que se haya elegido correctamente la fecha y hora
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar( // Remueve 'const' aquí porque el contenido ya no es constante
            content: CustomAnimatedSnackBar(
              message: '🕒 No olvides guardar tu recordatorio antes de salir.',
              icon: Icons.save_alt_rounded,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              actionButton: TextButton(
                onPressed: () {ScaffoldMessenger.of(context).hideCurrentSnackBar();},
                child: const Text(
                  'Okey',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
        );
      }
    }
  }


  void _scheduleNotification(String catego,String meto) async {
    if (selectedDateTime != null) {
      final state = context.read<NotificationsBloc>().state;
      String id = 'las tecnicas';
      print(meto);
      if(meto == 'tecnica1'){
        id = '🤸‍♀️ Estiramientos 🧘';
      }else if (meto == 'tecnica2'){
        id = '✍️💖 Escritura de gratitud';
      }else if(meto == 'tecnica3'){
        id = '📝✨ Escritura Expresiva';
      }
      String notificationTitle = "😥 Recordatorio tienes una cita pendiente en la tematica $catego";
      String notificationBody = "Hola estas preparado para regresar tu ejercicio de $id esta listo para ti";

      if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
        notificationTitle = state.notifications.first.title;
        notificationBody = state.notifications.first.body;
      }

      await service.saveUserNotification(
        dateTime: selectedDateTime!,
        title: notificationTitle,
        body: notificationBody,
        frequency: selectedFrequency,
        selectedDays: selectedDays,
      );

      context.read<NotificationsBloc>().add(
        ScheduleNotification(
          date: selectedDateTime!,
          time: TimeOfDay(hour: selectedDateTime!.hour, minute: selectedDateTime!.minute),
          title: notificationTitle,
          body: notificationBody,
          frequency: selectedFrequency,
          selectedDays: selectedDays.isEmpty ? null : selectedDays,
        ),
      );

      Get.snackbar("Recordatorio Guardado", "Notificación programada: $notificationTitle - $notificationBody");
    } else {
      Get.snackbar("Error", "Selecciona una fecha y hora primero.");
    }
  }

}






class CustomAnimatedSnackBar extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Widget? actionButton;

  const CustomAnimatedSnackBar({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor = const Color(0xFF3D496F),
    this.textColor = Colors.white,
    this.actionButton, // Lo incluimos en el constructor
  });

  @override
  _CustomAnimatedSnackBarState createState() => _CustomAnimatedSnackBarState();
}

class _CustomAnimatedSnackBarState extends State<CustomAnimatedSnackBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: widget.textColor.withOpacity(0.5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.textColor.withOpacity(0.8),
                size: 24,
              ),
              const SizedBox(width: 15),
              Flexible(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              if (widget.actionButton != null) ...[
                const SizedBox(width: 15),
                widget.actionButton!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}