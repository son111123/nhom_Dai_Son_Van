import 'package:flutter/material.dart';

import 'tongquan.dart';

class Student {
  final String id;
  final String name;
  final String email;
  final String classCode;
  final double score;
  final String status;
  final bool isInactive;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.classCode,
    required this.score,
    required this.status,
    this.isInactive = false,
  });

  Student copyWith({double? score}) {
    return Student(
      id: id,
      name: name,
      email: email,
      classCode: classCode,
      score: score ?? this.score,
      status: status,
      isInactive: isInactive,
    );
  }

  String get avatarText {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return (names[names.length - 2][0] + names[names.length - 1][0])
          .toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }
}

class StudentsTab extends StatefulWidget {
  final List<Student> students;
  final Function(Student) onAddStudent;
  final Function(String, double) onUpdateScore;
  final Function(String) onSearchChanged;

  const StudentsTab({
    super.key,
    required this.students,
    required this.onAddStudent,
    required this.onUpdateScore,
    required this.onSearchChanged,
  });

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  String selectedFilter = 'Tất cả';

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final classController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Thêm sinh viên mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: classController,
                decoration: const InputDecoration(
                  labelText: 'Lớp học',
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
              if (nameController.text.isNotEmpty) {
                final newStudent = Student(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  email: emailController.text,
                  classCode: classController.text,
                  score: 0.0,
                  status: 'Đang học',
                );
                widget.onAddStudent(newStudent);
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditScoreDialog(BuildContext context, Student student) {
    final scoreController = TextEditingController(
      text: student.score.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cập nhật điểm: ${student.name}'),
        content: TextField(
          controller: scoreController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Điểm số (0 - 10)',
            border: OutlineInputBorder(),
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
              final newScore = double.tryParse(scoreController.text);
              if (newScore != null && newScore >= 0 && newScore <= 10) {
                widget.onUpdateScore(student.id, newScore);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Lưu điểm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = widget.students.where((s) {
      if (selectedFilter == 'Đang học') return !s.isInactive;
      if (selectedFilter == 'Tạm nghỉ') return s.isInactive;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const HeaderWidget(
          title: 'Danh sách sinh viên',
          subtitle: 'Quản lý thông tin & điểm số sinh viên.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: widget.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên, email, lớp...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _showAddStudentDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Filter Chips UI
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Tất cả', 'Đang học', 'Tạm nghỉ'].map((filter) {
              final isSelected = selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => selectedFilter = filter);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (displayList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Text('Không tìm thấy sinh viên phù hợp.'),
            ),
          )
        else
          ...displayList.map(
            (s) => Column(
              children: [
                StudentListItem(
                  student: s,
                  onTap: () => _showEditScoreDialog(context, s),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
      ],
    );
  }
}

class StudentListItem extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;
  const StudentListItem({super.key, required this.student, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: student.isInactive
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFFDBEAFE),
              child: Text(
                student.avatarText,
                style: TextStyle(
                  color: student.isInactive
                      ? Colors.black54
                      : const Color(0xFF1E40AF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${student.classCode} • ${student.email}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: student.isInactive
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      student.status,
                      style: TextStyle(
                        fontSize: 10,
                        color: student.isInactive
                            ? const Color(0xFF64748B)
                            : const Color(0xFF15803D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  student.score.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const Text(
                  'Chỉnh sửa',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
