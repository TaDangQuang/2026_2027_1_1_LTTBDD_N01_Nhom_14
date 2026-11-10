import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

const Color _readerPrimary = Color(0xFF566A5C);
const Color _readerBackground = Color(0xFFF1EFEB);

class ReaderScreen extends StatefulWidget {
  final Map<String, dynamic> sach;

  const ReaderScreen({super.key, required this.sach});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(1);
  final ValueNotifier<int> _pageCount = ValueNotifier<int>(0);
  final TextEditingController _pageInputController = TextEditingController();

  bool _showSidebar = true;
  bool _isBookmarked = false;
  bool _fitWidth = true;

  @override
  void initState() {
    super.initState();
    _pageInputController.text = '1';
    _pdfController.addListener(_syncPageInformation);
  }

  @override
  void dispose() {
    _pdfController.removeListener(_syncPageInformation);
    _pdfController.dispose();
    _currentPage.dispose();
    _pageCount.dispose();
    _pageInputController.dispose();
    super.dispose();
  }

  void _syncPageInformation() {
    final page = _pdfController.pageNumber;
    final count = _pdfController.pageCount;

    if (page > 0 && _currentPage.value != page) {
      _currentPage.value = page;
      _pageInputController.text = '$page';
    }
    if (count > 0 && _pageCount.value != count) {
      _pageCount.value = count;
    }
  }

  void _goToPage(int page) {
    final total = _pdfController.pageCount;
    if (total == 0) return;

    final safePage = page.clamp(1, total).toInt();
    _pdfController.jumpToPage(safePage);
    _pageInputController.text = '$safePage';
  }

  void _submitPage(String value) {
    final page = int.tryParse(value.trim());
    if (page == null) {
      _pageInputController.text = '${_currentPage.value}';
      return;
    }
    _goToPage(page);
  }

  void _changeZoom(double amount) {
    final nextZoom = (_pdfController.zoomLevel + amount)
        .clamp(1.0, 3.0)
        .toDouble();
    _pdfController.zoomLevel = nextZoom;
    setState(() => _fitWidth = false);
  }

  void _toggleFitWidth() {
    setState(() {
      _fitWidth = !_fitWidth;
      _pdfController.zoomLevel = _fitWidth ? 1.0 : 1.25;
    });
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tìm trong sách'),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa cần tìm...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isEmpty) return;
            Navigator.pop(dialogContext);
            _pdfController.searchText(value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final value = searchController.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(dialogContext);
              _pdfController.searchText(value);
            },
            child: const Text('Tìm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    // Chỉ hiện toàn bộ thanh công cụ khi màn hình đủ rộng.
    final isWideToolbar = width >= 1450;

    return Scaffold(
      backgroundColor: _readerBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isDesktop, isWideToolbar),
            Expanded(
              child: Row(
                children: [
                  if (isDesktop && _showSidebar) _buildSidebar(),
                  Expanded(child: _buildPdfArea()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop, bool isWideToolbar) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE3E1DC))),
      ),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 18 : 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Quay lại',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          CircleAvatar(
            radius: 21,
            backgroundColor: _readerPrimary,
            child: const Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          if (isDesktop)
            SizedBox(
              width: isWideToolbar ? 280 : 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sach['title']?.toString() ?? 'Đọc sách',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.sach['author']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Text(
                widget.sach['title']?.toString() ?? 'Đọc sách',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          if (isDesktop) const Spacer(),
          _buildPageNavigator(isDesktop),
          if (isWideToolbar) ...[
            const Spacer(),
            IconButton(
              tooltip: _showSidebar ? 'Ẩn mục lục' : 'Hiện mục lục',
              onPressed: () => setState(() => _showSidebar = !_showSidebar),
              icon: Icon(
                _showSidebar
                    ? Icons.view_sidebar_rounded
                    : Icons.view_sidebar_outlined,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Tìm kiếm',
              onPressed: _showSearchDialog,
              icon: const Icon(Icons.search_rounded),
            ),
            IconButton(
              tooltip: 'Thu nhỏ',
              onPressed: () => _changeZoom(-0.25),
              icon: const Icon(Icons.zoom_out_rounded),
            ),
            ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (_, __, ___) => SizedBox(
                width: 58,
                child: Text(
                  '${(_pdfController.zoomLevel * 100).round()}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Phóng to',
              onPressed: () => _changeZoom(0.25),
              icon: const Icon(Icons.zoom_in_rounded),
            ),
            const SizedBox(width: 6),
            Container(width: 1, height: 28, color: const Color(0xFFE1DFDA)),
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: _toggleFitWidth,
              icon: Icon(
                _fitWidth ? Icons.fit_screen_rounded : Icons.crop_free_rounded,
                size: 18,
              ),
              label: Text(_fitWidth ? 'Vừa chiều rộng' : 'Kích thước thường'),
              style: TextButton.styleFrom(foregroundColor: Colors.black87),
            ),
            IconButton(
              tooltip: _isBookmarked ? 'Bỏ lưu tiến độ' : 'Lưu tiến độ',
              onPressed: () {
                setState(() => _isBookmarked = !_isBookmarked);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                      _isBookmarked
                          ? 'Đã lưu tiến độ ở trang ${_currentPage.value}'
                          : 'Đã bỏ lưu tiến độ',
                    ),
                  ),
                );
              },
              icon: Icon(
                _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
              ),
            ),
          ] else
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'sidebar':
                    setState(() => _showSidebar = !_showSidebar);
                    break;
                  case 'search':
                    _showSearchDialog();
                    break;
                  case 'zoomIn':
                    _changeZoom(0.25);
                    break;
                  case 'zoomOut':
                    _changeZoom(-0.25);
                    break;
                }
              },
              itemBuilder: (_) => [
                if (isDesktop)
                  PopupMenuItem(
                    value: 'sidebar',
                    child: Text(_showSidebar ? 'Ẩn mục lục' : 'Hiện mục lục'),
                  ),
                const PopupMenuItem(value: 'search', child: Text('Tìm kiếm')),
                const PopupMenuItem(value: 'zoomIn', child: Text('Phóng to')),
                const PopupMenuItem(value: 'zoomOut', child: Text('Thu nhỏ')),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPageNavigator(bool isDesktop) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDesktop)
          IconButton(
            tooltip: 'Trang trước',
            onPressed: () => _goToPage(_currentPage.value - 1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6F3),
            border: Border.all(color: const Color(0xFFE1DFDA)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: isDesktop ? 42 : 34,
                child: TextField(
                  controller: _pageInputController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  onSubmitted: _submitPage,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Text('/', style: TextStyle(color: Colors.black45)),
              ),
              ValueListenableBuilder<int>(
                valueListenable: _pageCount,
                builder: (_, count, __) => Text(
                  count == 0 ? '...' : '$count',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        if (isDesktop)
          IconButton(
            tooltip: 'Trang sau',
            onPressed: () => _goToPage(_currentPage.value + 1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
      ],
    );
  }

  Widget _buildSidebar() {
    final toc =
        (widget.sach['toc'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      width: 318,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE1DFDA))),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE8E6E1))),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Mục lục',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _readerPrimary,
                    ),
                  ),
                ),
                Text('Trang', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Expanded(
            child: toc.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'PDF này chưa có dữ liệu mục lục.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                : ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (_, current, __) => ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
                      itemCount: toc.length,
                      itemBuilder: (_, index) {
                        final item = toc[index];
                        final page = item['page'] as int? ?? 1;
                        final nextPage = index + 1 < toc.length
                            ? (toc[index + 1]['page'] as int? ?? 999999)
                            : 999999;
                        final selected = current >= page && current < nextPage;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Material(
                            color: selected
                                ? const Color(0xFFE8EEE9)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _goToPage(page),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 13,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      child: Text(
                                        '${index + 1}'.padLeft(2, '0'),
                                        style: TextStyle(
                                          color: selected
                                              ? _readerPrimary
                                              : Colors.black38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title']?.toString() ??
                                                'Phần ${index + 1}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.25,
                                              fontWeight: selected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                              color: selected
                                                  ? _readerPrimary
                                                  : Colors.black87,
                                            ),
                                          ),
                                          if (item['subtitle'] != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              item['subtitle'].toString(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$page',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? _readerPrimary
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (_, current, __) => ValueListenableBuilder<int>(
              valueListenable: _pageCount,
              builder: (_, total, __) {
                final progress = total == 0 ? 0.0 : current / total;
                return Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE8E6E1))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Tiến độ đọc',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: const Color(0xFFE8E6E1),
                        color: _readerPrimary,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          total == 0
                              ? 'Đang tải tài liệu...'
                              : 'Trang $current trên $total',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfArea() {
    return Container(
      color: _readerBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SfPdfViewer.asset(
        widget.sach['pdf'].toString(),
        controller: _pdfController,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        canShowPaginationDialog: true,
        pageSpacing: 12,
        onDocumentLoaded: (_) => _syncPageInformation(),
        onPageChanged: (_) => _syncPageInformation(),
      ),
    );
  }
}
