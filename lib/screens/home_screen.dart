import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waste_model.dart';
import '../widgets/waste_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalPoin = 0;
  double opacity = 0;
  bool _loading = true;

  int selectedNavIndex = 0;

  bool isGrid = false;

  // SEARCH
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<WasteModel> wasteList = [
    WasteModel(
      name: 'Plastik',
      description:
          'Sampah plastik dapat didaur ulang menjadi botol, tas belanja, atau bahan bangunan ringan. Bersihkan sebelum disetor.',
      points: 100,
      icon: Icons.local_drink,
      color: Colors.pinkAccent,
    ),
    WasteModel(
      name: 'Organik',
      description:
          'Sampah organik seperti daun dan sisa makanan bisa dijadikan kompos alami untuk menyuburkan tanah.',
      points: 40,
      icon: Icons.grass,
      color: Colors.green,
    ),
    WasteModel(
      name: 'Kaca',
      description:
          'Kaca bekas dapat dilebur ulang untuk membuat botol baru atau digunakan sebagai dekorasi; pisahkan dari keramik.',
      points: 80,
      icon: Icons.lightbulb,
      color: Colors.teal,
    ),
    WasteModel(
      name: 'Logam',
      description:
          'Logam seperti kaleng dan besi bisa dilebur kembali untuk membuat produk baru dan menghemat sumber daya.',
      points: 150,
      icon: Icons.settings,
      color: Colors.orange,
    ),
  ];

  final List<String> recycleTips = [
    "Gunakan botol minum isi ulang agar mengurangi limbah plastik 🌿",
    "Pisahkan sampah organik dan anorganik sejak dari rumah 🏡",
    "Gunakan kembali kardus bekas sebagai tempat penyimpanan 📦",
    "Cuci bersih botol plastik sebelum didaur ulang 💧",
    "Kurangi penggunaan kantong plastik sekali pakai 🌎",
  ];

  @override
  void initState() {
    super.initState();
    _loadPoints();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      setState(() => opacity = 1);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        totalPoin = prefs.getInt('totalPoin') ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        totalPoin = 0;
        _loading = false;
      });
    }
  }

  Future<void> _savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalPoin', totalPoin);
  }

  void _addPoints(int extra, {String? snackMsg}) {
    setState(() {
      totalPoin += extra;
    });
    _savePoints();
    if (snackMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snackMsg)));
    }
  }

  List<WasteModel> get _filteredWasteList {
    if (_searchQuery.isEmpty) return wasteList;
    final q = _searchQuery.toLowerCase();
    return wasteList.where((w) {
      final name = w.name.toLowerCase();
      final desc = w.description.toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  // Pilih Jenis Sampah
  void _showAddWasteModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, -3)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Pilih Jenis Sampah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: wasteList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final wt = wasteList[index];
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: wt.color, child: Icon(wt.icon, color: Colors.white)),
                            title: Text(wt.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const SizedBox(height: 4),
                              Text(wt.description, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
                              const SizedBox(height: 8),
                              Text('${wt.points} poin / kg', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                            ]),
                            isThreeLine: true,
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showWeightDialog(wt);
                              },
                              child: const Text('Pilih'),
                              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWeightDialog(WasteModel wt) {
    final qtyController = TextEditingController(text: '100');
    String unit = 'g';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSB) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text('Tambah ${wt.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Poin: ${wt.points} poin per kg'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Berat', hintText: 'Masukkan berat (contoh: 250)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: unit,
                      items: const [
                        DropdownMenuItem(value: 'g', child: Text('g')),
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                      ],
                      onChanged: (v) => setSB(() => unit = v ?? 'g'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerLeft, child: Text('Contoh: 250 g atau 0.5 kg', style: TextStyle(color: Colors.grey[700]))),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () {
                  final raw = double.tryParse(qtyController.text.replaceAll(',', '.')) ?? 0;
                  final weightKg = (unit == 'g') ? (raw / 1000.0) : raw;
                  final pointsPerKg = wt.points.toDouble();
                  final earnedDouble = pointsPerKg * weightKg;
                  final earned = earnedDouble.round();
                  if (earned <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan berat valid (>0).')));
                    return;
                  }
                  _addPoints(earned, snackMsg: 'Berhasil: +$earned poin untuk ${wt.name} (${raw.toString()} $unit)');
                  Navigator.of(context).pop();
                },
                child: const Text('Konfirmasi'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = selectedNavIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedNavIndex = index;
        });
      },
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: isActive ? Colors.green : Colors.grey),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: isActive ? Colors.green : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tip = (List.of(recycleTips)..shuffle()).first;

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2FFF0),
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          elevation: 0,
          title: const Text('Bank Sampah Kita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),

        body: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 350),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari jenis sampah atau deskripsi...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 14),
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Card(
                color: Colors.green[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total Poin Kamu', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(height: 6),
                      Text('$totalPoin Poin', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                    ]),
                    const Icon(Icons.emoji_events, color: Colors.orange, size: 48),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Listview/Gridview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeInLeft(duration: const Duration(milliseconds: 500), child: const Text('Jenis Sampah', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))),
                // Toggle button
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() => isGrid = false);
                      },
                      icon: Icon(Icons.view_list, color: isGrid ? Colors.grey : Colors.green),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => isGrid = true);
                      },
                      icon: Icon(Icons.grid_view, color: isGrid ? Colors.green : Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_filteredWasteList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text('Tidak ada hasil untuk "$_searchQuery"', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else if (!isGrid)
              // LIST MODE
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredWasteList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final waste = _filteredWasteList[index];
                  return FadeInUp(duration: Duration(milliseconds: 400 + (index * 120)), child: WasteCard(waste: waste, isGrid: false));
                },
              )
            else
              // GRID MODE
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredWasteList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final waste = _filteredWasteList[index];
                  return FadeInUp(duration: Duration(milliseconds: 350 + (index * 120)), child: WasteCard(waste: waste, isGrid: true));
                },
              ),

            const SizedBox(height: 20),
            FadeIn(
              duration: const Duration(milliseconds: 600),
              child: Card(
                color: Colors.lightGreen[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(children: [const Icon(Icons.tips_and_updates, color: Colors.green, size: 36), const SizedBox(width: 12), Expanded(child: Text(tip, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)))]),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FadeInUp(
          duration: const Duration(milliseconds: 700),
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
            onPressed: _showAddWasteModal,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.white,
          elevation: 10,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home, "Home", 0),
                _navItem(Icons.history, "Riwayat", 1),
                const SizedBox(width: 40),
                _navItem(Icons.person, "Profil", 2),
                _navItem(Icons.settings, "Setting", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
