// lib/screens/my_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime_model.dart';
import '../models/my_list_item.dart';
import '../services/database_service.dart';
import '../widgets/status_badge.dart';
import '../theme.dart';
import 'detail_screen.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  late TabController _tabController;

  List<MyListItem> _allItems = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Semua', 'status': null},
    {'label': 'Watching', 'status': 'watching'},
    {'label': 'Completed', 'status': 'completed'},
    {'label': 'Watchlist', 'status': 'watchlist'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Memuat semua data dari SQLite ───────────────────────────────────────
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await _db.getAllAnime();
    setState(() {
      _allItems = items;
      _isLoading = false;
    });
  }

  List<MyListItem> _filtered(String? status) {
    if (status == null) return _allItems;
    return _allItems.where((i) => i.status == status).toList();
  }

  // ─── Hapus item dari database ────────────────────────────────────────────
  Future<void> _deleteItem(MyListItem item) async {
    await _db.deleteAnime(item.id!);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.title}" dihapus dari list'),
          backgroundColor: AppColors.midBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Oke',
            textColor: AppColors.paleBlue,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softWhite,
      appBar: AppBar(
        title: const Text('My List'),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: AppColors.pureWhite,
        titleTextStyle: GoogleFonts.raleway(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.pureWhite,
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.accentGlow,
          indicatorWeight: 3,
          labelColor: AppColors.pureWhite,
          unselectedLabelColor: AppColors.paleBlue,
          labelStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: _tabs.map((t) {
            final count = _filtered(t['status']).length;
            return Tab(
              child: Row(
                children: [
                  Text(t['label']),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentGlow.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ]
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.lightBlue))
          : TabBarView(
              controller: _tabController,
              children: _tabs.map((t) {
                final items = _filtered(t['status']);
                if (items.isEmpty) return _buildEmpty();
                return _buildList(items);
              }).toList(),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.collections_bookmark_outlined,
              size: 64, color: AppColors.paleBlue),
          const SizedBox(height: 14),
          Text(
            'Belum ada anime di sini',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.lightBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cari anime di halaman utama\nlalu tambahkan ke listmu!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppColors.paleBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<MyListItem> items) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.lightBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: items.length,
        itemBuilder: (_, index) => _buildListCard(items[index]),
      ),
    );
  }

  Widget _buildListCard(MyListItem item) {
    return Dismissible(
      key: Key('item_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded,
            color: Colors.white, size: 26),
      ),
      onDismissed: (_) => _deleteItem(item),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final anime = Anime(
              malId: item.malId,
              title: item.title,
              imageUrl: item.imageUrl,
              score: item.score,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(anime: anime)),
            ).then((_) => _loadData());
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.lightBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: Image.network(
                item.imageUrl,
                height: 100,
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  width: 70,
                  color: AppColors.iceBlue,
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.raleway(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(status: item.status),
                    if (item.note != null && item.note!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppColors.lightBlue,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'Ditambahkan ${_formatDate(item.addedAt)}',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: AppColors.paleBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Swipe hint
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.paleBlue),
            ),
          ],
        ),
      ), // Container
      ), // InkWell
      ), // Material
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '-';
    }
  }
}
