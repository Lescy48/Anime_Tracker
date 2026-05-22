// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime_model.dart';
import '../models/my_list_item.dart';
import '../services/database_service.dart';
import '../services/jikan_service.dart';
import '../widgets/status_badge.dart';
import '../theme.dart';
import 'add_to_list_screen.dart';

class DetailScreen extends StatefulWidget {
  final Anime anime;

  const DetailScreen({super.key, required this.anime});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final DatabaseService _db = DatabaseService();
  final JikanService _jikan = JikanService();

  MyListItem? _savedItem;
  bool _loadingDb = true;

  // Data lengkap dari API (synopsis, genres, dll)
  late Anime _anime;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    _anime = widget.anime;
    _checkSavedStatus();
    // Kalau synopsis belum ada (dibuka dari My List), fetch dari API
    if (_anime.synopsis == null) {
      _fetchFullDetail();
    }
  }

  // ─── Fetch detail lengkap dari Jikan API ────────────────────────────────
  Future<void> _fetchFullDetail() async {
    setState(() => _loadingDetail = true);
    try {
      final full = await _jikan.getAnimeDetail(_anime.malId);
      if (mounted) setState(() { _anime = full; _loadingDetail = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingDetail = false);
      // Gagal fetch — tetap tampilkan data yang ada, tidak crash
    }
  }

  // ─── Cek apakah anime sudah disimpan di database lokal ──────────────────
  Future<void> _checkSavedStatus() async {
    final item = await _db.getAnimeByMalId(widget.anime.malId);
    setState(() {
      _savedItem = item;
      _loadingDb = false;
    });
  }

  // ─── Navigasi ke halaman tambah/edit list ────────────────────────────────
  Future<void> _goToAddList() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddToListScreen(
          anime: widget.anime,
          existingItem: _savedItem,
        ),
      ),
    );
    if (result == true) _checkSavedStatus();
  }

  // ─── Hapus dari list ─────────────────────────────────────────────────────
  Future<void> _removeFromList() async {
    if (_savedItem == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus dari List?',
            style: GoogleFonts.raleway(fontWeight: FontWeight.w700)),
        content:
            const Text('Anime ini akan dihapus dari daftar kamu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade400),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteAnime(_savedItem!.id!);
      setState(() => _savedItem = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari list'),
            backgroundColor: AppColors.midBlue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final anime = _anime;

    return Scaffold(
      backgroundColor: AppColors.softWhite,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.deepBlue,
            foregroundColor: AppColors.pureWhite,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred background
                  CachedNetworkImage(
                    imageUrl: anime.imageUrl,
                    fit: BoxFit.cover,
                    color: AppColors.deepBlue.withOpacity(0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                  // Poster centered
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: anime.imageUrl,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 200,
                            width: 140,
                            color: AppColors.midBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    anime.title,
                    style: GoogleFonts.raleway(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  if (anime.titleEnglish != null &&
                      anime.titleEnglish != anime.title)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        anime.titleEnglish!,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: AppColors.lightBlue,
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Stats row
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      if (anime.score != null)
                        _statChip(
                            Icons.star_rounded, '${anime.score}',
                            const Color(0xFFE8A800)),
                      if (anime.episodes != null)
                        _statChip(Icons.tv_rounded,
                            '${anime.episodes} Eps', AppColors.lightBlue),
                      if (anime.type != null)
                        _statChip(Icons.movie_creation_rounded,
                            anime.type!, AppColors.midBlue),
                      if (anime.status != null)
                        _statChip(Icons.circle_notifications_rounded,
                            anime.status!, AppColors.lightBlue),
                    ],
                  ),

                  // Genres
                  if (anime.genres.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: anime.genres
                          .map((g) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.iceBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.paleBlue),
                                ),
                                child: Text(g,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.midBlue,
                                    )),
                              ))
                          .toList(),
                    ),
                  ],

                  // Status in list
                  if (!_loadingDb && _savedItem != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.iceBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          StatusBadge(
                              status: _savedItem!.status, large: true),
                          const Spacer(),
                          if (_savedItem!.note != null &&
                              _savedItem!.note!.isNotEmpty)
                            Expanded(
                              flex: 2,
                              child: Text(
                                _savedItem!.note!,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: AppColors.midBlue,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _goToAddList,
                          icon: Icon(_savedItem != null
                              ? Icons.edit_rounded
                              : Icons.add_rounded),
                          label: Text(_savedItem != null
                              ? 'Edit List'
                              : 'Tambah ke List'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.midBlue,
                            foregroundColor: AppColors.pureWhite,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            textStyle: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      if (_savedItem != null) ...[
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: _removeFromList,
                          icon: const Icon(Icons.delete_outline_rounded),
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.red.shade400,
                            backgroundColor:
                                Colors.red.shade50,
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const Divider(height: 32, color: AppColors.paleBlue),

                  // Synopsis — loading indicator saat fetch dari API
                  if (_loadingDetail)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(
                            color: AppColors.lightBlue, strokeWidth: 2.5),
                      ),
                    )
                  else if (anime.synopsis != null) ...[
                    Text(
                      'Sinopsis',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      anime.synopsis!.replaceAll('[Written by MAL Rewrite]', '').trim(),
                      style: GoogleFonts.nunito(
                        fontSize: 13.5,
                        height: 1.7,
                        color: AppColors.midBlue,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ] else ...[
                    // Gagal fetch detail (no internet, dll)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.iceBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              color: AppColors.lightBlue, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sinopsis tidak tersedia. Periksa koneksi internetmu.',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: AppColors.midBlue,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _fetchFullDetail,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color),
          ),
        ],
      ),
    );
  }
}
