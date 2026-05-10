import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../core/constants/app_theme.dart';
import 'active_task_screen.dart';
import 'done_task_screen.dart';
import 'profile_screen.dart';
import '../../widgets/task_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  // Palet Warna dari AppTheme
  final Color navyBlue = AppTheme.primary;
  final Color softPink = AppTheme.secondary;
  late PageController _pageController;
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    // Memanggil data task pertama kali saat layar utama dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().refreshTasks();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(index);
  }

  void _onTabChanged() {
    _pageController.animateToPage(
      _tabController.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan TabController untuk sync antara TabBar dan PageView
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // Menggantikan AppBarLayout dan Toolbar
      appBar: AppBar(
        backgroundColor: navyBlue,
        elevation: 0,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Agenda Kuliah',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kelola tugas harianmu dengan lebih rapi',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),

        // Menggantikan TabLayout
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _onTabChanged(),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.check_circle_outline), text: "Aktif"),
            Tab(icon: Icon(Icons.done_all_rounded), text: "Selesai"),
            Tab(icon: Icon(Icons.person_outline_rounded), text: "Profil"),
          ],
        ),
      ),

      // Menggantikan ViewPager content dengan PageView untuk smooth animation
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          ActiveTaskScreen(), // Urutan 1: Menampilkan daftar tugas aktif
          DoneTaskScreen(), // Urutan 2: Menampilkan daftar tugas selesai
          ProfileScreen(), // Urutan 3: Menampilkan halaman profil user
        ],
      ),

      // Mengatur 2 FloatingActionButton seperti di CoordinatorLayout
      floatingActionButton: _currentIndex < 2
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // FAB 1: Switch Layout (List/Grid) - Hanya di tab Aktif dan Selesai
                Consumer<TaskViewModel>(
                  builder: (context, taskViewModel, child) {
                    return FloatingActionButton(
                      heroTag: "btn_switch",
                      backgroundColor: navyBlue,
                      elevation: 8,
                      mini: true,
                      onPressed: () {
                        taskViewModel.setLayoutMode(!taskViewModel.isGridView);
                      },
                      child: Icon(
                        taskViewModel.isGridView
                            ? Icons.view_list
                            : Icons.grid_view,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // FAB 2: Add Task - Hanya di tab Aktif dan Selesai
                FloatingActionButton(
                  heroTag: "btn_add",
                  backgroundColor: softPink,
                  elevation: 8,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const TaskDialog(),
                    );
                  },
                  child: const Icon(Icons.add, size: 28, color: Colors.black87),
                ),
              ],
            )
          : null,
    );
  }
}
