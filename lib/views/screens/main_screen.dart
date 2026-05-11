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

      // Menggantikan AppBarLayout dan Toolbar dengan Design Profesional
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 100,
        title: Container(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon visual untuk header
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: softPink.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: softPink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Judul dan Subtitle di samping icon
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agenda Kuliah',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola tugas harianmu dengan lebih rapi',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),

        // Menggantikan TabLayout dengan design lebih modern
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => _onTabChanged(),
              indicatorColor: softPink,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.check_circle_outline), text: "Aktif"),
                Tab(icon: Icon(Icons.done_all_rounded), text: "Selesai"),
                Tab(icon: Icon(Icons.person_outline_rounded), text: "Profil"),
              ],
            ),
          ),
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
