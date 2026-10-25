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

  Student copyWith({
    String? name,
    String? email,
    String? classCode,
    double? score,
    String? status,
    bool? isInactive,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      classCode: classCode ?? this.classCode,
      score: score ?? this.score,
      status: status ?? this.status,
      isInactive: isInactive ?? this.isInactive,
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
  final Function(Student) onEditStudent;
  final Function(String) onDeleteStudent;
  final Function(String, double) onUpdateScore;
  final Function(String) onSearchChanged;
  final List<String> classCodes;
  final bool canManage;
  final bool canEditScores;

  const StudentsTab({
    super.key,
    required this.students,
    required this.onAddStudent,
    required this.onEditStudent,
    required this.onDeleteStudent,
    required this.onUpdateScore,
    required this.onSearchChanged,
    required this.classCodes,
    required this.canManage,
    this.canEditScores = true,
  });

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  String selectedFilter = 'Tất cả';
  String selectedClass = 'Tất cả lớp';

  @override
  void didUpdateWidget(covariant StudentsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedClass != 'Tất cả lớp' &&
        !widget.classCodes.contains(selectedClass)) {
      selectedClass = 'Tất cả lớp';
    }
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    var selectedClassCode = widget.classCodes.isEmpty
        ? ''
        : widget.classCodes.first;
    var isActive = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Thêm sinh viên mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (widget.classCodes.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: selectedClassCode,
                    decoration: const InputDecoration(labelText: 'Lớp học'),
                    items: widget.classCodes
                        .map(
                          (code) =>
                              DropdownMenuItem(value: code, child: Text(code)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedClassCode = value);
                      }
                    },
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Đang học'),
                  value: isActive,
                  onChanged: (value) => setDialogState(() => isActive = value),
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
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập họ tên.')),
                  );
                  return;
                }
                widget.onAddStudent(
                  Student(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    name: name,
                    email: emailController.text.trim(),
                    classCode: selectedClassCode,
                    score: 0,
                    status: isActive ? 'Đang học' : 'Tạm nghỉ',
                    isInactive: !isActive,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, Student student) {
    final nameController = TextEditingController(text: student.name);
    final emailController = TextEditingController(text: student.email);
    var selectedClassCode = widget.classCodes.contains(student.classCode)
        ? student.classCode
        : (widget.classCodes.isEmpty ? '' : widget.classCodes.first);
    var isActive = !student.isInactive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Chỉnh sửa sinh viên'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (widget.classCodes.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: selectedClassCode,
                    decoration: const InputDecoration(labelText: 'Lớp học'),
                    items: widget.classCodes
                        .map(
                          (code) =>
                              DropdownMenuItem(value: code, child: Text(code)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedClassCode = value);
                      }
                    },
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Đang học'),
                  value: isActive,
                  onChanged: (value) => setDialogState(() => isActive = value),
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
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập họ tên.')),
                  );
                  return;
                }
                widget.onEditStudent(
                  student.copyWith(
                    name: name,
                    email: emailController.text.trim(),
                    classCode: selectedClassCode,
                    status: isActive ? 'Đang học' : 'Tạm nghỉ',
                    isInactive: !isActive,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteStudent(
    BuildContext context,
    Student student,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sinh viên?'),
        content: Text('Bạn có chắc muốn xóa ${student.name}?'),
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
    if (confirmed == true) widget.onDeleteStudent(student.id);
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
      final statusMatches = switch (selectedFilter) {
        'Đang học' => !s.isInactive,
        'Tạm nghỉ' => s.isInactive,
        _ => true,
      };
      final classMatches =
          selectedClass == 'Tất cả lớp' || s.classCode == selectedClass;
      return statusMatches && classMatches;
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
            if (widget.canManage)
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
        DropdownButtonFormField<String>(
          initialValue: selectedClass,
          decoration: const InputDecoration(
            labelText: 'Lọc theo lớp',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(
              value: 'Tất cả lớp',
              child: Text('Tất cả lớp'),
            ),
            ...widget.classCodes.map(
              (code) => DropdownMenuItem(value: code, child: Text(code)),
            ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => selectedClass = value);
          },
        ),
        const SizedBox(height: 12),
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
                  onTap: widget.canEditScores
                      ? () => _showEditScoreDialog(context, s)
                      : null,
                  trailing: widget.canManage
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (action) {
                            if (action == 'edit') {
                              _showEditStudentDialog(context, s);
                            } else if (action == 'delete') {
                              _confirmDeleteStudent(context, s);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Sửa thông tin'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa sinh viên'),
                            ),
                          ],
                        )
                      : null,
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
  final Widget? trailing;
  const StudentListItem({
    super.key,
    required this.student,
    this.onTap,
    this.trailing,
  });

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
                  'Điểm',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
