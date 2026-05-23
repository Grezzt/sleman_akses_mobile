import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sleman_akses_mobile/core/network/api_client.dart';
import 'package:sleman_akses_mobile/core/theme/app_theme.dart';
import 'package:sleman_akses_mobile/features/report/ui/screens/report_detail_screen.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _reports = [];
  TabController? _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  void _ensureTabController() {
    if (_tabController == null) {
      _tabController = TabController(length: 4, vsync: this);
      _tabController!.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _ensureTabController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 0 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
    _fetchReports();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('${ApiClient.baseUrl}/reports');
      final response = await http.get(uri, headers: ApiClient.headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _reports = data['data']['reports'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Gagal mengambil laporan';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Terjadi kesalahan pada server (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Gagal terhubung ke server. Periksa koneksi internet Anda.';
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getFilteredReports() {
    _ensureTabController();
    if (_tabController!.index == 1) {
      return _reports
          .where((r) => r['validation_status'] == 'approved')
          .toList();
    } else if (_tabController!.index == 2) {
      return _reports
          .where(
            (r) =>
                r['validation_status'] == 'pending' ||
                r['validation_status'] == null,
          )
          .toList();
    } else if (_tabController!.index == 3) {
      return _reports
          .where((r) => r['validation_status'] == 'rejected')
          .toList();
    }
    return _reports;
  }

  @override
  Widget build(BuildContext context) {
    _ensureTabController();

    final headerBgColor = _isScrolled ? AppTheme.primary : Colors.white;
    final headerTextColor = _isScrolled ? Colors.white : AppTheme.primary;
    final unselectedColor = _isScrolled ? Colors.white70 : AppTheme.textMuted;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF3F4F6,
      ), // Light grey background like Profile
      appBar: AppBar(
        backgroundColor: headerBgColor,
        foregroundColor: headerTextColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'Riwayat Laporan Saya',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: headerTextColor,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          labelColor: headerTextColor,
          unselectedLabelColor: unselectedColor,
          indicatorColor: AppTheme.secondary,
          indicatorWeight: 5,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Disetujui'),
            Tab(text: 'Menunggu'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReports,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final filteredReports = _getFilteredReports();

    if (filteredReports.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat laporan.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchReports,
      color: AppTheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredReports.length,
        itemBuilder: (context, index) {
          final report = filteredReports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  IconData _getFacilityIcon(String? category) {
    if (category == null) return Icons.check_circle;
    final lower = category.toLowerCase();
    if (lower.contains('miring') || lower.contains('ramp'))
      return Icons.accessible;
    if (lower.contains('toilet') || lower.contains('wc')) return Icons.wc;
    if (lower.contains('lift') || lower.contains('elevator'))
      return Icons.elevator;
    if (lower.contains('parkir')) return Icons.local_parking;
    return Icons.check_circle;
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return '-';
    final dateObj = DateTime.tryParse(timestamp);
    if (dateObj == null) return '-';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${dateObj.day.toString().padLeft(2, '0')} ${months[dateObj.month - 1]} ${dateObj.year}';
  }

  Widget _buildReportCard(dynamic report) {
    final status = report['validation_status'] ?? 'pending';
    final isPending = status == 'pending';
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    final mapLocation = report['map_location'];
    final placeName = mapLocation?['place_name'] ?? 'Titik Lokasi Baru';
    final dateString = _formatDate(report['timestamp']);
    final details = report['details'] as List<dynamic>? ?? [];

    Color statusColor;
    String statusText;

    if (isApproved) {
      statusColor = AppTheme.success;
      statusText = 'DISETUJUI';
    } else if (isRejected) {
      statusColor = AppTheme.error;
      statusText = 'DITOLAK';
    } else {
      statusColor = AppTheme.warning;
      statusText = 'MENUNGGU';
    }

    final rawImageUrl = report['photo_url'];
    final imageUrl = (rawImageUrl != null && !rawImageUrl.toString().contains('example.com')) 
        ? rawImageUrl.toString() 
        : null;
        
    final List<String> photoUrls = imageUrl != null ? imageUrl.split(',') : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.border,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailScreen(report: report),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Persegi di Kiri
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: photoUrls.isNotEmpty
                        ? Image.network(
                            photoUrls[0].trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),
                const SizedBox(width: 16),

                // Konten Kanan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        isPending ? 'Menunggu Validasi' : placeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Alamat
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              mapLocation?['address'] ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Tanggal
                      Text(
                        dateString,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Fasilitas Icons & Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: details.map<Widget>((d) {
                              bool isAvailable =
                                  d['availability_status'] == true;
                              IconData icon = _getFacilityIcon(d['category']);
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  icon,
                                  size: 20,
                                  color: isAvailable
                                      ? AppTheme.primary
                                      : AppTheme.border,
                                ),
                              );
                            }).toList(),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Catatan Penolakan (Hanya jika ada, bisa dimunculkan di bawah atau ditambahkan nanti di detail)
                      if (!isPending &&
                          report['evaluation_note'] != null &&
                          report['evaluation_note'].toString().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isApproved
                                ? AppTheme.primary.withOpacity(0.05)
                                : AppTheme.error.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Catatan: ${report['evaluation_note']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isApproved
                                  ? AppTheme.primary
                                  : AppTheme.error,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.black54),
    );
  }
}
