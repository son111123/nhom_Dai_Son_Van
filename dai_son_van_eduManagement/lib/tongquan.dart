import 'package:flutter/material.dart';

import 'sinhvien.dart';
import 'lophoc.dart';

class OverviewTab extends StatelessWidget {
  final String username;
  final List<Student> students;
  final List<ClassInfo> classes;
  final double attendanceRate;

  const OverviewTab({
    super.key,
    required this.username,
    required this.students,
    required this.classes,
    required this.attendanceRate,
  });

  double get averageScore {
    if (students.isEmpty) return 0.0;
    return students.map((s) => s.score).reduce((a, b) => a + b) /
        students.length;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        HeaderWidget(
          title: 'Chào buổi sáng, $username',
          subtitle: 'Đây là tổng quan hoạt động hôm nay.',
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            StatCard(
              title: 'Tổng sinh viên',
              value: students.length.toString(),
              subtext: '+8,2% tháng này',
              isPositive: true,
              icon: Icons.people_outline,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
            ),
            StatCard(
              title: 'Điểm trung bình',
              value: averageScore.toStringAsFixed(1),
              subtext: 'Thang điểm 10',
              isPositive: true,
              icon: Icons.star_outline,
              iconBgColor: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFF59E0B),
            ),
            StatCard(
              title: 'Lớp đang mở',
              value: classes.length.toString(),
              subtext: 'Đang giảng dạy',
              isPositive: true,
              icon: Icons.menu_book_outlined,
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF9333EA),
            ),
            StatCard(
              title: 'Chuyên cần',
              value: '${attendanceRate.toStringAsFixed(1)}%',
              subtext: 'Trên các buổi đã điểm danh',
              isPositive: true,
              icon: Icons.check_circle_outline,
              iconBgColor: Color(0xFFDCFCE7),
              iconColor: Color(0xFF16A34A),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phân bố sinh viên theo lớp',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Text(
                'Thống kê số lượng sinh viên trong các lớp',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 20),
              BarChartWidget(students: students),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sinh viên gần đây',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...students
                  .take(3)
                  .map(
                    (s) => Column(
                      children: [
                        StudentListItem(student: s),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  const HeaderWidget({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        const CircleAvatar(
          backgroundColor: Color(0xFF2563EB),
          child: Icon(Icons.person_rounded, color: Colors.white, size: 24),
        ),
      ],
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final bool isPositive;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtext,
    this.isPositive = false,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              color: isPositive ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final List<Student> students;
  const BarChartWidget({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    Map<String, int> classCounts = {};
    for (var student in students) {
      classCounts[student.classCode] =
          (classCounts[student.classCode] ?? 0) + 1;
    }

    var sortedClasses = classCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (students.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    int maxCount = sortedClasses.first.value;

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: sortedClasses.take(5).map((entry) {
          double heightFactor = entry.value / (maxCount > 0 ? maxCount : 1);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 28,
                height: 90 * heightFactor,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 60,
                child: Text(
                  entry.key,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
