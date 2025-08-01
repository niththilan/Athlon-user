// ignore_for_file: deprecated_member_use, file_names
import 'package:flutter/material.dart';
import 'package:athlon_user/customers/footer.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  int _currentTabIndex = 3; // Assuming help/support is at index 3

  // Expanded FAQ items tracking
  final Set<String> _expandedFAQs = <String>{};

  // Selected 4 FAQ items
  final List<FAQ> _selectedFAQs = [
    FAQ(
      id: "account_2",
      question: "How do I reset my password?",
      answer:
          "On the login screen, tap 'Forgot Password', enter your email address, and we'll send you a password reset link.",
    ),
    FAQ(
      id: "account_3",
      question: "How do I update my account information?",
      answer:
          "Go to your profile section, tap 'Edit Profile', make your changes, and save. You can update your name, contact details, and preferences.",
    ),
    FAQ(
      id: "booking_2",
      question: "How do I contact support?",
      answer:
          "You can contact our support team through the contact information provided below, or use the feedback option in the app.",
    ),
    FAQ(
      id: "venue_1",
      question: "How do I find venues near me?",
      answer:
          "The app automatically shows venues based on your location. You can also search by area name or use the map view to explore different locations.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFAQ(String faqId) {
    setState(() {
      if (_expandedFAQs.contains(faqId)) {
        _expandedFAQs.remove(faqId);
      } else {
        _expandedFAQs.add(faqId);
      }
    });
  }

  void _showAppFeedbackDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _buildAppFeedbackDialogContent();
      },
    );
  }

  Widget _buildAppFeedbackDialogContent() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController feedbackController = TextEditingController();
    int selectedRating = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  "App Feedback",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2C4F),
                  ),
                ),
                const SizedBox(height: 24),

                // Name field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Your Name',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Your Email',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Rating section
                const Text(
                  "Rating:",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Star rating
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          selectedRating > index
                              ? Icons.star
                              : Icons.star_border,
                          size: 32,
                          color: selectedRating > index
                              ? Colors.grey[400]
                              : Colors.grey[300],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Feedback field
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: feedbackController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Your Feedback',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showThankYouMessage(selectedRating);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2C4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _showRatingPopup() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       int selectedRating = 0;

  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return Dialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: Container(
  //               padding: const EdgeInsets.all(24),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   // App icon
  //                   Container(
  //                     width: 60,
  //                     height: 60,
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFF1B2C4F),
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: const Icon(
  //                       Icons.sports_tennis,
  //                       color: Colors.white,
  //                       size: 30,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),

  //                   // Title
  //                   const Text(
  //                     "Rate Athlon",
  //                     style: TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                       color: Color(0xFF1B2C4F),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),

  //                   // Subtitle
  //                   Text(
  //                     "How would you rate your experience with our app?",
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       color: Colors.grey[600],
  //                       height: 1.4,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 24),

  //                   // Star rating
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: List.generate(5, (index) {
  //                       return GestureDetector(
  //                         onTap: () {
  //                           setState(() {
  //                             selectedRating = index + 1;
  //                           });
  //                         },
  //                         child: Container(
  //                           padding: const EdgeInsets.all(4),
  //                           child: Icon(
  //                             selectedRating > index
  //                                 ? Icons.star
  //                                 : Icons.star_border,
  //                             size: 36,
  //                             color: selectedRating > index
  //                                 ? Colors.amber
  //                                 : Colors.grey[400],
  //                           ),
  //                         ),
  //                       );
  //                     }),
  //                   ),
  //                   const SizedBox(height: 24),

  //                   // Buttons
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: TextButton(
  //                           onPressed: () => Navigator.of(context).pop(),
  //                           style: TextButton.styleFrom(
  //                             padding: const EdgeInsets.symmetric(vertical: 12),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                           ),
  //                           child: Text(
  //                             "Not Now",
  //                             style: TextStyle(
  //                               color: Colors.grey[600],
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       Expanded(
  //                         child: ElevatedButton(
  //                           onPressed: selectedRating > 0
  //                               ? () {
  //                                   Navigator.of(context).pop();
  //                                   _showThankYouMessage(selectedRating);
  //                                 }
  //                               : null,
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: const Color(0xFF1B2C4F),
  //                             foregroundColor: Colors.white,
  //                             padding: const EdgeInsets.symmetric(vertical: 12),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                           ),
  //                           child: const Text(
  //                             "Submit",
  //                             style: TextStyle(fontWeight: FontWeight.w600),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _showThankYouMessage(int rating) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thank you for rating us $rating star${rating > 1 ? 's' : ''}!',
        ),
        backgroundColor: const Color(0xFF1B2C4F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildLetUsKnowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Let Us Know",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B2C4F),
          ),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: _showAppFeedbackDialog,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.feedback_outlined,
                    color: Color(0xFF1B2C4F),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "App Feedback",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Share your experience",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 4,
        toolbarHeight: 60,
        backgroundColor: const Color(0xFF1B2C4F),
        centerTitle: false,
        title: const Text(
          "Help & Support",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Frequently Asked Questions
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2C4F),
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Search for more help topics...",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // FAQ Items
            ..._selectedFAQs.map((faq) => _buildSimpleFAQItem(faq)),

            const SizedBox(height: 32),

            // Contact Us section
            const Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2C4F),
              ),
            ),
            const SizedBox(height: 16),

            // Contact items
            _buildContactItem(
              Icons.location_on_outlined,
              "Address",
              "11L, 35 Edward Lane, Colombo 00300",
            ),
            const SizedBox(height: 12),
            _buildContactItem(Icons.email_outlined, "Email", "info@athlon.lk"),
            const SizedBox(height: 12),
            _buildContactItem(Icons.language_outlined, "Website", "athlon.lk"),
            const SizedBox(height: 12),
            _buildContactItem(Icons.phone_outlined, "Phone", "+94 722288154"),

            const SizedBox(height: 32),

            // Let Us Know section
            _buildLetUsKnowSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentTabIndex,
        onTabSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSimpleFAQItem(FAQ faq) {
    final isExpanded = _expandedFAQs.contains(faq.id);

    // Get appropriate icon based on question content
    IconData getQuestionIcon(String question) {
      if (question.toLowerCase().contains('password')) {
        return Icons.lock_outlined;
      } else if (question.toLowerCase().contains('account') ||
          question.toLowerCase().contains('update')) {
        return Icons.person_outlined;
      } else if (question.toLowerCase().contains('contact') ||
          question.toLowerCase().contains('support')) {
        return Icons.help_outline;
      } else {
        return Icons.location_on_outlined;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleFAQ(faq.id),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      getQuestionIcon(faq.question),
                      color: const Color(0xFF1B2C4F),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1B2C4F), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.copy_outlined, color: Colors.grey[400], size: 18),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class FAQ {
  final String id;
  final String question;
  final String answer;

  FAQ({required this.id, required this.question, required this.answer});
}
