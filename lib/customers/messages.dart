// ignore_for_file: deprecated_member_use, prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'dart:async'; // Add Timer for debouncing
import 'dart:ui';
import 'home.dart';
import 'search.dart';
import 'footer.dart';

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

/// Represents a chat conversation with a sports facility
class ChatMessage {
  final String name;
  String lastMessage;
  final String time;
  int unreadCount;
  final String avatarUrl;
  final bool isOnline;
  List<Message> messages;
  bool isArchived;
  bool isPinned;
  bool isMuted;

  ChatMessage({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatarUrl,
    required this.isOnline,
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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Add timer for debouncing search
  Timer? _debounceTimer;
  static const _debounceTime = Duration(milliseconds: 300);

  List<ChatMessage> _messages = [];
  List<ChatMessage> _filteredMessages = [];
  String _selectedCategory = 'All';
  bool _isSearching = false;
  bool _isRefreshing = false;
  bool _isDisposed = false; // Track widget disposal state

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  // Extract method for better code organization
  void _initializeMessages() {
    _messages = [
      ChatMessage(
        name: "Ark Sports",
        lastMessage: "Yes, the futsal court is available at 3pm tomorrow",
        time: "2m ago",
        unreadCount: 1,
        avatarUrl: "assets/ark.jpg",
        isOnline: true,
        isArchived: false,
        isPinned: false,
        isMuted: false,
        messages: [
          Message(
            content: "Is the futsal court available tomorrow at 3pm?",
            time: "10m ago",
            isSentByMe: true,
          ),
          Message(
            content: "Let me check our schedule for you.",
            time: "8m ago",
            isSentByMe: false,
          ),
          Message(
            content: "Yes, the futsal court is available at 3pm tomorrow",
            time: "2m ago",
            isSentByMe: false,
          ),
        ],
      ),
      ChatMessage(
        name: "Stadium Sports Complex",
        lastMessage: "Thank you for your booking! See you tomorrow.",
        time: "1h ago",
        unreadCount: 0,
        avatarUrl: "assets/crickett.jpg",
        isOnline: false,
        isArchived: false,
        isPinned: false,
        isMuted: false,
        messages: [
          Message(
            content: "I'd like to book the cricket pitch for tomorrow morning",
            time: "2h ago",
            isSentByMe: true,
          ),
          Message(
            content: "Great! I can book you for 9 AM to 11 AM. Does that work?",
            time: "2h ago",
            isSentByMe: false,
          ),
          Message(
            content: "Perfect, I'll take it!",
            time: "1h ago",
            isSentByMe: true,
          ),
          Message(
            content: "Thank you for your booking! See you tomorrow.",
            time: "1h ago",
            isSentByMe: false,
          ),
        ],
      ),
    ];
    _filteredMessages = List.from(_messages);
  }

  Future<void> _refreshMessages() async {
    if (_isDisposed) return;

    setState(() {
      _isRefreshing = true;
    });

    // Simulate network request
    await Future.delayed(const Duration(milliseconds: 1500));

    // Add error handling
    try {
      // Update the messages (in a real app, this would fetch from a server)
      if (!_isDisposed) {
        setState(() {
          _messages.sort((a, b) => a.time.compareTo(b.time));
          _filteredMessages = _filterMessagesByCategory(_selectedCategory);
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _isRefreshing = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh messages: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  void _filterByCategory(String category) {
    if (_isDisposed) return;

    setState(() {
      _selectedCategory = category;
      _filteredMessages = _filterMessagesByCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 2,
        toolbarHeight: 50,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            "Messages",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        leadingWidth: 20,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildMessageCategories(),
            Expanded(
              child: _isRefreshing
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _refreshMessages,
                      color: const Color(0xFF1B2C4F),
                      child: _filteredMessages.isEmpty
                          ? _buildEmptyState()
                          : _buildMessageList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B2C4F),
        onPressed: () {
          _showNewChatOptions();
        },
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 3,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SearchScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 3) {
            // Already on Messages tab, do nothing
          }
        },
      ),
    );
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "New Conversation",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2C4F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildNewChatOption(
                    icon: Icons.sports,
                    title: "Find Facilities",
                    subtitle: "Browse and message sports facilities",
                    color: const Color(0xFF1B2C4F),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewChatOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1B2C4F).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context);
            // Implement the specific action
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: const Color(0xFF2D3142).withOpacity(0.7),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF1B2C4F).withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
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
          hintText: 'Search conversations...',
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
          _buildCategoryChip('All', _selectedCategory == 'All'),
          _buildCategoryChip('Unread', _selectedCategory == 'Unread'),
          _buildCategoryChip('Archive', _selectedCategory == 'Archive'),
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
        content: Text('Conversation with ${message.name} archived'),
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
              ? 'Conversation with ${message.name} pinned'
              : 'Conversation with ${message.name} unpinned',
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
        content: Text('Conversation with ${message.name} unarchived'),
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
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Conversation'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the conversation with ${message.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.remove(message);
                _filteredMessages = _filterMessagesByCategory(
                  _selectedCategory,
                );
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Conversation with ${message.name} deleted'),
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
                _isSearching ? 'No results found' : 'No conversations yet',
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
                      ? 'Try different keywords or check for typos'
                      : 'Start chatting with sports facilities to book your next game',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF2D3142).withOpacity(0.7),
                  ),
                ),
              ),
              if (!_isSearching) ...[
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
                          'Tip: Message facilities directly to check availability',
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
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    _showNewChatOptions();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Start New Conversation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2C4F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
    _debounceTimer?.cancel();
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
      onLongPress: () {
        _showActionMenu(context);
      },
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
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF1B2C4F)),
                    onPressed: () => _showActionMenu(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isArchived) ...[
              ListTile(
                leading: const Icon(
                  Icons.archive_outlined,
                  color: Colors.green,
                ),
                title: const Text('Archive Conversation'),
                onTap: () {
                  Navigator.pop(context);
                  onArchive();
                },
              ),
              ListTile(
                leading: Icon(
                  message.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: const Color(0xFF1B2C4F),
                ),
                title: Text(
                  message.isPinned ? 'Unpin Conversation' : 'Pin Conversation',
                ),
                onTap: () {
                  Navigator.pop(context);
                  onPin();
                },
              ),
              ListTile(
                leading: Icon(
                  message.isMuted
                      ? Icons.volume_up
                      : Icons.notifications_off_outlined,
                  color: const Color(0xFF1B2C4F),
                ),
                title: Text(
                  message.isMuted
                      ? 'Unmute Notifications'
                      : 'Mute Notifications',
                ),
                onTap: () {
                  Navigator.pop(context);
                  onMute();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(
                  Icons.unarchive_outlined,
                  color: Colors.blue,
                ),
                title: const Text('Unarchive Conversation'),
                onTap: () {
                  Navigator.pop(context);
                  onUnarchive();
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Conversation'),
              onTap: () {
                Navigator.pop(context);
                onMore();
              },
            ),
          ],
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
        child: Image.asset(
          message.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
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
            );
          },
        ),
      ),
    );
  }
}

// Chat Screen
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
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              _buildAttachmentSection(),
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
      elevation: 2,
      toolbarHeight: 50,
      leading: Container(
        margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
        child: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            radius: 16,
            backgroundImage: AssetImage(widget.chatMessage.avatarUrl),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image error
            },
            child: widget.chatMessage.avatarUrl.isEmpty
                ? Text(
                    widget.chatMessage.name.isNotEmpty
                        ? widget.chatMessage.name[0]
                        : '?',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.chatMessage.name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.white, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Calling ${widget.chatMessage.name}...'),
                backgroundColor: const Color(0xFF1B2C4F),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          onPressed: () => _showMoreOptions(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF1B2C4F)),
              title: const Text('View Facility Info'),
              onTap: () {
                Navigator.pop(context);
                // Implement facility info view
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block Facility'),
              onTap: () {
                Navigator.pop(context);
                // Implement block functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem, color: Colors.orange),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // Implement report functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Clear Chat'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  messages.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isSentByMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isSentByMe ? const Color(0xFF1B2C4F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    ? Colors.white
                    : const Color(0xFF2D3142),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    color: message.isSentByMe
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF2D3142).withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                if (message.isSentByMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    if (!_showAttachments) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentOption(Icons.image, 'Photo'),
          _buildAttachmentOption(Icons.camera_alt, 'Camera'),
          _buildAttachmentOption(Icons.location_on, 'Location'),
          _buildAttachmentOption(Icons.file_copy, 'Document'),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _showAttachments = false;
        });
        // Implement attachment functionality
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1B2C4F)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1B2C4F)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFF1B2C4F)),
            onPressed: () {
              setState(() {
                _showAttachments = !_showAttachments;
              });
              _focusNode.unfocus();
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: const Color(0xFF1B2C4F).withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                isDense: true,
              ),
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (text) {
                setState(() {}); // Rebuild to update send button state
              },
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _messageController.text.trim().isEmpty
                ? const Color(0xFF1B2C4F).withOpacity(0.5)
                : const Color(0xFF1B2C4F),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _messageController.text.trim().isEmpty
                  ? null
                  : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      content: _messageController.text.trim(),
      time: 'Just now',
      isSentByMe: true,
    );

    setState(() {
      messages.add(newMessage);
      widget.chatMessage.messages = messages;
      widget.chatMessage.lastMessage = _messageController.text.trim();
      _messageController.clear();
    });

    // Simulate auto-reply from facility
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        final autoReplyMessages = [
          "Thanks for your message! I'll check availability and get back to you.",
          "Hi! Thanks for reaching out. Let me look into that for you.",
          "Got your inquiry! I'll send you the details shortly.",
          "Thank you for contacting us. I'll respond with more information soon.",
        ];

        final autoReply =
            autoReplyMessages[DateTime.now().millisecond %
                autoReplyMessages.length];

        setState(() {
          messages.add(
            Message(content: autoReply, time: 'Just now', isSentByMe: false),
          );
          widget.chatMessage.lastMessage = autoReply;
          widget.chatMessage.unreadCount = 1;
        });
      }
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
