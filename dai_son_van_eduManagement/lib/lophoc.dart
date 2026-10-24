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
}

class ClassesTab extends StatelessWidget {
  final List<ClassInfo> classes;
  final List<Student> students;
  final Function(ClassInfo) onAddClass;

  const ClassesTab({
    super.key,
    required this.classes,
    required this.students,
    required this.onAddClass,
  });

  void _showAddClassDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final teacherController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tạo lớp học mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên lớp (VD: CNTT K68-A)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Môn học',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: teacherController,
                decoration: const InputDecoration(
                  labelText: 'Giảng viên',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
              if (titleController.text.isNotEmpty) {
                final newClass = ClassInfo(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  subtitle: subtitleController.text,
                  teacherName: teacherController.text,
                  teacherAvatar: teacherController.text.isNotEmpty
                      ? teacherController.text.substring(0, 1).toUpperCase()
                      : '?',
                  studentCount: 0,
                  room: 'P. A101',
                  progress: 0.1,
                  tag: 'Mới',
                );
                onAddClass(newClass);
                Navigator.pop(context);
              }
            },
            child: const Text('Tạo lớp', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const HeaderWidget(
          title: 'Danh sách lớp học',
          subtitle: 'Theo dõi tiến độ giảng dạy & danh sách lớp.',
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showAddClassDialog(context),
          icon: const Icon(Icons.add_task_rounded, color: Colors.white),
          label: const Text(
            'Tạo lớp học mới',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        ...classes.map(
          (c) => Column(
            children: [
              ClassCardWidget(
                classInfo: c,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailScreen(
                        classInfo: c,
                        students: students
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
  const ClassCardWidget({super.key, required this.classInfo, this.onTap});

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
