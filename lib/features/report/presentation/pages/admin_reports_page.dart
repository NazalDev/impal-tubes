import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/report/domain/entity/report_entity.dart';
import 'package:volync/features/report/presentation/bloc/report_bloc.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ReportBloc>().add(ReportLoadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Kelola Laporan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppPallete.buttonColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppPallete.buttonColor,
          tabs: const [
            Tab(text: 'Laporan Event'),
            Tab(text: 'Laporan Pengguna'),
          ],
        ),
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportMarkSeenSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Laporan ditandai sebagai sudah dilihat'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ReportBloc>().add(ReportLoadAll());
          }
          if (state is ReportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppPallete.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          // Read reports directly from state — no _reports cache needed
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports =
              state is ReportLoaded ? state.reports : <ReportEntity>[];

          final eventReports =
              reports.where((r) => r.isEventReport).toList();
          final userReports =
              reports.where((r) => r.isUserReport).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _ReportList(
                reports: eventReports,
                onMarkSeen: (id) => context
                    .read<ReportBloc>()
                    .add(ReportMarkSeen(reportId: id)),
              ),
              _ReportList(
                reports: userReports,
                onMarkSeen: (id) => context
                    .read<ReportBloc>()
                    .add(ReportMarkSeen(reportId: id)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  final List<ReportEntity> reports;
  final void Function(String) onMarkSeen;

  const _ReportList({required this.reports, required this.onMarkSeen});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Tidak ada laporan',
              style: TextStyle(fontSize: 15, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) => _ReportCard(
        report: reports[index],
        onMarkSeen: () => onMarkSeen(reports[index].id),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportEntity report;
  final VoidCallback onMarkSeen;

  const _ReportCard({required this.report, required this.onMarkSeen});

  @override
  Widget build(BuildContext context) {
    final isSeen = report.status == 'seen';
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
        border: isSeen
            ? null
            : Border.all(
                color: Colors.orange.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSeen
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                report.isEventReport
                    ? Icons.event_outlined
                    : Icons.person_outline,
                color: isSeen ? Colors.grey : Colors.orange,
                size: 22,
              ),
            ),
            title: Text(
              report.isEventReport
                  ? (report.reportedEventTitle ?? 'Event tidak diketahui')
                  : (report.reportedUsername ?? 'Pengguna tidak diketahui'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.flag_outlined,
                        size: 12, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      report.reason,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Dilaporkan oleh: ${report.reporterUsername ?? 'Tidak diketahui'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  formatter.format(report.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSeen
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isSeen ? 'Dilihat' : 'Baru',
                style: TextStyle(
                  fontSize: 11,
                  color: isSeen ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (report.description != null && report.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  report.description!,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
            ),
          if (!isSeen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onMarkSeen,
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Tandai Sudah Dilihat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
