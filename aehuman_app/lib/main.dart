import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/habit.dart';
import 'repositories/habits_repository.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  // Request permissions (Android 13+ via permission_handler)
  await Permission.notification.request();

  final habitsRepo = HabitsRepository(notificationService);
  await habitsRepo.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => habitsRepo),
      ],
      child: const AEHumanApp(),
    ),
  );
}

class AEHumanApp extends StatelessWidget {
  const AEHumanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Æ‑HUMAN',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A1A2E),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A1A2E)),
      ),
      home: const OnboardingScreen(),
    );
  }
}

/// Onboarding screen introducing the app
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Benvenuto in Æ‑HUMAN',
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Il tuo coach personale per vivere meglio ogni giorno.',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Color(0xFF00FF85)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Inizia il tuo percorso',
                      style: GoogleFonts.poppins(color: const Color(0xFF00FF85))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home screen showing overall progress, categories and navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsRepo = Provider.of<HabitsRepository>(context);
    final categories = _buildCategories();
    final completion = habitsRepo.completionPercentage;
    final motivationalQuotes = [
      'Ogni piccolo passo ti avvicina a una vita più sana 🔵',
      'La tua mente è più forte di qualsiasi ostacolo 🟠',
      'Rigenera il tuo cervello con una notte di sonno profondo 🟣',
      'Affronta lo stress con la forza del freddo 🟢',
      'La disciplina è la chiave per il tuo massimo potenziale 🟡',
      'Nutri il tuo cervello per chiarezza eterna 🔷',
    ];
    final quote = (motivationalQuotes..shuffle()).first;

    return Scaffold(
      appBar: AppBar(
        title: Text('Æ‑HUMAN',
            style: GoogleFonts.poppins(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white70),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progresso giornaliero: ${completion.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                        fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(quote,
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: const Color(0xFF00FF85))),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryScreen(
                                  categoryName: category['name'] as String),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(category['icon'] as String,
                                  style: const TextStyle(fontSize: 32)),
                              Text(category['name'] as String,
                                  style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: category['color'] as Color,
                                      fontWeight: FontWeight.w600)),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(category['payoff'] as String,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.white70),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Defines the categories of habits with UI attributes.
  List<Map<String, dynamic>> _buildCategories() {
    return [
      {
        'name': 'Sleep',
        'color': const Color(0xFF6B4EFF),
        'icon': '🟣',
        'payoff': 'Rigenera il cervello, estendi la vita'
      },
      {
        'name': 'Cold',
        'color': const Color(0xFF00FF85),
        'icon': '🟢',
        'payoff': 'Stress antico, resilienza moderna'
      },
      {
        'name': 'Longevity',
        'color': const Color(0xFF00B7EB),
        'icon': '🔵',
        'payoff': 'Allunga la salute, non solo la vita'
      },
      {
        'name': 'Performance',
        'color': const Color(0xFFFFD700),
        'icon': '🟡',
        'payoff': 'Energia e focus ogni giorno'
      },
      {
        'name': 'Brain',
        'color': const Color(0xFF4682B4),
        'icon': '🔷',
        'payoff': 'Neuroplasticità, memoria, chiarezza'
      },
      {
        'name': 'Resilience',
        'color': const Color(0xFFFF4500),
        'icon': '🟠',
        'payoff': 'Forza mentale contro stress e caos'
      },
    ];
  }
}

/// Screen for listing habits in a category
class CategoryScreen extends StatelessWidget {
  final String categoryName;
  const CategoryScreen({super.key, required this.categoryName});
  @override
  Widget build(BuildContext context) {
    final habitsRepo = Provider.of<HabitsRepository>(context);
    final habits = habitsRepo.habitsByCategory(categoryName);
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName,
            style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)])),
        child: ListView.builder(
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return Card(
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(habit.title,
                    style: GoogleFonts.poppins(color: Colors.white)),
                subtitle: Text(habit.evidence,
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 12)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => HabitDetailScreen(habit: habit)),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        habit.notify
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: habit.notify
                            ? const Color(0xFF00FF85)
                            : Colors.grey,
                      ),
                      onPressed: () {
                        habitsRepo.toggleNotification(habit);
                      },
                    ),
                    Checkbox(
                      value: habit.completed,
                      onChanged: (value) {
                        habitsRepo.toggleCompletion(habit);
                      },
                      activeColor: const Color(0xFF00FF85),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Detailed screen for a single habit, with editing options
class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});
  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final habitsRepo = Provider.of<HabitsRepository>(context, listen: false);
    final habit = widget.habit;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(habit.title, style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)])),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Categoria: ${habit.category}',
                  style: GoogleFonts.poppins(
                      fontSize: 18, color: const Color(0xFF00B7EB))),
              const SizedBox(height: 8),
              Text('Evidenza scientifica:',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              Text(habit.evidence,
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.alarm, color: Color(0xFF00FF85)),
                  const SizedBox(width: 8),
                  Text('Orario di notifica: ${habit.notificationTime}',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(habit.notificationTime.split(':')[0]),
                          minute: int.parse(habit.notificationTime.split(':')[1]),
                        ),
                      );
                      if (picked != null) {
                        final newTime =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        await habitsRepo.updateNotificationTime(habit, newTime);
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.repeat, color: Color(0xFF00FF85)),
                  const SizedBox(width: 8),
                  Text('Ripetizioni giornaliere: ${habit.timesPerDay}',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: () async {
                      final controller = TextEditingController(
                          text: habit.timesPerDay.toString());
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A2E),
                          title: Text('Quante volte al giorno?',
                              style: GoogleFonts.poppins(color: Colors.white)),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Numero di ripetizioni',
                              hintStyle:
                                  TextStyle(color: Colors.white54),
                            ),
                            style:
                                const TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Annulla'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final int times = int.tryParse(controller.text) ?? 1;
                                await habitsRepo.updateTimesPerDay(habit, times);
                                if (!mounted) return;
                                Navigator.pop(context);
                                setState(() {});
                              },
                              child: const Text('Salva'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Progressi di oggi:',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              Row(
                children: List.generate(habit.timesPerDay, (index) {
                  final done = index < habit.timesCompletedToday;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(done ? Icons.check_circle : Icons.circle_outlined,
                        color: done ? const Color(0xFF00FF85) : Colors.grey),
                  );
                }),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  habitsRepo.toggleCompletion(habit);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF85),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Segna completato',
                    style: GoogleFonts.poppins(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen showing statistics for each habit and category
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final habitsRepo = Provider.of<HabitsRepository>(context);
    final habits = habitsRepo.habits;
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Statistiche', style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)])),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Progresso totale: ${habitsRepo.completionPercentage.toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(
                    fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...habits.map((habit) {
              final progress =
                  (habit.timesCompletedToday / habit.timesPerDay) * 100;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.title,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF00FF85),
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF00FF85)),
                    ),
                    const SizedBox(height: 4),
                    Text('${progress.toStringAsFixed(0)}% completato',
                        style:
                            GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}