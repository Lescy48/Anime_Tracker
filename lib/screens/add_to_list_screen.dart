// lib/screens/add_to_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime_model.dart';
import '../models/my_list_item.dart';
import '../services/database_service.dart';
import '../theme.dart';

class AddToListScreen extends StatefulWidget {
  final Anime anime;
  final MyListItem? existingItem;

  const AddToListScreen({
    super.key,
    required this.anime,
    this.existingItem,
  });

  @override
  State<AddToListScreen> createState() => _AddToListScreenState();
}

class _AddToListScreenState extends State<AddToListScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _noteCtrl = TextEditingController();

  String _selectedStatus = 'watchlist';
  bool _isSaving = false;

  // Status pilihan yang tersedia
  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'watchlist',
      'label': 'Watchlist',
      'icon': Icons.bookmark_rounded,
      'color': AppColors.watchlist,
    },
    {
      'value': 'watching',
      'label': 'Watching',
      'icon': Icons.play_circle_filled_rounded,
      'color': AppColors.watching,
    },
    {
      'value': 'completed',
      'label': 'Completed',
      'icon': Icons.check_circle_rounded,
      'color': AppColors.completed,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Jika edit, isi data existing
    if (widget.existingItem != null) {
      _selectedStatus = widget.existingItem!.status;
      _noteCtrl.text = widget.existingItem!.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ─── Simpan data ke SQLite ────────────────────────────────────────────────
  Future<void> _saveToList() async {
    setState(() => _isSaving = true);

    try {
      final item = MyListItem(
        id: widget.existingItem?.id,
        malId: widget.anime.malId,
        title: widget.anime.title,
        imageUrl: widget.anime.imageUrl,
        score: widget.anime.score,
        status: _selectedStatus,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        addedAt: DateTime.now().toIso8601String(),
      );

      if (widget.existingItem != null) {
        // UPDATE data yang sudah ada
        await _db.updateAnime(item);
      } else {
        // INSERT data baru
        await _db.insertAnime(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.pureWhite),
                const SizedBox(width: 10),
                Text(
                  widget.existingItem != null
                      ? 'List berhasil diperbarui!'
                      : 'Ditambahkan ke list!',
                  style:
                      GoogleFonts.nunito(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppColors.midBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softWhite,
      appBar: AppBar(
        title: Text(
          widget.existingItem != null ? 'Edit List' : 'Tambah ke List',
        ),
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.deepBlue,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.iceBlue),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Anime Info Card ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightBlue.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.anime.imageUrl,
                      height: 72,
                      width: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 72,
                        width: 52,
                        color: AppColors.iceBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.anime.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.raleway(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBlue,
                          ),
                        ),
                        if (widget.anime.score != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFE8A800)),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.anime.score}',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.midBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Pilih Status ──────────────────────────────────────────────
            Text(
              'Status',
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.deepBlue,
              ),
            ),
            const SizedBox(height: 12),

            // Status selector cards
            Column(
              children: _statusOptions.map((opt) {
                final isSelected = _selectedStatus == opt['value'];
                final color = opt['color'] as Color;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedStatus = opt['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.1)
                          : AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : AppColors.paleBlue,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(opt['icon'] as IconData,
                            color: isSelected ? color : AppColors.lightBlue,
                            size: 22),
                        const SizedBox(width: 12),
                        Text(
                          opt['label'] as String,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? color : AppColors.midBlue,
                          ),
                        ),
                        const Spacer(),
                        AnimatedOpacity(
                          opacity: isSelected ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.check_circle_rounded,
                              color: color, size: 20),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Catatan / Note ────────────────────────────────────────────
            Text(
              'Catatan (Opsional)',
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.deepBlue,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(
                hintText:
                    'Tulis catatan, kesan, atau episode terakhir yang ditonton...',
              ),
            ),

            const SizedBox(height: 28),

            // ── Tombol Simpan ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveToList,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.midBlue,
                  disabledBackgroundColor: AppColors.paleBlue,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.pureWhite, strokeWidth: 2.5),
                      )
                    : const Text('Simpan ke List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
