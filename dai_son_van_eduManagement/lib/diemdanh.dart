import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'lophoc.dart';
import 'sinhvien.dart';

class AttendanceTab extends StatefulWidget {
  final List<Student> students;
  final List<ClassInfo> classes;
  final Map<String, Map<String, bool>> records;
  final bool canEdit;
  final void Function(String dateKey, String studentId, bool? present)
  onSetAttendance;

  const AttendanceTab({
    super.key,
    required this.students,
    required this.classes,
    required this.records,
    this.canEdit = true,
    required this.onSetAttendance,
  });

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  String _selectedClass = 'Tất cả lớp';

  @override
  void didUpdateWidget(covariant AttendanceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedClass != 'Tất cả lớp' &&
        !widget.classes.any((classInfo) => classInfo.title == _selectedClass)) {
      _selectedClass = 'Tất cả lớp';
    }
  }

  String get _dateKey =>
      '${_selectedDate.year.toString().padLeft(4, '0')}-'
      '${_selectedDate.month.toString().padLeft(2, '0')}-'
      '${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = DateUtils.dateOnly(date));
  }

  Future<void> _exportReport() async {
    final studentReports = widget.students.map((student) {
      var present = 0;
      var absent = 0;
      for (final dailyRecord in widget.records.values) {
        final value = dailyRecord[student.id];
        if (value == true) present++;
        if (value == false) absent++;
      }
      final recorded = present + absent;
      final rate = recorded == 0 ? 0.0 : present * 100 / recorded;
      return [
        student.name,
        student.email,
        student.classCode,
        present.toString(),
        absent.toString(),
        recorded.toString(),
        rate.toStringAsFixed(1),
      ];
    }).toList();

    final csvRows = <List<String>>[
      ['Họ tên', 'Email', 'Lớp', 'Có mặt', 'Vắng', 'Số buổi', 'Chuyên cần (%)'],
      ...studentReports,
    ];
    final csv = '\uFEFF${csvRows.map(_csvRow).join('\r\n')}';
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(csv)),
      mimeType: 'text/csv',
      name: 'bao_cao_chuyen_can.csv',
    );

    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'Báo cáo chuyên cần',
          files: [file],
          fileNameOverrides: ['bao_cao_chuyen_can.csv'],
          downloadFallbackEnabled: true,
        ),
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xuất báo cáo: ${error.message}')),
      );
    }
  }

  String _csvRow(List<String> values) {
    return values.map((value) => '"${value.replaceAll('"', '""')}"').join(',');
  }

  @override
  Widget build(BuildContext context) {
    final activeStudents = widget.students
        .where((student) => !student.isInactive)
        .where(
          (student) =>
              _selectedClass == 'Tất cả lớp' ||
              student.classCode == _selectedClass,
        )
        .toList();
    final dailyRecords = widget.records[_dateKey] ?? const <String, bool>{};
    final presentCount = activeStudents
        .where((student) => dailyRecords[student.id] == true)
        .length;
    final absentCount = activeStudents
        .where((student) => dailyRecords[student.id] == false)
        .length;
    final markedCount = presentCount + absentCount;
    final attendanceRate = markedCount == 0
        ? 0.0
        : presentCount * 100 / markedCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Điểm danh & báo cáo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ghi nhận chuyên cần theo ngày và xem thống kê.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ngày ${_selectedDate.day.toString().padLeft(2, '0')}/'
                        '${_selectedDate.month.toString().padLeft(2, '0')}/'
                        '${_selectedDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Chọn ngày'),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  initialValue: _selectedClass,
                  decoration: const InputDecoration(labelText: 'Lọc lớp'),
                  items: [
                    const DropdownMenuItem(
                      value: 'Tất cả lớp',
                      child: Text('Tất cả lớp'),
                    ),
                    ...widget.classes.map(
                      (classInfo) => DropdownMenuItem(
                        value: classInfo.title,
                        child: Text(classInfo.title),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedClass = value);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _SummaryCard(
              label: 'Có mặt',
              value: '$presentCount',
              color: const Color(0xFF15803D),
            ),
            const SizedBox(width: 8),
            _SummaryCard(
              label: 'Vắng',
              value: '$absentCount',
              color: const Color(0xFFDC2626),
            ),
            const SizedBox(width: 8),
            _SummaryCard(
              label: 'Chuyên cần',
              value: '${attendanceRate.toStringAsFixed(0)}%',
              color: const Color(0xFF2563EB),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (activeStudents.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Lớp chưa có sinh viên đang học.')),
            ),
          )
        else
          ...activeStudents.map((student) {
            final attendance = dailyRecords[student.id];
            return Card(
              child: ListTile(
                title: Text(student.name),
                subtitle: Text(student.classCode),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'Có mặt',
                      onPressed: widget.canEdit
                          ? () => widget.onSetAttendance(
                              _dateKey,
                              student.id,
                              true,
                            )
                          : null,
                      icon: Icon(
                        Icons.check_circle,
                        color: attendance == true
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Vắng',
                      onPressed: widget.canEdit
                          ? () => widget.onSetAttendance(
                              _dateKey,
                              student.id,
                              false,
                            )
                          : null,
                      icon: Icon(
                        Icons.cancel,
                        color: attendance == false
                            ? Colors.red
                            : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Báo cáo tổng hợp',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: widget.records.isEmpty ? null : _exportReport,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Xuất CSV'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.records.isEmpty)
          const Text(
            'Chưa có dữ liệu điểm danh để lập báo cáo.',
            style: TextStyle(color: Color(0xFF64748B)),
          )
        else
          ...widget.students.map((student) {
            var present = 0;
            var absent = 0;
            for (final record in widget.records.values) {
              final value = record[student.id];
              if (value == true) present++;
              if (value == false) absent++;
            }
            final total = present + absent;
            final rate = total == 0 ? 0.0 : present * 100 / total;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(student.name),
              subtitle: Text(
                '${student.classCode} · $present có mặt · $absent vắng',
              ),
              trailing: Text(
                total == 0 ? '—' : '${rate.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
