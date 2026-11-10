import 'package:flutter/material.dart';
import 'reader_screen.dart';

const Color _mauChinh = Color(0xFF566A5C);

// Trang chi tiết của một cuốn sách.
// Nhận vào 1 cuốn sách (Map lấy từ books_data.dart).
class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> sach;
  const BookDetailScreen({super.key, required this.sach});

  // Bấm nút "Đọc sách"
  void docSach(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(sach: sach)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F3),

      appBar: AppBar(
        backgroundColor: _mauChinh,
        foregroundColor: Colors.white,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book),
            SizedBox(width: 8),
            Text('BookNest', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: LayoutBuilder(
                builder: (context, c) {
                  // Màn hình rộng: bìa bên trái, thông tin bên phải
                  // Màn hình hẹp: bìa ở trên, thông tin ở dưới
                  final rong = c.maxWidth >= 700;
                  if (rong) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 300, child: anhBia()),
                        const SizedBox(width: 40),
                        Expanded(child: thongTin(context)),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: SizedBox(width: 260, child: anhBia())),
                      const SizedBox(height: 28),
                      thongTin(context),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Ảnh bìa sách (không có ảnh thì hiện khung màu kèm tên sách)
  Widget anhBia() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 0.8,
        child: Image.asset(
          sach['cover'],
          fit: BoxFit.cover,
          errorBuilder: (context, loi, stack) => Container(
            color: _mauChinh,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: Text(
              sach['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }

  // Phần chữ: thể loại, tên, tác giả, giới thiệu, nút đọc
  Widget thongTin(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nhãn thể loại
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFDDE5DF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            sach['category'].toString().toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),

        // Tên sách
        Text(
          sach['title'],
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Tác giả
        Text(
          'Tác giả: ${sach['author']}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 4),

        // Nhà xuất bản
        Text(
          'Nhà xuất bản: ${sach['publisher'] ?? 'Chưa cập nhật'}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Giới thiệu
        const Text(
          'Giới thiệu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          sach['description'] ?? 'Chưa có mô tả cho cuốn sách này.',
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 32),

        // Nút Đọc sách
        ElevatedButton.icon(
          onPressed: () => docSach(context),
          icon: const Icon(Icons.menu_book),
          label: const Text('Đọc sách', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _mauChinh,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
