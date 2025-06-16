// ignore_for_file: deprecated_member_use, unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

// Constants for consistent styling
const Color primaryColor = Color(0xFF1B2C4F);
const Color backgroundColor = Color(0xFFF5F6FA);
const Color textDarkColor = Color(0xFF2D3142);
const Color cardColor = Colors.white;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sports Venue Payment',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          background: const Color.fromARGB(255, 34, 51, 117),
        ),
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: const InvoiceScreen(),
    );
  }
}

// Placeholder for missing imports
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Home Screen')));
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Search Screen')));
  }
}

// Unified Payment Screen - handles payment methods and payment processing
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'card'; // Default to 'card'
  int _numberOfPeople = 4;
  double _amountPerPerson = 200.0;
  bool _splitPayment = false;
  bool _rememberCard = false;

  // Payment methods from the merged functionality
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

  PaymentMethod? _selectedCard;

  @override
  void initState() {
    super.initState();

    // Set default card if available
    if (_paymentMethods.isNotEmpty) {
      _selectedCard = _paymentMethods.firstWhere(
        (card) => card.isDefault,
        orElse: () => _paymentMethods.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        toolbarHeight: 50.0,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Payments',
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
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total amount card
              _buildTotalAmountCard(),
              const SizedBox(height: 20),

              // Payment Method Selection Card
              _buildPaymentMethodCard(),
              const SizedBox(height: 20),

              // Show Cash, Card selection, or Card details based on selection
              if (_selectedPaymentMethod == 'cash')
                _buildCashPaymentDetailsCard()
              else if (_selectedPaymentMethod == 'card' &&
                  _selectedCard == null)
                _buildSavedCardsSection()
              else if (_selectedPaymentMethod == 'card' &&
                  _selectedCard != null)
                _buildSelectedCardSection(),

              const SizedBox(height: 20),

              // Security note (only for card payments)
              if (_selectedPaymentMethod == 'card') _buildSecurityNote(),

              const SizedBox(height: 24),

              // Pay Button
              _buildPaySecurelyButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    // Mock booking data - in real app, this would be passed from booking screen
    const double hourlyRate = 700.0;
    const double serviceFee = 50.0;
    const int selectedHours = 2;
    const double total = (hourlyRate * selectedHours) + serviceFee;

    return Container(
      padding: const EdgeInsets.all(20.0),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textDarkColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Due Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'LKR ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedPaymentMethod == 'cash'
                ? 'Cash payment at venue'
                : 'Secure payment powered by Stripe',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textDarkColor,
            ),
          ),
          const SizedBox(height: 16),

          // Payment Method Selector
          Row(
            children: [
              // Cash Option
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'cash';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedPaymentMethod == 'cash'
                          ? primaryColor.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: _selectedPaymentMethod == 'cash'
                            ? primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.money,
                          size: 18,
                          color: _selectedPaymentMethod == 'cash'
                              ? primaryColor
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cash',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _selectedPaymentMethod == 'cash'
                                ? primaryColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Card Option
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'card';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedPaymentMethod == 'card'
                          ? primaryColor.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: _selectedPaymentMethod == 'card'
                            ? primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card,
                          size: 18,
                          color: _selectedPaymentMethod == 'card'
                              ? primaryColor
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Card',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _selectedPaymentMethod == 'card'
                                ? primaryColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CASH PAYMENT WIDGETS
  Widget _buildCashPaymentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cash Payment Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDarkColor,
              ),
            ),
            const SizedBox(height: 20),

            // Number of People Selector
            const Text(
              'Number of People',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textDarkColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_numberOfPeople > 1) {
                      setState(() {
                        _numberOfPeople--;
                        _calculateAmountPerPerson();
                      });
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove, color: primaryColor),
                  ),
                ),
                Container(
                  width: 60,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _numberOfPeople.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDarkColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _numberOfPeople++;
                      _calculateAmountPerPerson();
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: primaryColor),
                  ),
                ),
                const Spacer(),
                // Split Payment Toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _splitPayment,
                          onChanged: (value) {
                            setState(() {
                              _splitPayment = value ?? false;
                              _calculateAmountPerPerson();
                            });
                          },
                          activeColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Split payment',
                        style: TextStyle(fontSize: 13, color: textDarkColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount Per Person
            _buildAmountPerPersonSection(),
            const SizedBox(height: 24),

            // Payment Instructions
            _buildPaymentInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountPerPersonSection() {
    // Mock booking data
    const double hourlyRate = 700.0;
    const double serviceFee = 50.0;
    const int selectedHours = 2;
    const double totalAmount = (hourlyRate * selectedHours) + serviceFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _splitPayment ? 'Amount per person' : 'Total amount to pay',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textDarkColor,
                ),
              ),
              Text(
                'LKR ${_splitPayment ? (totalAmount / _numberOfPeople).toStringAsFixed(2) : totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          if (_splitPayment) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total payment ($_numberOfPeople people)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'LKR ${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textDarkColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please pay at the venue reception desk before your scheduled time. Bring exact change if possible.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // CARD PAYMENT WIDGETS
  Widget _buildSavedCardsSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saved Cards',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDarkColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addNewPaymentMethod,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add New'),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_paymentMethods.isEmpty)
              _buildEmptyCardsState()
            else
              _buildPaymentMethodsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCardsState() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.credit_card, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved cards',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a card to continue',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: _paymentMethods.map((method) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCard = method;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedCard?.id == method.id
                  ? primaryColor.withOpacity(0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedCard?.id == method.id
                    ? primaryColor
                    : Colors.grey.shade200,
                width: _selectedCard?.id == method.id ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 25,
                  decoration: BoxDecoration(
                    color: method.cardColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.credit_card, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${method.cardType} •••• ${method.lastFourDigits}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textDarkColor,
                        ),
                      ),
                      Text(
                        method.cardHolderName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (method.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 10,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editPaymentMethod(method);
                        break;
                      case 'delete':
                        _deletePaymentMethod(method);
                        break;
                      case 'default':
                        _setAsDefaultPaymentMethod(method);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!method.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 16),
                            SizedBox(width: 8),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedCardSection() {
    if (_selectedCard == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20.0),
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selected Card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDarkColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCard = null;
                    });
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Display selected card
            _buildCreditCardWidget(_selectedCard!),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardWidget(PaymentMethod method) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            method.cardColor,
            Color.lerp(method.cardColor, Colors.black, 0.3) ?? method.cardColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: method.cardColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.credit_card, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      method.cardType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                if (method.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
            const SizedBox(height: 16),
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
                        fontSize: 12,
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
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.expiryDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
    );
  }

  // SECURITY NOTE WIDGET
  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 18, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your payment information is secured with SSL encryption. We never store your card details.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateAmountPerPerson() {
    // Mock calculation with actual booking data
    const double hourlyRate = 700.0;
    const double serviceFee = 50.0;
    const int selectedHours = 2;
    const double totalAmount = (hourlyRate * selectedHours) + serviceFee;

    setState(() {
      _amountPerPerson = _splitPayment
          ? totalAmount / _numberOfPeople
          : totalAmount;
    });
  }

  Widget _buildPaySecurelyButton() {
    bool canPay =
        _selectedPaymentMethod == 'cash' ||
        (_selectedPaymentMethod == 'card' && _selectedCard != null);

    return ElevatedButton(
      onPressed: canPay
          ? () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const PaymentSuccessScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canPay ? primaryColor : Colors.grey,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            _selectedPaymentMethod == 'cash'
                ? 'CONFIRM BOOKING'
                : 'PAY SECURELY',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Add new payment method functionality
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
    String selectedCardType = 'Visa';
    final formKey = GlobalKey<FormState>();

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Simple drag handle
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
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
                        // Title
                        const Text(
                          'Add New Card',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Card type selection
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
                                onTap: () => setModalState(() {
                                  selectedCardType = 'Visa';
                                }),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCardTypeOption(
                                isSelected: selectedCardType == 'Mastercard',
                                cardType: 'Mastercard',
                                onTap: () => setModalState(() {
                                  selectedCardType = 'Mastercard';
                                }),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Form fields
                        _buildFormField(
                          'Card Number',
                          cardNumberController,
                          '1234 5678 9012 3456',
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Cardholder Name',
                          cardHolderController,
                          'John Doe',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                'Expiry',
                                expiryDateController,
                                'MM/YY',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                'CVV',
                                cvvController,
                                '123',
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
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
                                  _paymentMethods.add(
                                    PaymentMethod(
                                      id: DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                      cardType: selectedCardType,
                                      lastFourDigits:
                                          cardNumberController.text.length >= 4
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
                                      cardHolderName: cardHolderController.text,
                                      cardColor: randomColor,
                                    ),
                                  );
                                  if (_paymentMethods.length == 1) {
                                    _selectedCard = _paymentMethods.first;
                                  }
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Card added successfully',
                                    ),
                                    backgroundColor: Colors.green.shade600,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            child: const Text(
                              'Save Card',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
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

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textDarkColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCardTypeOption({
    required bool isSelected,
    required String cardType,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              color: isSelected ? const Color(0xFF1B2C4F) : Colors.grey,
              size: 20,
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

  void _editPaymentMethod(PaymentMethod method) {
    // Implementation for editing payment method
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality would be implemented here'),
      ),
    );
  }

  void _deletePaymentMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Card'),
        content: const Text('Are you sure you want to remove this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _paymentMethods.removeWhere((m) => m.id == method.id);
                if (_selectedCard?.id == method.id) {
                  _selectedCard = _paymentMethods.isNotEmpty
                      ? _paymentMethods.first
                      : null;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card removed successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${method.cardType} ending in ${method.lastFourDigits} set as default',
        ),
      ),
    );
  }
}

// Payment Success Screen
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        toolbarHeight: 50.0,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Payments',
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
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor, width: 4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 60, color: primaryColor),
                ),
                const SizedBox(height: 24),

                // Success Message
                const Text(
                  'Payment Successful',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Divider with yellow progress indicator
                Column(
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

                // Payment Details Text
                const Text(
                  'Your payment details are given below for your further reference.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Payment Summary
                _buildPaymentSummaryRow(),
                const SizedBox(height: 16),

                // Payment Method
                _buildPaymentMethodRow(),
                const SizedBox(height: 40),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryRow() {
    // Mock booking data
    const double hourlyRate = 700.0;
    const double serviceFee = 50.0;
    const int selectedHours = 2;
    const double total = (hourlyRate * selectedHours) + serviceFee;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.green, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Amount Paid:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              'LKR ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDarkColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.credit_card, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visa Card',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textDarkColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'XXXX XXXX XXXX 4242',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Share receipt logic
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Share',
              style: TextStyle(
                color: textDarkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to home screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Go to home',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Invoice/Pricing Summary Screen
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1B2C4F),
      toolbarHeight: 50.0,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Payment Summary',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice number and date
              _buildInvoiceHeader(),
              const SizedBox(height: 16),

              // Booking Details
              _buildBookingDetailsCard(),
              const SizedBox(height: 16),

              // Pricing Summary
              _buildPricingSummaryCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Invoice #78921',
            style: TextStyle(
              color: textDarkColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Today, ${DateTime.now().toString().substring(0, 10)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDarkColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Confirmed',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Venue image/icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: primaryColor.withOpacity(0.1),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sports_soccer,
                      size: 30,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CR7 Futsal Arena',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, 'Downtown, 2.5 km'),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        '11 Dec 2024, 10:00 - 12:00',
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.people_outline,
                        'Capacity: 10-12 players',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildPricingSummaryCard(BuildContext context) {
    // Mock booking data
    const double hourlyRate = 700.0;
    const double serviceFee = 50.0;
    const int selectedHours = 2;
    const double subtotal = hourlyRate * selectedHours;
    const double total = subtotal + serviceFee;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pricing Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDarkColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildPriceRow(
              'Venue Rental (${selectedHours}h)',
              'LKR ${subtotal.toStringAsFixed(2)}',
            ),
            _buildPriceRow(
              'Service Fee',
              'LKR ${serviceFee.toStringAsFixed(2)}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 1),
            ),
            _buildPriceRow(
              'Total',
              'LKR ${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Payment required to confirm your booking. Cancellations are free up to 24 hours before your slot.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PaymentScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    'Secure payment powered by Stripe',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String title, String price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: isTotal ? primaryColor : textDarkColor,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? primaryColor : textDarkColor,
            ),
          ),
        ],
      ),
    );
  }
}

// PaymentMethod class
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
