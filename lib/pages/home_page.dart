import 'package:flutter/material.dart';

import 'login/email_login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const EmailLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _goToLogin(context),
            child: const Text(
              '去登录',
              style: TextStyle(fontSize: 14, color: Color(0xFF3B53CF)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _WelcomeCard(),
          SizedBox(height: 12),
          _QuickActionCard(),
          SizedBox(height: 12),
          _FeedCard(title: '今日推荐', content: '这里是随机生成的首页内容模块 A'),
          SizedBox(height: 12),
          _FeedCard(title: '热门动态', content: '这里是随机生成的首页内容模块 B'),
          SizedBox(height: 12),
          _FeedCard(title: '猜你喜欢', content: '这里是随机生成的首页内容模块 C'),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B53CF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi，欢迎回来',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '这是一个用于跳过登录后的示例首页。',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _QuickActionItem(icon: Icons.search, label: '搜索'),
          _QuickActionItem(icon: Icons.favorite_border, label: '收藏'),
          _QuickActionItem(icon: Icons.history, label: '历史'),
          _QuickActionItem(icon: Icons.settings, label: '设置'),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFEFF2FF),
          child: Icon(icon, color: const Color(0xFF3B53CF)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E9F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Color(0xFF61677D)),
          ),
        ],
      ),
    );
  }
}
