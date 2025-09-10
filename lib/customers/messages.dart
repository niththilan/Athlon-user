// ignore_for_file: deprecated_member_use, prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, avoid_print, prefer_final_fields

import 'package:flutter/material.dart';
import 'dart:async'; // Add Timer for debouncing
import './footer.dart';
//import 'home.dart'; // Add this import
import 'widgets/football_spinner.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2C4F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const MessagesScreen(),
    ),
  );
}

/// Represents a chat conversation with a customer
class ChatMessage {
  final String? conversationId; // Add conversation ID for database operations
  final String name;
  String lastMessage;
  final String time;
  int unreadCount;
  final String avatarUrl;
  List<Message> messages;
  bool isArchived;
  bool isPinned;
  bool isMuted;

  ChatMessage({
    this.conversationId,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatarUrl,
    required this.messages,
    this.isArchived = false,
    this.isPinned = false,
    this.isMuted = false,
  });
}

/// Represents an individual message in a chat
class Message {
  final String content;
  final String time;
  final bool isSentByMe;

  const Message({
    // Add const constructor for immutability
    required this.content,
    required this.time,
    required this.isSentByMe,
  });
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  //     GlobalKey<RefreshIndicatorState>();

  // Add timer for debouncing search
  Timer? _debounceTimer;
  static const _debounceTime = Duration(milliseconds: 300);

  List<ChatMessage> _messages = [];
  List<ChatMessage> _filteredMessages = [];
  String _selectedCategory = 'All';
  bool _isSearching = false;
  bool _isLoading = true; // FIXED: Changed from _isRefreshing to _isLoading
  bool _isDisposed = false;
  int _currentIndex = 3; // Messages tab index

  @override
  void initState() {
    super.initState();
    // Initialize with some mock data for testing
    //_initializeMockData();
    // _loadConversationsFromDatabase();

    // Ensure loading state is false after initialization
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load messages from Supabase or other real data source
    // For now, we'll implement a placeholder that loads empty messages
    // until a proper messaging system is implemented in the backend
    
    await Future.delayed(const Duration(milliseconds: 800)); // Keep loading simulation for UX

    if (!_isDisposed) {
      // Load real data instead of mock data
      if (mounted) {
        setState(() {
          _messages = []; // No mock data - load from real source when available
          _filteredMessages = [];
          _isLoading = false;
        });
      }
    }
  }

  // Messages will be loaded from Supabase when messaging system is implemented

  // Add mock data for testing categories
  // void _initializeMockData() {
  //   setState(() {
  //     _messages = [
  //       ChatMessage(
  //         name: 'John Doe',
  //         lastMessage:
  //             'Hi, I need help with booking a football court for tomorrow',
  //         time: '2:30 PM',
  //         unreadCount: 2,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content:
  //                 'Hi, I need help with booking a football court for tomorrow',
  //             time: '2:30 PM',
  //             isSentByMe: false,
  //           ),
  //           Message(
  //             content: 'What time do you prefer?',
  //             time: '2:35 PM',
  //             isSentByMe: true,
  //           ),
  //         ],
  //       ),
  //       ChatMessage(
  //         name: 'Sarah Wilson',
  //         lastMessage: 'Is the court available this evening?',
  //         time: '1:45 PM',
  //         unreadCount: 1,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content: 'Is the court available this evening?',
  //             time: '1:45 PM',
  //             isSentByMe: false,
  //           ),
  //         ],
  //         isPinned: true,
  //       ),
  //       ChatMessage(
  //         name: 'Mike Johnson',
  //         lastMessage: 'Thank you for the excellent service!',
  //         time: 'Yesterday',
  //         unreadCount: 0,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content: 'Thank you for the excellent service!',
  //             time: 'Yesterday',
  //             isSentByMe: false,
  //           ),
  //           Message(
  //             content: 'Thank you! We appreciate your feedback.',
  //             time: 'Yesterday',
  //             isSentByMe: true,
  //           ),
  //         ],
  //       ),
  //       ChatMessage(
  //         name: 'Emma Davis',
  //         lastMessage: 'Can I reschedule my booking?',
  //         time: 'Monday',
  //         unreadCount: 3,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content: 'Can I reschedule my booking?',
  //             time: 'Monday',
  //             isSentByMe: false,
  //           ),
  //         ],
  //       ),
  //       ChatMessage(
  //         name: 'Alex Thompson',
  //         lastMessage: 'What are your rates for group bookings?',
  //         time: '12:15 PM',
  //         unreadCount: 1,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content: 'What are your rates for group bookings?',
  //             time: '12:15 PM',
  //             isSentByMe: false,
  //           ),
  //         ],
  //       ),
  //       ChatMessage(
  //         name: 'Lisa Brown',
  //         lastMessage: 'Great facility, will book again',
  //         time: 'Sunday',
  //         unreadCount: 0,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content: 'Great facility, will book again',
  //             time: 'Sunday',
  //             isSentByMe: false,
  //           ),
  //           Message(
  //             content: 'Thank you for choosing us!',
  //             time: 'Sunday',
  //             isSentByMe: true,
  //           ),
  //         ],
  //         isArchived: true,
  //       ),
  //       ChatMessage(
  //         name: 'David Miller',
  //         lastMessage: 'Is parking available at your venue?',
  //         time: 'Friday',
  //         unreadCount: 0,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content: 'Is parking available at your venue?',
  //             time: 'Friday',
  //             isSentByMe: false,
  //           ),
  //           Message(
  //             content: 'Yes, we have free parking available.',
  //             time: 'Friday',
  //             isSentByMe: true,
  //           ),
  //         ],
  //         isArchived: true,
  //       ),
  //       ChatMessage(
  //         name: 'Jessica Taylor',
  //         lastMessage: 'Do you have equipment rental?',
  //         time: '11:30 AM',
  //         unreadCount: 1,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content: 'Do you have equipment rental?',
  //             time: '11:30 AM',
  //             isSentByMe: false,
  //           ),
  //         ],
  //         isMuted: true,
  //       ),
  //       ChatMessage(
  //         name: 'Robert Anderson',
  //         lastMessage: 'Booking confirmed for 6 PM',
  //         time: 'Yesterday',
  //         unreadCount: 0,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content: 'Booking confirmed for 6 PM',
  //             time: 'Yesterday',
  //             isSentByMe: true,
  //           ),
  //           Message(
  //             content: 'Perfect, see you then!',
  //             time: 'Yesterday',
  //             isSentByMe: false,
  //           ),
  //         ],
  //         isPinned: true,
  //       ),
  //       ChatMessage(
  //         name: 'Maria Garcia',
  //         lastMessage: 'Can I bring my own ball?',
  //         time: 'Thursday',
  //         unreadCount: 0,
  //         avatarUrl: '',
  //         messages: [
  //           Message(
  //             content: 'Can I bring my own ball?',
  //             time: 'Thursday',
  //             isSentByMe: false,
  //           ),
  //           Message(
  //             content: 'Of course! You can bring your own equipment.',
  //             time: 'Thursday',
  //             isSentByMe: true,
  //           ),
  //         ],
  //         isArchived: true,
  //       ),
  //     ];
  //     _filteredMessages = _filterMessagesByCategory(_selectedCategory);
  //   });
  // }

  // Footer navigation to handle all tabs - FIXED
  void _onTabSelected(int index) {
    print('Navigation selected: index $index'); // Debug output

    // Just update the current index for UI state
    // Let the footer handle the actual navigation
    setState(() {});
  }

  // Add debounce for better performance
  void _filterMessages(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(_debounceTime, () {
      if (_isDisposed) return;

      setState(() {
        _isSearching = query.isNotEmpty;
        _filteredMessages = _messages.where((message) {
          return message.name.toLowerCase().contains(query.toLowerCase()) ||
              message.lastMessage.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    });
  }

  List<ChatMessage> _filterMessagesByCategory(String category) {
    List<ChatMessage> filtered;

    // Use switch statement for better readability
    switch (category) {
      case 'Unread':
        filtered = _messages
            .where((message) => message.unreadCount > 0 && !message.isArchived)
            .toList();
        break;
      case 'Archive':
        filtered = _messages.where((message) => message.isArchived).toList();
        break;
      case 'All':
      default:
        filtered = _messages.where((message) => !message.isArchived).toList();
    }

    // Sort by pinned status (pinned messages first)
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return filtered;
  }

  // Add localization fallback method
  String _getLocalizedCategory(String category) {
    switch (category) {
      case 'All':
        return 'All';
      case 'Unread':
        return 'Unread';
      case 'Archive':
        return 'Archive';
      default:
        return category;
    }
  }

  void _filterByCategory(String category) {
    if (_isDisposed) return;

    // Map localized strings to internal keys
    String internalCategory;

    if (category == 'All') {
      internalCategory = 'All';
    } else if (category == 'Unread') {
      internalCategory = 'Unread';
    } else if (category == 'Archive') {
      internalCategory = 'Archive';
    } else {
      internalCategory = category; // fallback
    }

    setState(() {
      _selectedCategory = internalCategory;
      _filteredMessages = _filterMessagesByCategory(internalCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Only show loading during initial load or refresh, not always
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        body: Center(child: FootballLoadingWidget()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 50,
        backgroundColor: const Color(0xFF1B2C4F),
        centerTitle: false,
        title: const Text(
          "Messages",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () {
              // Simply pop back - no loading dialogs needed for back navigation
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            tooltip: 'Back',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildMessageCategories(),
            Expanded(
              child: _filteredMessages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessageList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex, // Messages tab index
        onTabSelected: (int index) {
          // Let the AppFooter handle all navigation logic
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterMessages,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          // hintText: AppLocalizations.of(context)!.searchMessages,
          hintText: 'Search messages',
          hintStyle: TextStyle(
            color: const Color(0xFF1B2C4F).withOpacity(0.5),
            fontFamily: 'Poppins',
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF1B2C4F),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF1B2C4F),
                    size: 20,
                  ),
                  tooltip: 'Clear search',
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _filterMessages('');
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildMessageCategories() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(
            _getLocalizedCategory('All'),
            _selectedCategory == 'All',
          ),
          _buildCategoryChip(
            _getLocalizedCategory('Unread'),
            _selectedCategory == 'Unread',
          ),
          _buildCategoryChip(
            _getLocalizedCategory('Archive'),
            _selectedCategory == 'Archive',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _filterByCategory(label);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1B2C4F) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1B2C4F),
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredMessages.length,
      itemBuilder: (context, index) {
        return ChatTile(
          key: ValueKey(
            _filteredMessages[index].name + _filteredMessages[index].time,
          ),
          message: _filteredMessages[index],
          onTap: () {
            // Update unread count when opening chat
            setState(() {
              _filteredMessages[index].unreadCount = 0;
            });
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChatScreen(chatMessage: _filteredMessages[index]),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            ).then((_) {
              // Refresh the list when returning from chat screen
              setState(() {
                _filteredMessages = _filterMessagesByCategory(
                  _selectedCategory,
                );
              });
            });
          },
          onArchive: () {
            _archiveMessage(_filteredMessages[index]);
          },
          onMore: () {
            _deleteMessage(_filteredMessages[index]);
          },
          onPin: () {
            _pinMessage(_filteredMessages[index]);
          },
          onMute: () {
            _muteMessage(_filteredMessages[index]);
          },
          onUnarchive: () {
            _unarchiveMessage(_filteredMessages[index]);
          },
        );
      },
    );
  }

  void _archiveMessage(ChatMessage message) {
    setState(() {
      message.isArchived = true;
      _filteredMessages = _filterMessagesByCategory(_selectedCategory);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat with ${message.name} archived'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              message.isArchived = false;
              _filteredMessages = _filterMessagesByCategory(_selectedCategory);
            });
          },
        ),
      ),
    );
  }

  void _pinMessage(ChatMessage message) {
    setState(() {
      message.isPinned = !message.isPinned;
      _filteredMessages = _filterMessagesByCategory(_selectedCategory);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.isPinned
              ? 'Chat with ${message.name} pinned'
              : 'Chat with ${message.name} unpinned',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _muteMessage(ChatMessage message) {
    setState(() {
      message.isMuted = !message.isMuted;
      _filteredMessages = _filterMessagesByCategory(_selectedCategory);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.isMuted
              ? 'Notifications muted for ${message.name}'
              : 'Notifications unmuted for ${message.name}',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _unarchiveMessage(ChatMessage message) {
    setState(() {
      message.isArchived = false;
      _filteredMessages = _filterMessagesByCategory(_selectedCategory);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat with ${message.name} unarchived'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              message.isArchived = true;
              _filteredMessages = _filterMessagesByCategory(_selectedCategory);
            });
          },
        ),
      ),
    );
  }

  void _deleteMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text('Delete Chat'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete chat with ${message.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                barrierColor: Colors.white,
                builder: (BuildContext context) {
                  return const FootballLoadingWidget();
                },
              );

              // Loading delay
              await Future.delayed(const Duration(milliseconds: 300));

              Navigator.pop(context);
              setState(() {
                _messages.remove(message);
                _filteredMessages = _filterMessagesByCategory(
                  _selectedCategory,
                );
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chat with ${message.name} deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _messages.add(message);
                        _filteredMessages = _filterMessagesByCategory(
                          _selectedCategory,
                        );
                      });
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Icon(
                _isSearching ? Icons.search_off : Icons.chat_bubble_outline,
                size: 80,
                color: const Color(0xFF1B2C4F).withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                _isSearching
                    ? 'No results found'
                    : _selectedCategory == 'Archive'
                    ? 'No archived messages'
                    : _selectedCategory == 'Unread'
                    ? 'No unread messages'
                    : 'No customer messages yet',
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF2D3142),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _isSearching
                      ? 'Try different keywords'
                      : _selectedCategory == 'Archive'
                      ? 'Archived conversations will appear here.'
                      : _selectedCategory == 'Unread'
                      ? 'New messages from customers will appear here.'
                      : 'When customers inquire, you will see their messages here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF2D3142).withOpacity(0.7),
                  ),
                ),
              ),
              if (!_isSearching && _selectedCategory == 'All') ...[
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2C4F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF1B2C4F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Respond quickly to increase your chances of booking.',
                          style: const TextStyle(
                            color: Color(0xFF1B2C4F),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    _debounceTimer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }
}

// Custom chat tile widget
class ChatTile extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onMore;
  final VoidCallback onPin;
  final VoidCallback onMute;
  final VoidCallback onUnarchive;

  const ChatTile({
    super.key,
    required this.message,
    required this.onTap,
    required this.onArchive,
    required this.onMore,
    required this.onPin,
    required this.onMute,
    required this.onUnarchive,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = message.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: hasUnread
                  ? const Color(0xFF1B2C4F).withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: hasUnread ? 10 : 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: hasUnread
              ? Border.all(color: const Color(0xFF1B2C4F), width: 1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  _buildAvatar(message),
                  if (message.isPinned)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2C4F),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(
                          Icons.push_pin,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            message.name,
                            style: TextStyle(
                              fontWeight: hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: const Color(0xFF2D3142),
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (message.isMuted) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.volume_off,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.lastMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasUnread
                            ? const Color(0xFF2D3142)
                            : const Color(0xFF2D3142).withOpacity(0.7),
                        fontWeight: hasUnread ? FontWeight.w500 : null,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread
                              ? const Color(0xFF1B2C4F)
                              : const Color(0xFF2D3142).withOpacity(0.7),
                          fontWeight: hasUnread ? FontWeight.w500 : null,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2C4F),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF1B2C4F)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    onSelected: (value) {
                      switch (value) {
                        case 'archive':
                          onArchive();
                          break;
                        case 'unarchive':
                          onUnarchive();
                          break;
                        case 'pin':
                          onPin();
                          break;
                        case 'mute':
                          onMute();
                          break;
                        case 'delete':
                          onMore();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!message.isArchived) ...[
                        PopupMenuItem<String>(
                          value: 'archive',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.archive_outlined,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text('Archive Chat'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'pin',
                          child: Row(
                            children: [
                              Icon(
                                message.isPinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                color: const Color(0xFF1B2C4F),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                message.isPinned ? 'Unpin Chat' : 'Pin Chat',
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'mute',
                          child: Row(
                            children: [
                              Icon(
                                message.isMuted
                                    ? Icons.volume_up
                                    : Icons.notifications_off_outlined,
                                color: const Color(0xFF1B2C4F),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                message.isMuted
                                    ? 'Unmute Notifications'
                                    : 'Mute Notifications',
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        PopupMenuItem<String>(
                          value: 'unarchive',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.unarchive_outlined,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text('Unarchive Chat'),
                            ],
                          ),
                        ),
                      ],
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text('Delete Chat'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ChatMessage message) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          color: const Color(0xFF1B2C4F).withOpacity(0.1),
          child: Center(
            child: Text(
              message.name.isNotEmpty ? message.name[0] : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2C4F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Keep the existing ChatScreen class as is but update the AppBar
class ChatScreen extends StatefulWidget {
  final ChatMessage chatMessage;

  const ChatScreen({super.key, required this.chatMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showAttachments = false;
  late List<Message> messages;

  // Quick replies for vendors
  /*
  List<String> _getQuickReplies(BuildContext context) {
    return [
      AppLocalizations.of(context)!.thankYouInquiry,
      AppLocalizations.of(context)!.checkAvailability,
      AppLocalizations.of(context)!.ratesStartFrom,
      AppLocalizations.of(context)!.whatTimeWorks,
      AppLocalizations.of(context)!.availabilityThisWeek,
      AppLocalizations.of(context)!.sendBookingForm,
      AppLocalizations.of(context)!.thanksForChoosing,
      AppLocalizations.of(context)!.howManyPeople,
    ];
  }
  */

  @override
  void initState() {
    super.initState();
    messages = List.from(widget.chatMessage.messages);
    // Scroll to bottom when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        _focusNode.unfocus();
        if (_showAttachments) {
          setState(() {
            _showAttachments = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: messages.length + 1, // +1 for date header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Show date header at the top
                      return _buildDateHeader();
                    }
                    final message =
                        messages[index - 1]; // Adjust index for messages
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1B2C4F),
      elevation: 0,
      toolbarHeight: 50,
      centerTitle: false,
      leading: Container(
        margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
        child: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
            // Navigator.push(
            //   context,
            //   PageRouteBuilder(
            //     pageBuilder: (context, animation, secondaryAnimation) =>
            //         const HomeScreen(),
            //     transitionDuration: Duration.zero,
            //     reverseTransitionDuration: Duration.zero,
            //   ),
            // );
          },
          tooltip: 'Back',
        ),
      ),
      title: Text(
        widget.chatMessage.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.white, size: 20),
          onPressed: () {
            /*
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.of(context)!.calling} ${widget.chatMessage.name}...',
                ),
                backgroundColor: const Color(0xFF1B2C4F),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: Duration(seconds: 2),
              ),
            );
            */
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 8,
          color: Colors.white,
          onSelected: (value) {
            switch (value) {
              case 'block':
                // Implement block functionality
                break;
              case 'report':
                // Implement report functionality
                break;
              case 'clear':
                // Implement clear chat functionality
                setState(() {
                  messages.clear();
                });
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'block',
              child: Row(
                children: [
                  const Icon(Icons.block, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  const Text('Block User'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'report',
              child: Row(
                children: [
                  const Icon(
                    Icons.report_problem,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text('Report'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'clear',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  const Text('Clear Chat'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 4,
        left: message.isSentByMe ? 80 : 0,
        right: message.isSentByMe ? 0 : 80,
      ),
      child: Column(
        crossAxisAlignment: message.isSentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: message.isSentByMe
                  ? const Color(0xFF25D366).withOpacity(
                      0.15,
                    ) // Light green for customer
                  : Colors.white, // White for vendor
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: message.isSentByMe
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: message.isSentByMe
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: message.isSentByMe
                        ? const Color(0xFF1B2C4F)
                        : const Color(0xFF000000),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (message.isSentByMe) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all, size: 14, color: Colors.blue[600]),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    // Get today's date formatted like WhatsApp
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String dateText;
    if (now.difference(today).inHours < 24) {
      dateText = 'Today';
    } else if (now.difference(yesterday).inHours < 48) {
      dateText = 'Yesterday';
    } else {
      // Format as "December 15, 2024"
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      dateText = '${months[now.month - 1]} ${now.day}, ${now.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      children: [
        // Quick replies section
        /*
        if (_showQuickReplies)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.quickReplies,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2C4F),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getQuickReplies(context)
                      .map(
                        (reply) => InkWell(
                          onTap: () {
                            _messageController.text = reply;
                            setState(() {
                              _showQuickReplies = false;
                            });
                            _focusNode.requestFocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF1B2C4F).withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              reply,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1B2C4F),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        */

        // WhatsApp-style message input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFFF0F0F0), // WhatsApp background color
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Emoji/attachment button
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: IconButton(
                  icon: const Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey,
                    size: 24,
                  ),
                  onPressed: () {
                    // Emoji picker functionality
                  },
                ),
              ),
              // Message input field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Type a message',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          maxLines: 5,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                      ),
                      // Attachment button
                      if (_messageController.text.trim().isEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onPressed: () {
                            // Attachment functionality
                          },
                        ),
                      // Camera button
                      if (_messageController.text.trim().isEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.grey,
                              size: 22,
                            ),
                            onPressed: () {
                              // Camera functionality
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Send button
              Container(
                margin: const EdgeInsets.only(left: 4),
                child: CircleAvatar(
                  backgroundColor: _messageController.text.trim().isEmpty
                      ? Colors.grey.shade400
                      : const Color(0xFF25D366), // WhatsApp green
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _messageController.text.trim().isEmpty
                        ? null
                        : _sendMessage,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageContent = _messageController.text.trim();

    _messageController.clear();
    setState(() {
    });

    try {
      /*
      if (widget.chatMessage.conversationId != null) {
        await SupabaseService.sendChatMessage(
          widget.chatMessage.conversationId!,
          messageContent,
          true,
        );
      }
      */

      final newMessage = Message(
        content: messageContent,
        time: _formatCurrentTime(),
        isSentByMe: true,
      );

      setState(() {
        messages.add(newMessage);
        widget.chatMessage.messages = messages;
        widget.chatMessage.lastMessage = messageContent;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      print('Error sending message: $e');

      /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _messageController.text = messageContent;
      */
    }
  }

  // Helper method to format current time
  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
