# AnimeTracker

Aplikasi mobile tracker anime pribadi, dibuat dengan Flutter. Data anime diambil langsung dari MyAnimeList via Jikan API, tanpa perlu API key. Penyimpanan daftar anime menggunakan SQLite lokal di perangkat.

## Instalasi

1. Clone repo
```bash
git clone https://github.com/Lescy48/Anime_Tracker.git
cd Anime_Tracker
```

2. Install dependencies
```bash
flutter pub get
```

3. Jalankan app
```bash
flutter run
```

4. Build APK
```bash
flutter build apk --release
```
APK ada di `build/app/outputs/flutter-apk/app-release.apk`

## Fitur

- Browse top airing anime dan search berdasarkan judul, data real-time dari Jikan API
- Lihat detail anime lengkap, sinopsis, genre, score, jumlah episode
- Simpan anime ke daftar pribadi dengan status Watchlist, Watching, atau Completed
- Tambah catatan pribadi per anime
- Filter daftar berdasarkan status
- Data tersimpan permanen di perangkat menggunakan SQLite, tetap ada walau offline