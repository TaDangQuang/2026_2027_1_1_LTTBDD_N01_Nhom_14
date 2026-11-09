import 'package:flutter/material.dart';
import '../data/books_data.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'book_detail_screen.dart';

const Color mauChinh = Color(0xFF566A5C); // xanh xám

// Các thể loại hiện trên thanh điều hướng
// (chữ phải giống hệt giá trị 'category' trong books_data.dart)
const List<String> dsTheLoai = ['Thiếu nhi', 'Đời sống', 'Tiểu thuyết'];

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String tuKhoa = ''; // chữ đang tìm kiếm
  String theLoai = 'Tất cả'; // thể loại đang chọn

  // Mở trang chi tiết của cuốn sách được bấm
  void xemChiTiet(Map<String, dynamic> sach) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookDetailScreen(sach: sach)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rong = MediaQuery.of(context).size.width >= 1100;

    // Lọc sách theo ô tìm kiếm và thể loại
    final dsSach = duLieuSach.where((s) {
      final chu = '${s['title']} ${s['author']}'.toLowerCase();
      final khopTen = chu.contains(tuKhoa.toLowerCase());
      return khopTen && (theLoai == 'Tất cả' || s['category'] == theLoai);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F3),
      body: Column(
        children: [
          thanhDieuHuong(rong), // đứng yên ở trên
          Expanded(
            // phần còn lại cuộn được
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          if (dsSach.isEmpty)
                            const Text('Không tìm thấy sách nào')
                          else
                            luoiSach(dsSach),
                        ],
                      ),
                    ),
                  ),
                  chanTrang(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Thanh điều hướng ----------

  Widget logo() => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.menu_book, color: Colors.white),
      SizedBox(width: 8),
      Text(
        'BookNest',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  Widget thanhDieuHuong(bool rong) {
    // Màn hình rộng: logo + các mục + ô tìm kiếm + tên người dùng trên 1 hàng
    if (rong) {
      return Container(
        height: 70,
        color: mauChinh,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          children: [
            logo(),
            const SizedBox(width: 32),
            tab('Trang chủ', 'Tất cả'),
            for (final t in dsTheLoai) tab(t, t),
            const Spacer(),
            SizedBox(width: 240, child: oTimKiem()),
            const SizedBox(width: 20),
            PopupMenuButton<String>(
              onSelected: (_) => AuthService().logout(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'out', child: Text('Đăng xuất')),
              ],
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: mauChinh, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.user.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Màn hình nhỏ: hàng trên có logo + nút menu, hàng dưới là ô tìm kiếm
    return Container(
      color: mauChinh,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              logo(),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu, color: Colors.white),
                onSelected: (v) {
                  if (v == 'out') {
                    AuthService().logout();
                  } else {
                    setState(() => theLoai = v);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'Tất cả',
                    child: Text('Trang chủ'),
                  ),
                  for (final t in dsTheLoai)
                    PopupMenuItem(value: t, child: Text(t)),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'out', child: Text('Đăng xuất')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          oTimKiem(),
        ],
      ),
    );
  }

  // Một mục trên thanh điều hướng (bấm vào để lọc theo thể loại)
  Widget tab(String chu, String loai) {
    final chon = theLoai == loai;
    return InkWell(
      onTap: () => setState(() => theLoai = loai),
      child: Container(
        height: 70,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: chon ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          chu,
          style: TextStyle(
            color: chon ? Colors.white : Colors.white70,
            fontWeight: chon ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Ô tìm kiếm (dùng cho cả 2 kiểu thanh điều hướng)
  Widget oTimKiem() {
    return SizedBox(
      height: 40,
      child: TextField(
        onChanged: (chu) => setState(() => tuKhoa = chu),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sách...',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------- Lưới sách ----------

  // Số cột thay đổi theo độ rộng: tối đa 4, tối thiểu 1
  Widget luoiSach(List<Map<String, dynamic>> ds) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final soCot = w >= 1000 ? 4 : (w >= 700 ? 3 : (w >= 450 ? 2 : 1));
        final rongThe = ((w - 24 * (soCot - 1)) / soCot).floorToDouble();
        return Wrap(
          spacing: 24,
          runSpacing: 32,
          children: ds
              .map((s) => SizedBox(width: rongThe, child: theSach(s)))
              .toList(),
        );
      },
    );
  }

  // Một thẻ sách: ảnh bìa + thể loại + tên + tác giả
  Widget theSach(Map<String, dynamic> sach) {
    return InkWell(
      onTap: () => xemChiTiet(sach),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 0.8,
              child: Image.asset('${sach['cover'] ?? ''}', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${sach['category']}'.toUpperCase(),
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            '${sach['title']}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          Text(
            '${sach['author']}',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Chân trang
  Widget chanTrang() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2F3A34),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1110),
          child: Column(
            children: [
              Wrap(
                spacing: 48,
                runSpacing: 32,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        logo(),
                        const SizedBox(height: 16),
                        const Text(
                          'Một góc nhỏ cho những tâm hồn yêu sách.\nĐọc, cảm nhận và lớn lên mỗi ngày.',
                          style: TextStyle(color: Colors.white70, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                  cotLienKet('Khám phá', [
                    'Sách mới',
                    'Sách nổi bật',
                    'Về dự án',
                  ]),
                  cotLienKet('Hỗ trợ', [
                    'Điều khoản sử dụng',
                    'Chính sách bảo mật',
                    'Liên hệ',
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Một cột liên kết trong chân trang
  Widget cotLienKet(String tieuDe, List<String> muc) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tieuDe,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          for (final m in muc)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(m, style: const TextStyle(color: Colors.white70)),
            ),
        ],
      ),
    );
  }
}
