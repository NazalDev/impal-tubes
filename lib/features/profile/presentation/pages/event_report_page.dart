import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/profile/domain/entity/profile_event_entity.dart';
import 'package:volync/features/profile/domain/entity/profile_member_entity.dart';
import 'package:volync/features/profile/presentation/bloc/profile_bloc.dart';

class EventReportPage extends StatefulWidget {
  final ProfileEventEntity event;
  final List<ProfileMemberEntity> members;

  const EventReportPage({
    super.key,
    required this.event,
    this.members = const [],
  });

  @override
  State<EventReportPage> createState() => _EventReportPageState();
}

class _EventReportPageState extends State<EventReportPage> {
  List<ProfileMemberEntity> _members = [];
  bool _loadedFromBloc = false;

  @override
  void initState() {
    super.initState();
    // Use passed members first; then also trigger a fresh load from bloc
    _members = List.from(widget.members);
    if (_members.isEmpty) {
      context.read<ProfileBloc>().add(
        ProfileLoadEventMembers(eventId: widget.event.id),
      );
    }
  }

  Future<void> _downloadPdf() async {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');
    final now = DateFormat(
      'dd MMMM yyyy HH:mm',
      'id_ID',
    ).format(DateTime.now());

    final approved = _members.where((m) => m.status == 'approved').length;
    final rejected = _members.where((m) => m.status == 'rejected').length;
    final pending = _members.where((m) => m.status == 'pending').length;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Laporan Event',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  widget.event.title,
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Event Info
          pw.Text(
            'Informasi Event',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _pdfRow(
                  'Tanggal Mulai',
                  dateFormatter.format(widget.event.startAt),
                ),
                _pdfRow(
                  'Tanggal Selesai',
                  dateFormatter.format(widget.event.endAt),
                ),
                _pdfRow('Lokasi', widget.event.location),
                _pdfRow('Status', widget.event.status),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Statistics
          pw.Text(
            'Statistik Pendaftaran',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _pdfStatBox('Total', _members.length.toString(), PdfColors.blue),
              pw.SizedBox(width: 8),
              _pdfStatBox('Disetujui', approved.toString(), PdfColors.green),
              pw.SizedBox(width: 8),
              _pdfStatBox('Ditolak', rejected.toString(), PdfColors.red),
              pw.SizedBox(width: 8),
              _pdfStatBox('Menunggu', pending.toString(), PdfColors.orange),
            ],
          ),
          pw.SizedBox(height: 20),

          // Members table
          if (_members.isNotEmpty) ...[
            pw.Text(
              'Daftar Peserta',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _pdfCell('Nama', isHeader: true),
                    _pdfCell('Email', isHeader: true),
                    _pdfCell('Status', isHeader: true),
                  ],
                ),
                // Rows
                ..._members.map(
                  (m) => pw.TableRow(
                    children: [
                      _pdfCell(m.username),
                      _pdfCell(m.email),
                      _pdfCell(m.status),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Description
          pw.Text(
            'Deskripsi Event',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              widget.event.description,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
            ),
          ),

          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(
            'Dicetak pada: $now',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'laporan_${widget.event.title.replaceAll(' ', '_')}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
          ),
          pw.Text(': '),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfStatBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileEventMembersLoaded &&
            state.eventId == widget.event.id) {
          setState(() {
            _members = state.members;
            _loadedFromBloc = true;
          });
        }
      },
      child: Builder(
        builder: (context) {
          final approved = _members.where((m) => m.status == 'approved').length;
          final rejected = _members.where((m) => m.status == 'rejected').length;
          final pending = _members.where((m) => m.status == 'pending').length;

          return Scaffold(
            backgroundColor: AppPallete.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppPallete.cardBackgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppPallete.backButtonColor,
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Laporan Event',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  onPressed: _downloadPdf,
                  tooltip: 'Unduh PDF',
                ),
              ],
            ),
            body: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final isLoading = state is ProfileLoading && _members.isEmpty;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event info card
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppPallete.buttonColor.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.event_note_rounded,
                                    color: AppPallete.buttonColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.event.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            _InfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Tanggal Mulai',
                              value: dateFormatter.format(widget.event.startAt),
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.event_available_outlined,
                              label: 'Tanggal Selesai',
                              value: dateFormatter.format(widget.event.endAt),
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.location_on_outlined,
                              label: 'Lokasi',
                              value: widget.event.location,
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.info_outline,
                              label: 'Status',
                              value: widget.event.status,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Statistics
                      const Text(
                        'Statistik Pendaftaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                value: _members.length.toString(),
                                label: 'Total',
                                color: Colors.blueAccent,
                                icon: Icons.people_outline,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                value: approved.toString(),
                                label: 'Disetujui',
                                color: Colors.green,
                                icon: Icons.check_circle_outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                value: rejected.toString(),
                                label: 'Ditolak',
                                color: Colors.red,
                                icon: Icons.cancel_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                value: pending.toString(),
                                label: 'Menunggu',
                                color: Colors.orange,
                                icon: Icons.hourglass_empty_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Member list preview
                      if (_members.isNotEmpty) ...[
                        const Text(
                          'Daftar Peserta',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _SectionCard(
                          child: Column(
                            children: _members
                                .map(
                                  (m) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.teal
                                              .withOpacity(0.15),
                                          child: Text(
                                            m.username.isNotEmpty
                                                ? m.username[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.teal,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                m.username,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                m.email,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _MiniStatusChip(status: m.status),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      const Text(
                        'Deskripsi Event',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SectionCard(
                        child: Text(
                          widget.event.description,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),

                      if (widget.event.createdAt != null) ...[
                        const SizedBox(height: 16),
                        _SectionCard(
                          child: _InfoRow(
                            icon: Icons.access_time_outlined,
                            label: 'Dibuat pada',
                            value: DateFormat(
                              'dd MMMM yyyy, HH:mm',
                              'id_ID',
                            ).format(widget.event.createdAt!),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MiniStatusChip extends StatelessWidget {
  final String status;
  const _MiniStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status.trim().toLowerCase()) {
      case 'approved':
        color = Colors.green;
        label = 'Disetujui';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Ditolak';
        break;
      default:
        color = Colors.orange;
        label = 'Menunggu';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
