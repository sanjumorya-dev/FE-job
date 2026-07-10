import 'package:flutter/material.dart';
import 'package:dihaadi_app/data/models/user_model.dart';
import 'package:dihaadi_app/constants/colors.dart';

class HelpSupportScreen extends StatefulWidget {
  final UserRole role;

  const HelpSupportScreen({
    super.key,
    required this.role,
  });

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Owner FAQ items
  final List<Map<String, String>> _ownerFaqs = [
    {
      'question': 'How do I post a new requirement?',
      'answer': 'Go to Requirements tab → tap Create → fill in job details, skills, wage and schedule.',
    },
    {
      'question': 'How are workers verified?',
      'answer': 'All workers complete Aadhaar-based KYC, skill tests and background checks before appearing in search.',
    },
    {
      'question': 'Can I edit a requirement after publishing?',
      'answer': 'Yes — open the requirement, tap Edit. Changes won\'t affect workers already accepted.',
    },
    {
      'question': 'How do I mark attendance?',
      'answer': 'Use the Live Map screen or let workers self check-in via QR code at your job site.',
    },
    {
      'question': 'When is payment processed?',
      'answer': 'Payments are auto-deducted at job completion. Disputes can be raised within 48 hours.',
    },
  ];

  // Worker FAQ items
  final List<Map<String, String>> _workerFaqs = [
    {
      'question': 'How do I apply for a job?',
      'answer': 'Go to the Jobs tab → search for open requirements → view details and tap Apply.',
    },
    {
      'question': 'How do I get paid?',
      'answer': 'Once the owner marks your work as completed, the amount will be transferred directly to your linked bank account or UPI.',
    },
    {
      'question': 'What happens if a job is cancelled?',
      'answer': 'If an owner cancels a job after you check in, you are eligible for compensation according to standard workforce policies.',
    },
    {
      'question': 'How do I mark attendance?',
      'answer': 'At the job site, ask the owner for their QR code to scan, or use the check-in option on your dashboard.',
    },
    {
      'question': 'How do I edit my profile or skills?',
      'answer': 'Go to your Profile tab → tap Edit Profile at the top right to update your name, skills, and address.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _currentFaqs {
    final rawFaqs = widget.role == UserRole.owner ? _ownerFaqs : _workerFaqs;
    if (_searchQuery.isEmpty) return rawFaqs;
    return rawFaqs.where((faq) {
      final q = faq['question']!.toLowerCase();
      final a = faq['answer']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return q.contains(query) || a.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E9EB),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Back Button
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF2F3A50),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Titles
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF171A22),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'We\'re here to help — 24/7',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7A8394),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: bottomSafeInset + 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chat Banner Card
            _buildImmediateHelpBanner(),
            const SizedBox(height: 20),

            // Search Box
            _buildSearchBox(),
            const SizedBox(height: 24),

            // Contact & Legal
            const Text(
              'CONTACT & LEGAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7A8394),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactLegalSection(),
            const SizedBox(height: 32),

            // FAQs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FREQUENTLY ASKED',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A8394),
                    letterSpacing: 0.8,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF5123),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'All articles',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFaqSection(),
            
            const SizedBox(height: 24),
            Center(
              child: Text(
                'WorkForce App v2.4.1',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7A8394).withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImmediateHelpBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171A22),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Headset Icon inside container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5123).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.headset_mic_rounded,
              color: Color(0xFFFF5123),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need immediate help?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Our support team is online right now',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9AA1B4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Chat Now Button
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting live support chat...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5123),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Chat now',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF171A22),
          fontWeight: FontWeight.w600,
        ),
        decoration: const InputDecoration(
          hintText: 'Search help articles...',
          hintStyle: TextStyle(
            color: Color(0xFF9AA1B4),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFF9AA1B4),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildContactLegalSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: Column(
        children: [
          _buildSupportTile(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: const Color(0xFF208F67),
            title: 'Chat with Support',
            subtitle: 'Avg. response in 5 min',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Support Chat')),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFE5E9EB)),
          _buildSupportTile(
            icon: Icons.phone_outlined,
            iconColor: const Color(0xFF2182F3),
            title: 'Call Helpline',
            subtitle: '1800-XXX-XXXX · Mon-Sat 9-6',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling Helpline: 1800-XXX-XXXX')),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFE5E9EB)),
          _buildSupportTile(
            icon: Icons.report_problem_outlined,
            iconColor: const Color(0xFFFF7800),
            title: 'Report a Problem',
            subtitle: widget.role == UserRole.owner
                ? 'Bug, payment issue, worker dispute'
                : 'Bug, payment issue, owner dispute',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening problem report form')),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFE5E9EB)),
          _buildSupportTile(
            icon: Icons.block_flipped,
            iconColor: const Color(0xFFDC3545),
            title: 'Blocked Users',
            subtitle: widget.role == UserRole.owner
                ? 'Manage your blocked workers'
                : 'Manage your blocked owners',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to blocked users list')),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFE5E9EB)),
          _buildSupportTile(
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF7A8394),
            title: 'Terms & Conditions',
            subtitle: 'Last updated Jan 2024',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Terms & Conditions')),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFE5E9EB)),
          _buildSupportTile(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF7A8394),
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Privacy Policy')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF171A22),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF7A8394),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF9AA1B4),
        size: 20,
      ),
    );
  }

  Widget _buildFaqSection() {
    final faqs = _currentFaqs;
    if (faqs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: const Text(
          'No FAQs matching your query',
          style: TextStyle(
            color: Color(0xFF9AA1B4),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      children: faqs.map((faq) {
        return _FaqTile(
          question: faq['question']!,
          answer: faq['answer']!,
        );
      }).toList(),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _heightFactor = _animationController.drive(
      CurveTween(curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Little peach circle with chevron-right-rounded inside
                  RotationTransition(
                    turns: _iconTurns,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFFF5123),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF171A22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController.view,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(58, 0, 16, 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: Color(0xFF7A8394),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
