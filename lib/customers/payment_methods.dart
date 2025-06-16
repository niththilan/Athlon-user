// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const PaymentMethodsApp());
}

class PaymentMethodsApp extends StatelessWidget {
  const PaymentMethodsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment Methods',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2C4F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF1B2C4F), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade600),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B2C4F),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      home: const PaymentMethodsScreen(),
    );
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen>
    with SingleTickerProviderStateMixin {
  // Mock data for payment methods
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      cardType: 'Visa',
      lastFourDigits: '4242',
      expiryDate: '05/25',
      isDefault: true,
      cardHolderName: 'John Doe',
      cardColor: const Color(0xFF1B2C4F),
    ),
    PaymentMethod(
      id: '2',
      cardType: 'Mastercard',
      lastFourDigits: '5678',
      expiryDate: '09/26',
      isDefault: false,
      cardHolderName: 'Jane Smith',
      cardColor: const Color(0xFF424CB8),
    ),
  ];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 2,
        toolbarHeight: 50,
        title: const Text(
          "Payment Methods",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildAddPaymentMethodButton(),
          Expanded(
            child: _paymentMethods.isEmpty
                ? _buildEmptyState()
                : _buildPaymentMethodsList(),
          ),
        ],
      ),
      // Removed floating action button for simplicity
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_controller),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B2C4F).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.credit_card,
                  size: 80,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'No Payment Methods',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Add your credit or debit card to make bookings faster and easier',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _addNewPaymentMethod,
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Card'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  minimumSize: const Size(250, 55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: _paymentMethods.length,
          itemBuilder: (context, index) {
            final method = _paymentMethods[index];
            // Staggered animation for each card
            final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  0.1 * index,
                  0.1 * index + 0.6,
                  curve: Curves.easeOut,
                ),
              ),
            );

            return FadeTransition(
              opacity: itemAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.2, 0),
                  end: Offset.zero,
                ).animate(itemAnimation),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCreditCardWidget(method),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreditCardWidget(PaymentMethod method) {
    return GestureDetector(
      onTap: () => _showCardOptions(method),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              method.cardColor,
              Color.lerp(method.cardColor, Colors.black, 0.3) ??
                  method.cardColor,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: method.cardColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: CardPatternPainter(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _getCardTypeImage(method.cardType),
                      if (method.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),

                  // Card number
                  Text(
                    '•••• •••• •••• ${method.lastFourDigits}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card holder and expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARD HOLDER',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method.cardHolderName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPIRES',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method.expiryDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCardTypeImage(String cardType) {
    IconData iconData;
    Color iconColor = Colors.white;
    String label;

    switch (cardType.toLowerCase()) {
      case 'visa':
        iconData = Icons.credit_card;
        label = 'VISA';
        break;
      case 'mastercard':
        iconData = Icons.credit_card;
        label = 'MASTERCARD';
        break;
      case 'american express':
        iconData = Icons.credit_card;
        label = 'AMEX';
        break;
      default:
        iconData = Icons.credit_card;
        label = 'CARD';
    }

    return Row(
      children: [
        Icon(iconData, color: iconColor, size: 30),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildAddPaymentMethodButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: TextButton(
        onPressed: _addNewPaymentMethod,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          foregroundColor: const Color(0xFF1B2C4F),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, size: 18),
            SizedBox(width: 8),
            Text('Add Payment Method', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _showCardOptions(PaymentMethod method) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(),
              const SizedBox(height: 20),
              Text(
                '${method.cardType} •••• ${method.lastFourDigits}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2C4F),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Expires ${method.expiryDate}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),
              _buildOptionButton(
                icon: Icons.edit_outlined,
                label: 'Edit Card Details',
                onTap: () {
                  Navigator.pop(context);
                  _editPaymentMethod(method);
                },
              ),
              if (!method.isDefault)
                _buildOptionButton(
                  icon: Icons.check_circle_outline,
                  label: 'Set as Default',
                  onTap: () {
                    Navigator.pop(context);
                    _setAsDefaultPaymentMethod(method);
                  },
                ),
              _buildOptionButton(
                icon: Icons.delete_outline,
                label: 'Remove Card',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _deletePaymentMethod(method);
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 28, 27, 27),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFF1B2C4F),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddPaymentMethodForm(),
    );
  }

  Widget _buildAddPaymentMethodForm() {
    final cardNumberController = TextEditingController();
    final cardHolderController = TextEditingController();
    final expiryDateController = TextEditingController();
    final cvvController = TextEditingController();
    String selectedCardType = 'Visa'; // Default card type
    final formKey = GlobalKey<FormState>();

    // Card animation transformations
    final Matrix4 rotateRight = Matrix4.identity()..rotateY(0.1);
    final Matrix4 rotateLeft = Matrix4.identity()..rotateY(-0.1);

    // Card details
    String cardNumber = '•••• •••• •••• ••••';
    String cardHolder = 'YOUR NAME';
    String expiryDate = 'MM/YY';

    return StatefulBuilder(
      builder: (context, setState) {
        void updateCardData() {
          setState(() {
            cardNumber = cardNumberController.text.isEmpty
                ? '•••• •••• •••• ••••'
                : _formatCardNumber(cardNumberController.text);
            cardHolder = cardHolderController.text.isEmpty
                ? 'YOUR NAME'
                : cardHolderController.text.toUpperCase();
            expiryDate = expiryDateController.text.isEmpty
                ? 'MM/YY'
                : expiryDateController.text;
          });
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle and title
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(),
                    const SizedBox(height: 16),
                    const Text(
                      'Add New Card',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2C4F),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 20,
                    right: 20,
                    top: 20,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated Credit Card Preview
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            height: 200,
                            margin: const EdgeInsets.only(bottom: 30),
                            transform: selectedCardType == 'Visa'
                                ? rotateRight
                                : rotateLeft,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: selectedCardType == 'Visa'
                                      ? [
                                          const Color(0xFF1B2C4F),
                                          const Color(0xFF2A4178),
                                        ]
                                      : [
                                          const Color(0xFF424CB8),
                                          const Color(0xFF2F3A8F),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (selectedCardType == 'Visa'
                                                ? const Color(0xFF1B2C4F)
                                                : const Color(0xFF424CB8))
                                            .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.credit_card,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            selectedCardType.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.wifi,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    cardNumber,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'CARD HOLDER',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            cardHolder,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'EXPIRES',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            expiryDate,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
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
                        ),

                        // Card Type Selection
                        const Text(
                          'Card Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCardTypeOption(
                                isSelected: selectedCardType == 'Visa',
                                cardType: 'Visa',
                                onTap: () => setState(() {
                                  selectedCardType = 'Visa';
                                }),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCardTypeOption(
                                isSelected: selectedCardType == 'Mastercard',
                                cardType: 'Mastercard',
                                onTap: () => setState(() {
                                  selectedCardType = 'Mastercard';
                                }),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Card Number Field
                        TextFormField(
                          controller: cardNumberController,
                          decoration: InputDecoration(
                            labelText: 'Card Number',
                            prefixIcon: Icon(
                              Icons.credit_card,
                              size: 18,
                              color: const Color(0xFF1B2C4F).withOpacity(0.7),
                            ),
                            hintText: '1234 5678 9012 3456',
                            suffixIcon: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Color(0xFF1B2C4F),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            _CardNumberFormatter(),
                          ],
                          onChanged: (value) => updateCardData(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter card number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Cardholder Name Field
                        TextFormField(
                          controller: cardHolderController,
                          decoration: InputDecoration(
                            labelText: 'Cardholder Name',
                            prefixIcon: Icon(
                              Icons.person,
                              size: 18,
                              color: const Color(0xFF1B2C4F).withOpacity(0.7),
                            ),
                            hintText: 'Name on card',
                            floatingLabelStyle: const TextStyle(
                              color: Color(0xFF1B2C4F),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) => updateCardData(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter cardholder name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Expiry Date and CVV Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: expiryDateController,
                                decoration: InputDecoration(
                                  labelText: 'Expiry Date',
                                  hintText: 'MM/YY',
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: const Color(
                                      0xFF1B2C4F,
                                    ).withOpacity(0.7),
                                  ),
                                  floatingLabelStyle: const TextStyle(
                                    color: Color(0xFF1B2C4F),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 12),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  _ExpiryDateFormatter(),
                                ],
                                onChanged: (value) => updateCardData(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: cvvController,
                                decoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: '123',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    size: 16,
                                    color: const Color(
                                      0xFF1B2C4F,
                                    ).withOpacity(0.7),
                                  ),
                                  floatingLabelStyle: const TextStyle(
                                    color: Color(0xFF1B2C4F),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 12),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                // Choose a random color for the new card
                                final colors = [
                                  const Color(0xFF1B2C4F),
                                  const Color(0xFF424CB8),
                                  const Color(0xFF38386A),
                                  const Color(0xFF5E4FC1),
                                ];
                                final randomColor =
                                    colors[math.Random().nextInt(
                                      colors.length,
                                    )];

                                setState(() {
                                  this.setState(() {
                                    _paymentMethods.add(
                                      PaymentMethod(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        cardType: selectedCardType,
                                        lastFourDigits:
                                            cardNumberController.text.length >=
                                                4
                                            ? cardNumberController.text
                                                  .replaceAll(' ', '')
                                                  .substring(
                                                    cardNumberController.text
                                                            .replaceAll(' ', '')
                                                            .length -
                                                        4,
                                                  )
                                            : '0000',
                                        expiryDate: expiryDateController.text,
                                        isDefault: _paymentMethods.isEmpty,
                                        cardHolderName:
                                            cardHolderController.text,
                                        cardColor: randomColor,
                                      ),
                                    );
                                  });
                                });
                                Navigator.pop(context);

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('Card added successfully'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.all(10),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: const Text('Save Card'),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Cancel Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: const Color.fromARGB(
                                255,
                                149,
                                141,
                                141,
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        // Remove extra space by adding minimal bottom padding
                        const SizedBox(height: 5),

                        // Security note
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Your payment info is stored securely',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardTypeOption({
    required bool isSelected,
    required String cardType,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1B2C4F).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B2C4F) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card,
              color: isSelected
                  ? cardType == 'Visa'
                        ? Colors.blue
                        : Colors.deepOrange
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              cardType,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF1B2C4F)
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCardNumber(String input) {
    final digitsOnly = input.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    final obscured = formatted.replaceAllMapped(RegExp(r'\d'), (match) => '•');

    if (digitsOnly.length >= 12) {
      // Show only last 4 digits
      return '•••• •••• •••• ${digitsOnly.substring(digitsOnly.length - 4)}';
    } else {
      return obscured;
    }
  }

  void _editPaymentMethod(PaymentMethod method) {
    final cardHolderController = TextEditingController(
      text: method.cardHolderName,
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Card animation transformations
            final Matrix4 rotateRight = Matrix4.identity()..rotateY(0.1);
            final Matrix4 rotateLeft = Matrix4.identity()..rotateY(-0.1);

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle and title
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(),
                        const SizedBox(height: 16),
                        const Text(
                          'Edit Card Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        left: 20,
                        right: 20,
                        top: 20,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Animated Credit Card Preview
                            Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                height: 200,
                                margin: const EdgeInsets.only(bottom: 30),
                                transform: method.cardType == 'Visa'
                                    ? rotateRight
                                    : rotateLeft,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        method.cardColor,
                                        Color.lerp(
                                              method.cardColor,
                                              Colors.black,
                                              0.3,
                                            ) ??
                                            method.cardColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: method.cardColor.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _getCardTypeImage(method.cardType),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.wifi,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        '•••• •••• •••• ${method.lastFourDigits}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'CARD HOLDER',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                cardHolderController.text
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'EXPIRES',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                method.expiryDate,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
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
                            ),

                            // Cardholder Name Field
                            TextFormField(
                              controller: cardHolderController,
                              decoration: InputDecoration(
                                labelText: 'Cardholder Name',
                                prefixIcon: Icon(
                                  Icons.person,
                                  size: 18,
                                  color: const Color(
                                    0xFF1B2C4F,
                                  ).withOpacity(0.7),
                                ),
                                hintText: 'Name on card',
                                floatingLabelStyle: const TextStyle(
                                  color: Color(0xFF1B2C4F),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(fontSize: 12),
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) {
                                // Update the preview when text changes
                                setState(() {});
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter cardholder name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 35),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    // Update the payment method
                                    this.setState(() {
                                      final index = _paymentMethods.indexWhere(
                                        (m) => m.id == method.id,
                                      );
                                      if (index != -1) {
                                        _paymentMethods[index] = PaymentMethod(
                                          id: method.id,
                                          cardType: method.cardType,
                                          lastFourDigits: method.lastFourDigits,
                                          expiryDate: method.expiryDate,
                                          isDefault: method.isDefault,
                                          cardHolderName:
                                              cardHolderController.text,
                                          cardColor: method.cardColor,
                                        );
                                      }
                                    });

                                    Navigator.pop(context);

                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Card updated successfully',
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.green.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        margin: const EdgeInsets.all(10),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B2C4F),
                                  minimumSize: const Size(double.infinity, 55),
                                ),
                                child: const Text('Save Changes'),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Cancel Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: const Color.fromARGB(
                                    255,
                                    28,
                                    26,
                                    26,
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            // Remove extra space by adding minimal bottom padding
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deletePaymentMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove Card',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2C4F),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card_off,
                color: Colors.red.shade400,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to remove this card? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 40), // Set minimum width
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ), // Add padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                _paymentMethods.removeWhere((m) => m.id == method.id);
              });
              Navigator.pop(context);

              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Card removed successfully'),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(10),
                ),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _setAsDefaultPaymentMethod(PaymentMethod method) {
    setState(() {
      for (var m in _paymentMethods) {
        m.isDefault = m.id == method.id;
      }
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              '${method.cardType} ending in ${method.lastFourDigits} set as default',
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}

// Custom painter for credit card pattern
class CardPatternPainter extends CustomPainter {
  final Color color;

  CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw circles
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      size.width * 0.25,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.05),
      size.width * 0.1,
      paint,
    );

    // Draw rounded rectangle
    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -size.width * 0.1,
        size.height * 0.65,
        size.width * 0.6,
        size.height * 0.5,
      ),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom formatter for card number
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String formattedText = '';
    int count = 0;

    for (int i = 0; i < newValue.text.length; i++) {
      if (count > 0 && count % 4 == 0 && count < 16) {
        formattedText += ' ';
      }
      formattedText += newValue.text[i];
      count++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// Custom formatter for expiry date
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String formattedText = newValue.text;
    if (formattedText.length > 2 && formattedText[2] != '/') {
      formattedText =
          '${formattedText.substring(0, 2)}/${formattedText.substring(2)}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class PaymentMethod {
  final String id;
  final String cardType;
  final String lastFourDigits;
  final String expiryDate;
  final String cardHolderName;
  final Color cardColor;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.cardType,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.isDefault,
    required this.cardHolderName,
    required this.cardColor,
  });
}
