import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.username,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Thẻ thông tin cá nhân
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFF2563EB),
                child: Text(
                  'HL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tài khoản EduManager',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    SizedBox(height: 6),
                    Chip(
                      label: Text(
                        'Tài khoản người dùng',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      backgroundColor: Color(0xFFEFF6FF),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Nhóm Cài đặt tài khoản
        const Text(
          'Tài khoản',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        _buildSettingsGroup([
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Chỉnh sửa thông tin',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.notifications_none,
            title: 'Thông báo',
            onTap: () {},
          ),
        ]),
        const SizedBox(height: 20),
        // Nhóm Tùy chỉnh ứng dụng
        const Text(
          'Cài đặt ứng dụng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        _buildSettingsGroup([
          _ProfileMenuItem(
            icon: Icons.dark_mode_outlined,
            title: 'Chế độ tối',
            trailing: Switch(value: false, onChanged: (v) {}),
            onTap: null,
          ),
          _ProfileMenuItem(
            icon: Icons.language,
            title: 'Ngôn ngữ',
            trailingText: 'Tiếng Việt',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () {},
          ),
        ]),
        const SizedBox(height: 24),
        // Nút Đăng xuất
        ElevatedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'Đăng xuất',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFEE2E2),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF475569), size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), 
        ),
        trailing:
            trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null)
                  Text(
                    trailingText!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
      ),
    );
  }
}
