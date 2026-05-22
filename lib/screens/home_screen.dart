// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime_model.dart';
import '../services/jikan_service.dart';
import '../widgets/anime_card.dart';
import '../theme.dart';
import 'detail_screen.dart';
import 'my_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JikanService _jikanService = JikanService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Anime> _animeList = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _hasError = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTopAiring();
  }

  Future<void> _loadTopAiring() async {
    setState(() { _isLoading = true; _hasError = false; });
    try {
      final result = await _jikanService.getTopAiring();
      setState(() { _animeList = result; _isLoading = false; });
    } catch (_) {
      setState(() { _isLoading = false; _hasError = true; });
    }
  }

  Future<void> _searchAnime(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      _loadTopAiring();
      return;
    }
    setState(() {
      _isLoading = true;
      _isSearching = true;
      _hasError = false;
      _searchQuery = query;
    });
    try {
      final result = await _jikanService.searchAnime(query);
      setState(() { _animeList = result; _isLoading = false; });
    } catch (_) {
      setState(() { _isLoading = false; _hasError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softWhite,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.pureWhite,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.deepBlue, AppColors.midBlue],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 55, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'AnimeTracker',
                      style: GoogleFonts.raleway(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pureWhite,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Temukan & simpan anime favoritmu',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.paleBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyListScreen()),
                  ),
                  icon: const Icon(Icons.collections_bookmark_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.pureWhite,
                  ),
                  tooltip: 'My List',
                ),
              ),
            ],
          ),

          // ── Search Bar ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: _searchAnime,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari anime...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.lightBlue),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.lightBlue),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _isSearching = false);
                            _loadTopAiring();
                          },
                        )
                      : null,
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
          ),

          // ── Section Title ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isSearching
                        ? 'Hasil pencarian "$_searchQuery"'
                        : 'Top Airing Saat Ini',
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Grid Anime ────────────────────────────────────────────────────
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.lightBlue),
                  ),
                )
              : _hasError
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded,
                                size: 56, color: AppColors.paleBlue),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada koneksi internet',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.midBlue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Periksa koneksimu lalu coba lagi',
                              style: GoogleFonts.nunito(
                                  color: AppColors.lightBlue, fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _loadTopAiring,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Coba Lagi'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.midBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
              : _animeList.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 56, color: AppColors.paleBlue),
                            const SizedBox(height: 12),
                            Text(
                              'Anime tidak ditemukan',
                              style: GoogleFonts.nunito(
                                  color: AppColors.lightBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.58,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => AnimeCard(
                            anime: _animeList[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                    anime: _animeList[index]),
                              ),
                            ),
                          ),
                          childCount: _animeList.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
