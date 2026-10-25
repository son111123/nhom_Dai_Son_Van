import 'package:flutter/material.dart';

import 'tongquan.dart';
import 'sinhvien.dart';

class ClassInfo {
  final String id;
  final String title;
  final String subtitle;
  final String teacherName;
  final String teacherAvatar;
  final int studentCount;
  final String room;
  final double progress;
  final String tag;

  ClassInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.teacherName,
    required this.teacherAvatar,
    required this.studentCount,
    required this.room,
    required this.progress,
    required this.tag,
  });

  ClassInfo copyWith({
    String? title,
    String? subtitle,
    String? teacherName,
    String? teacherAvatar,
    int? studentCount,
    String? room,
  }) {
    return ClassInfo(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      teacherName: teacherName ?? this.teacherName,
      teacherAvatar: teacherAvatar ?? this.teacherAvatar,
      studentCount: studentCount ?? this.studentCount,
      room: room ?? this.room,
      progress: progress,
      tag: tag,
    );
  }
}

class ClassesTab extends StatefulWidget {
  final List<ClassInfo> classes;
  final List<Student> students;
  final Function(ClassInfo) onAddClass;
  final Function(ClassInfo) onUpdateClass;
  final Function(String) onDeleteClass;
  final bool canManage;

  const ClassesTab({
    super.key,
    required this.classes,
    required this.students,
    required this.onAddClass,
    required this.onUpdateClass,
    required this.onDeleteClass,
    required this.canManage,
  });

  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<ClassesTab> {
  String _searchQuery = '';

  void _showClassDialog(BuildContext context, {ClassInfo? classInfo}) {
    final titleController = TextEditingController(text: classInfo?.title);
    final subtitleController = TextEditingController(text: classInfo?.subtitle);
    final teacherController = TextEditingController(
      text: classInfo?.teacherName,
    );
    final roomController = TextEditingController(
      text: classInfo?.room ?? 'P. A101',
    );
    final formKey = GlobalKey<FormState>();
    final isEditing = classInfo != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEditing ? 'Chỉnh sửa lớp học' : 'Tạo lớp học mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Tên lớp'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: subtitleController,
                  decoration: const InputDecoration(labelText: 'Môn học'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: teacherController,
                  decoration: const InputDecoration(labelText: 'Giảng viên'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: roomController,
                  decoration: const InputDecoration(labelText: 'Phòng học'),
                  validator: _requiredValidator,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final title = titleController.text.trim();
              final teacher = teacherController.text.trim();
              final duplicateTitle = widget.classes.any(
                (existingClass) =>
                    existingClass.id != classInfo?.id &&
                    existingClass.title.toLowerCase() == title.toLowerCase(),
              );
              if (duplicateTitle) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tên lớp này đã được sử dụng.')),
                );
                return;
              }
              if (isEditing) {
                widget.onUpdateClass(
                  classInfo.copyWith(
                    title: title,
                    subtitle: subtitleController.text.trim(),
                    teacherName: teacher,
                    teacherAvatar: teacher[0].toUpperCase(),
                    room: roomController.text.trim(),
                  ),
                );
              } else {
                widget.onAddClass(
                  ClassInfo(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    title: title,
                    subtitle: subtitleController.text.trim(),
                    teacherName: teacher,
                    teacherAvatar: teacher[0].toUpperCase(),
                    studentCount: 0,
                    room: roomController.text.trim(),
                    progress: 0,
                    tag: 'Mới',
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Lưu' : 'Tạo lớp'),
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'Không được để trống.' : null;

  Future<void> _confirmDeleteClass(
    BuildContext context,
    ClassInfo classInfo,
  ) async {
    final enrolledCount = widget.students
        .where((student) => student.classCode == classInfo.title)
        .length;
    if (enrolledCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể xóa lớp còn $enrolledCount sinh viên. '
            'Hãy chuyển sinh viên sang lớp khác trước.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lớp học?'),
        content: Text('Bạn có chắc muốn xóa lớp ${classInfo.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) widget.onDeleteClass(classInfo.id);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredClasses = widget.classes.where((classInfo) {
      return classInfo.title.toLowerCase().contains(query) ||
          classInfo.subtitle.toLowerCase().contains(query) ||
          classInfo.teacherName.toLowerCase().contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const HeaderWidget(
          title: 'Danh sách lớp học',
          subtitle: 'Theo dõi tiến độ giảng dạy & danh sách lớp.',
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Tìm lớp, môn học hoặc giảng viên...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.canManage)
          ElevatedButton.icon(
            onPressed: () => _showClassDialog(context),
            icon: const Icon(Icons.add_task_rounded, color: Colors.white),
            label: const Text(
              'Tạo lớp học mới',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (filteredClasses.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Không tìm thấy lớp phù hợp.')),
          )
        else
          ...filteredClasses.map(
            (c) => Column(
              children: [
                ClassCardWidget(
                  classInfo: c.copyWith(
                    studentCount: widget.students
                        .where((student) => student.classCode == c.title)
                        .length,
                  ),
                  onEdit: widget.canManage
                      ? () => _showClassDialog(context, classInfo: c)
                      : null,
                  onDelete: widget.canManage
                      ? () => _confirmDeleteClass(context, c)
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassDetailScreen(
                          classInfo: c,
                          students: widget.students
                              .where((s) => s.classCode == c.title)
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
      ],
    );
  }
}

class ClassDetailScreen extends StatelessWidget {
  final ClassInfo classInfo;
  final List<Student> students;

  const ClassDetailScreen({
    super.key,
    required this.classInfo,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classInfo.title),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.meeting_room_outlined,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Môn: ${classInfo.subtitle}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Giảng viên: ${classInfo.teacherName} • Phòng: ${classInfo.room}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có sinh viên nào trong lớp này.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: StudentListItem(student: students[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ClassCardWidget extends StatelessWidget {
  final ClassInfo classInfo;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const ClassCardWidget({
    super.key,
    required this.classInfo,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.book_outlined,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classInfo.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${classInfo.subtitle} • Phòng ${classInfo.room}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (action) {
                      if (action == 'edit') onEdit?.call();
                      if (action == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Sửa lớp')),
                      PopupMenuItem(value: 'delete', child: Text('Xóa lớp')),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tiến độ học phần',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                Text(
                  '${(classInfo.progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: classInfo.progress,
                backgroundColor: const Color(0xFFF1F5F9),
                color: const Color(0xFF2563EB),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${classInfo.studentCount} sinh viên',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
                Text(
                  classInfo.teacherName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
