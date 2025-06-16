// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'home.dart';
import 'search.dart';
import 'footer.dart';

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

// Unified Payment Screen - handles both card and cash payment methods
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        toolbarHeight: 50.0,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Payments',
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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

              // Show Cash or Card details based on selection
              if (_selectedPaymentMethod == 'cash')
                _buildCashPaymentDetailsCard()
              else
                _buildCardDetailsForm(),

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
      bottomNavigationBar: AppFooter(
        currentIndex: 1,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1 && index != 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
            const Text(
              'LKR 800.00',
              style: TextStyle(
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
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
      ),
    );
  }

  // CASH PAYMENT WIDGETS
  Widget _buildCashPaymentDetailsCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
                'LKR ${_splitPayment ? _amountPerPerson.toStringAsFixed(2) : "800.00"}',
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
                const Text(
                  'LKR 800.00',
                  style: TextStyle(
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
  Widget _buildCardDetailsForm() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Card Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDarkColor,
              ),
            ),
            const SizedBox(height: 20),

            // Cardholder Name
            const Text(
              'Cardholder Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textDarkColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField('Enter cardholder name'),
            const SizedBox(height: 16),

            // Card Number
            const Text(
              'Card Number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textDarkColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              '**** **** **** ****',
              keyboardType: TextInputType.number,
              suffixIcon: Icon(Icons.credit_card, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Expiry Date and CVV
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expiry Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'MM/YY',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CVV',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        '***',
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        suffixIcon: Icon(
                          Icons.info_outline,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Remember Card Checkbox
            _buildRememberCardCheckbox(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          suffixIcon: suffixIcon,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildRememberCardCheckbox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              value: _rememberCard,
              onChanged: (value) {
                setState(() {
                  _rememberCard = value ?? false;
                });
              },
              activeColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Remember this card for future payments',
            style: TextStyle(fontSize: 13, color: textDarkColor),
          ),
        ],
      ),
    );
  }

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

  Widget _buildPaySecurelyButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'PAY SECURELY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _calculateAmountPerPerson() {
    setState(() {
      _amountPerPerson = _splitPayment ? 800.0 / _numberOfPeople : 800.0;
    });
  }
}

// Payment Success Screen
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        toolbarHeight: 50.0,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Payments',
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
      bottomNavigationBar: AppFooter(
        currentIndex: 0,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildPaymentSummaryRow() {
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount Paid:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 2),
            Text(
              'LKR 800.00',
              style: TextStyle(
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
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.credit_card, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ComBank Digital Debit Card',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textDarkColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'XXXX XXXX XXXX 4590',
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
              // Navigate back to home screen
              Navigator.of(context).popUntil((route) => route.isFirst);
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
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Payment Summary',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 8, 8),
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
      backgroundColor: backgroundColor,
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

              // Selected Services - moved before pricing for logical flow
              _buildSelectedServicesCard(),
              const SizedBox(height: 16),

              // Pricing Summary - at the end as the conclusion
              _buildPricingSummaryCard(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 0,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Card(
      elevation: 0,
      color: backgroundColor,
      child: Padding(
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
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _buildSelectedServicesCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDarkColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildServiceRow('Venue Rental (2 hours)', '\$70.00', true),
            const Divider(height: 1, thickness: 0.5),
            _buildServiceRow('Equipment Rental', '\$10.00', true),
            const Divider(height: 1, thickness: 0.5),
            _buildServiceRow('Professional Coach', '\$45.00', false),
            const Divider(height: 1, thickness: 0.5),
            _buildServiceRow('Shower Access', '\$5.00', true),
            const Divider(height: 1, thickness: 0.5),
            _buildServiceRow('Video Recording', '\$25.00', false),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummaryCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            _buildPriceRow('Venue Rental (2 hours)', '\$70.00'),
            _buildPriceRow('Equipment Rental', '\$10.00'),
            _buildPriceRow('Shower Access', '\$5.00'),
            _buildPriceRow('Service Fee', '\$5.00'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 1),
            ),
            _buildPriceRow('Total', '\$90.00', isTotal: true),
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
                  MaterialPageRoute(
                    builder: (context) => const PaymentScreen(),
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
                  const Icon(Icons.lock_outline, size: 16, color: primaryColor),
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

  Widget _buildServiceRow(String title, String price, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? textDarkColor : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? primaryColor : Colors.grey.shade500,
            ),
          ),
        ],
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
