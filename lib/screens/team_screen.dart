import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/team_data.dart';

const Color _mauChinh = Color(0xFF566A5C); // xanh xám

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  // Mở link GitHub trong tab mới
  Future<void> moGithub() async {
    await launchUrl(
      Uri.parse(thongTinDuAn['github'] ?? ''),
      webOnlyWindowName: '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F3),

      // Thanh trên cùng có logo, tự có nút quay lại
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
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin nhóm',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Thành viên nhóm',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  // 2 thẻ thành viên: màn hình rộng xếp ngang, hẹp xếp dọc
                  LayoutBuilder(
                    builder: (context, c) {
                      final rongThe = c.maxWidth >= 700
                          ? (c.maxWidth - 24) / 2
                          : c.maxWidth;
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: dsThanhVien
                            .map(
                              (tv) => SizedBox(
                                width: rongThe,
                                child: theThanhVien(tv),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  thongTinDuAnCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Khung trắng bo góc dùng chung
  Widget khung({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E0)),
      ),
      child: child,
    );
  }

  Widget theThanhVien(Map<String, String> tv) {
    return khung(
      child: Column(
        children: [
          ClipOval(
            child: SizedBox(
              width: 112,
              height: 112,
              child: Image.asset(
                tv['avatar'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, loi, stack) => Container(
                  color: const Color(0xFFDDE5DF),
                  child: const Icon(Icons.person, size: 56, color: _mauChinh),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tv['name'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          dong(Icons.badge_outlined, 'MSSV', tv['mssv']),
          dong(Icons.school_outlined, 'Lớp', tv['lop']),
          dong(Icons.mail_outline, 'Email', tv['email']),
        ],
      ),
    );
  }

  // Thẻ thông tin dự án + nút GitHub
  Widget thongTinDuAnCard() {
    return khung(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin dự án',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          dong(Icons.lightbulb_outline, 'Tên đề tài', thongTinDuAn['tenDeTai']),
          dong(Icons.groups_outlined, 'Nhóm', thongTinDuAn['tenNhom']),
          dong(Icons.menu_book_outlined, 'Môn học', thongTinDuAn['tenMonHoc']),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: moGithub,
            icon: const Icon(Icons.code),
            label: const Text('Xem mã nguồn trên GitHub'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _mauChinh,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Một dòng thông tin: biểu tượng + nhãn + nội dung
  Widget dong(IconData icon, String nhan, String? giaTri) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Text('$nhan: ', style: const TextStyle(color: Colors.black54)),
          Expanded(
            child: Text(
              giaTri ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
