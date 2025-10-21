import 'dart:convert';

import 'package:fairnestui/components/OutstandingBalanceCard.dart';
import 'package:fairnestui/components/TransactionCard.dart';
import 'package:fairnestui/components/UpcomingPaymentCard.dart';
import 'package:fairnestui/components/SecondaryButton.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_service.dart';
import 'package:fairnestui/services/notification_service.dart';
import 'package:fairnestui/widgets/celebration_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class Financepage extends StatefulWidget {
  const Financepage({super.key});

  @override
  State<Financepage> createState() => _FinancepageState();
}

class _FinancepageState extends State<Financepage> {
  bool _loading = true;
  String? _error;

  // Monthly snapshot data
  int _totalPaidByMe = 0;
  int _totalOwedToMe = 0;
  int _totalOwedByMe = 0;

  // Outstanding balances
  List<_OutstandingBalance> _outstandingBalances = [];

  // Upcoming payments
  List<_UpcomingPayment> _upcomingPayments = [];

  // Transaction history
  List<_Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadAllFinanceData();
  }

  Future<void> _loadAllFinanceData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = await UserService.getUserIdFromToken();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Fetch all data in parallel
      await Future.wait([
        _fetchMonthlySnapshot(userId),
        _fetchOutstandingBalances(userId),
        _fetchUpcomingPayments(userId),
        _fetchTransactionHistory(userId),
      ]);

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading finance data: $e');
      }
      setState(() {
        _error = 'Failed to load finance data';
        _loading = false;
      });
    }
  }

  Future<void> _fetchMonthlySnapshot(int userId) async {
    try {
      final response = await ApiClient.get(
        '/GetMyMonthlySnapshotByUserID/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _totalPaidByMe = data['total_paid_by_me'] as int? ?? 0;
          _totalOwedToMe = data['total_owed_to_me'] as int? ?? 0;
          _totalOwedByMe = data['total_owed_by_me'] as int? ?? 0;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching monthly snapshot: $e');
      }
    }
  }

  Future<void> _fetchOutstandingBalances(int userId) async {
    try {
      final response = await ApiClient.get(
        '/FetchAllOutstandingBalancesByUserID/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;

        setState(() {
          _outstandingBalances = data
              .map((json) =>
                  _OutstandingBalance.fromJson(json as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching outstanding balances: $e');
      }
    }
  }

  Future<void> _fetchUpcomingPayments(int userId) async {
    try {
      final response = await ApiClient.get(
        '/FetchAllUpcomingPaymentByUserID/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final payments = data
            .map((json) =>
                _UpcomingPayment.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by due date (earliest first)
        payments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        setState(() {
          _upcomingPayments = payments;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching upcoming payments: $e');
      }
    }
  }

  Future<void> _fetchTransactionHistory(int userId) async {
    try {
      final response = await ApiClient.get(
        '/FetchAllPaidTransactionHistoryByUserID/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        setState(() {
          _transactions = data
              .map(
                  (json) => _Transaction.fromJson(json as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching transaction history: $e');
      }
    }
  }

  Future<void> _handleBalanceCardTap(_OutstandingBalance balance) async {
    if (kDebugMode) {
      print(
          '🔔 Card tapped: ${balance.username}, Status: ${balance.balanceStatus}');
    }

    // Only show reminder option for "Owes You" status
    if (balance.balanceStatus != 'You Are Owed') {
      if (kDebugMode) {
        print('⚠️ Not "You Are Owed" status, skipping reminder');
      }
      return;
    }

    if (kDebugMode) {
      print('📱 Showing reminder dialog...');
    }

    // Show custom reminder dialog (without auto-notification)
    final shouldSendReminder =
        await _showCustomReminderDialog(balance.username);

    if (kDebugMode) {
      print('💭 User response: $shouldSendReminder');
    }

    // If user clicked "Yes!", send the notification
    if (shouldSendReminder == true) {
      if (kDebugMode) {
        print('📤 Sending payment reminder...');
      }
      final success = await _sendPaymentReminder(balance);

      // Show notified dialog only if successful
      if (success && mounted) {
        if (kDebugMode) {
          print('✅ Showing success dialog');
        }
        await _showNotifiedDialog(balance.username);
      }
    }
  }

  Future<void> _handleUpcomingPaymentCardTap(_UpcomingPayment payment) async {
    if (kDebugMode) {
      print('💳 Upcoming payment card tapped: ${payment.titleName}');
    }

    // Show QR code dialog
    await _showQRCodeDialog(payment);
  }

  Future<void> _handleMarkAsPaid(_UpcomingPayment payment) async {
    if (kDebugMode) {
      print('✅ Marking payment as paid: ${payment.titleName}');
    }

    // Track if dialog is showing to prevent multiple pop attempts
    bool dialogShowing = true;

    // Show loading dialog with a specific route name
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        routeSettings: const RouteSettings(name: 'payment_verification_dialog'),
        builder: (dialogContext) => const PopScope(
          canPop: false, // Prevent back button from closing
          child: Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Verifying payment...'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).then((_) {
        dialogShowing = false;
      });
    }

    try {
      // Poll the payment status with timeout protection
      final isSucceeded =
          await _pollPaymentStatusWithTimeout(payment.transactionId);

      if (!mounted) return; // ✅ Add this extra safety check

      // Only try to pop if dialog is still showing and context is still mounted
      if (mounted && dialogShowing) {
        // Check if we can pop and if the current route is our dialog
        if (Navigator.of(context).canPop()) {
          // Use careful navigation to only pop the dialog
          Navigator.of(context).popUntil((route) {
            // Stop popping when we reach a route that's not our dialog
            return route.settings.name != 'payment_verification_dialog';
          });
        }
        dialogShowing = false;
      }

      if (isSucceeded && mounted) {
        // Small delay to ensure dialog is fully closed
        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;

        CelebrationPopup.show(
          context,
          message: 'Payment Verified!\nWell done! 💰',
          backgroundColor: const Color(0xFFF8F9FA),
          textColor: const Color(0xFF2D3748),
          autoCloseDuration: const Duration(seconds: 2),
        );

        // Refresh the data
        await _loadAllFinanceData();
      } else if (mounted) {
        // Show timeout message instead of throwing error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment verification timed out. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in payment verification: $e');
      }

      // Safely close dialog if still open
      if (mounted && dialogShowing) {
        if (Navigator.of(context).canPop()) {
          // Check if the dialog route is on top before popping
          Navigator.of(context).popUntil((route) {
            return route.settings.name != 'payment_verification_dialog';
          });
        }
        dialogShowing = false;
      }

      if (mounted) {
        // Show user-friendly error message
        String errorMessage = 'Payment verification failed';
        if (e.toString().contains('timeout')) {
          errorMessage = 'Payment verification timed out. Please try again.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

// Add this new method for polling with timeout protection
  Future<bool> _pollPaymentStatusWithTimeout(int transactionId) async {
    try {
      // Use Future.any to race between polling and a timeout
      return await Future.any([
        _performPaymentPolling(transactionId),
        Future.delayed(
          const Duration(seconds: 35), // Slightly longer than 30 seconds
          () => false, // Return false on timeout
        ),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Polling failed with error: $e');
      }
      return false;
    }
  }

// Separate the actual polling logic
  Future<bool> _performPaymentPolling(int transactionId) async {
    const maxAttempts = 15; // 15 attempts × 2 seconds = 30 seconds
    int attempts = 0;

    while (attempts < maxAttempts) {
      // Check if widget is still mounted
      if (!mounted) {
        if (kDebugMode) {
          print('⚠️ Widget unmounted, stopping payment polling');
        }
        return false;
      }

      try {
        if (kDebugMode) {
          print(
              '🔄 Polling payment status (attempt ${attempts + 1}/$maxAttempts)');
        }

        final response = await ApiClient.get(
          '/GetPaymentStatusByTransactionID/$transactionId',
        ).timeout(
          const Duration(seconds: 5), // Timeout for individual requests
          onTimeout: () {
            throw Exception('Request timeout');
          },
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final status = data['status'] as String?;

          if (kDebugMode) {
            print('📊 Payment status: $status');
          }

          if (status == 'succeeded') {
            if (kDebugMode) {
              print('✅ Payment succeeded!');
            }
            return true;
          }

          // Check for terminal states to stop polling early
          if (status == 'failed' ||
              status == 'cancelled' ||
              status == 'refunded') {
            if (kDebugMode) {
              print('❌ Payment terminated with status: $status');
            }
            return false;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(
              '⚠️ Error polling payment status (attempt ${attempts + 1}): $e');
        }
        // Continue polling even on error (API might be temporarily unavailable)
      }

      attempts++;

      // Wait before next attempt (unless it's the last attempt)
      if (attempts < maxAttempts && mounted) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (kDebugMode) {
      print('❌ Payment status polling completed without success');
    }
    return false;
  }

// Keep the existing _pollPaymentStatus method but update it to use the new implementation

  Future<bool?> _showCustomReminderDialog(String name) {
    const cardSize = Size(382, 247);
    const bgColor = Color(0xFFECE9E6);
    const accent = Color(0xFF645A80);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Dialog(
          elevation: 10,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: cardSize.width,
            height: cardSize.height,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    color: Colors.black.withValues(alpha: .15),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/notifications-sound.png',
                    width: 56,
                    height: 56,
                    color: accent,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  Text(
                    'Do you want to send $name a Reminder?',
                    textAlign: TextAlign.center,
                    style: AppFonts.heading3.copyWith(color: accent),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'No',
                          onPressed: () => Navigator.of(context).pop(false),
                          width: double.infinity,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          text: 'Yes!',
                          backgroundColor: const Color(0xFF6CC08B),
                          textColor: Colors.white,
                          width: double.infinity,
                          height: 48,
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchPaymentLink(String paymentLink) async {
    try {
      final Uri url = Uri.parse(paymentLink);

      if (kDebugMode) {
        print('🔗 Attempting to launch payment link: $paymentLink');
      }

      // First check if the URL can be launched
      final canLaunch = await canLaunchUrl(url);

      if (kDebugMode) {
        print('🔗 Can launch URL: $canLaunch');
      }

      if (canLaunch) {
        // Launch the URL in external browser
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Opens in external browser
        );

        if (kDebugMode) {
          print('🔗 URL launched successfully: $launched');
        }

        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open payment link'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // If can't launch, show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open payment link'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error launching payment link: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
// Update the _showQRCodeDialog method in Financepage class
// Replace the existing _showQRCodeDialog method with this updated version:

  Future<void> _showQRCodeDialog(_UpcomingPayment payment) {
    const bgColor = Color(0xFFECE9E6);
    const accent = Color(0xFF645A80);

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
        child: Dialog(
          elevation: 10,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  color: Colors.black.withValues(alpha: .15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          payment.titleName,
                          style: AppFonts.heading3.copyWith(color: accent),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(Icons.close_rounded,
                              size: 24, color: accent),
                        ),
                      ),
                    ],
                  ),
                ),
                // QR Code
                if (payment.qrCodeImage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent, width: 2),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.memory(
                        _base64ToImage(payment.qrCodeImage!),
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No QR code available',
                      style: TextStyle(color: accent),
                    ),
                  ),
                // Payment details
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    children: [
                      Text(
                        'Amount: ${payment.totalAmount} THB',
                        style: const TextStyle(
                          color: accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Due: ${_formatDueDate(payment.dueDate)}',
                        style: TextStyle(
                          color: accent.withValues(alpha: .7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Payment Link Button (NEW ADDITION)
                if (payment.paymentLink != null &&
                    payment.paymentLink!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _launchPaymentLink(payment.paymentLink!),
                        icon: const Icon(Icons.open_in_new, size: 20),
                        label: const Text('Open Payment Link'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: const BorderSide(color: accent, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(),
                          width: double.infinity,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          text: 'Verify',
                          backgroundColor: const Color(0xFF6CC08B),
                          textColor: Colors.white,
                          width: double.infinity,
                          height: 48,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _handleMarkAsPaid(payment);
                          },
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
    );
  }

  Future<void> _showNotifiedDialog(String name) {
    const notifSize = Size(284, 193);
    const bgColor = Color(0xFFECE9E6);
    const accent = Color(0xFF645A80);

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
        child: Dialog(
          elevation: 10,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: notifSize.width,
            height: notifSize.height,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    color: Colors.black.withValues(alpha: .12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child:
                            Icon(Icons.close_rounded, size: 22, color: accent),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/mail-notification.png',
                          width: 56,
                          height: 56,
                          color: accent,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$name has been notified!',
                          textAlign: TextAlign.center,
                          style: AppFonts.heading3.copyWith(color: accent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _sendPaymentReminder(_OutstandingBalance balance) async {
    try {
      if (kDebugMode) {
        print('📤 Sending payment reminder to ${balance.username}...');
      }

      final message =
          'Payment reminder: You owe ${balance.netBalance.abs()} THB';

      // Use NotificationService to create notification
      final result = await NotificationService.createNotification(
        receiverId: balance.userId,
        message: message,
      );

      if (result != null) {
        if (kDebugMode) {
          print('✅ Reminder sent successfully');
        }
        return true;
      } else {
        throw Exception('Failed to send notification');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error sending reminder: $e');
        print('📚 Stack trace: $stackTrace');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reminder: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return false;
    }
  }

  // Helper method to convert base64 string to image bytes
  Uint8List _base64ToImage(String base64String) {
    // Remove data:image/png;base64, prefix if present
    final base64Data =
        base64String.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
    return base64Decode(base64Data);
  }

  String _formatDueDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAllFinanceData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadAllFinanceData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Finance",
                  style:
                      AppFonts.heading1.copyWith(color: AppColors.textPurple),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Text(
                    "My Monthly Snapshot",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPurple,
                    ),
                  ),
                ),
                MonthlySnapshotCard(
                  paid: _totalPaidByMe,
                  owed: _totalOwedToMe,
                  youOwe: _totalOwedByMe,
                  currency: 'THB',
                ),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Text(
                    "Outstanding Balances",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPurple,
                    ),
                  ),
                ),

                // Outstanding Balances Section
                if (_outstandingBalances.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No outstanding balances',
                      style: TextStyle(
                        color: AppColors.textPurple,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        for (int i = 0;
                            i < _outstandingBalances.length;
                            i++) ...[
                          Builder(
                            builder: (context) {
                              final balance = _outstandingBalances[i];
                              final isOwedToYou =
                                  balance.balanceStatus == 'You Are Owed';

                              // Only make it tappable for "Owes You" cards
                              if (isOwedToYou) {
                                return InkWell(
                                  onTap: () {
                                    if (kDebugMode) {
                                      print('👆 Tap detected on card $i');
                                    }
                                    _handleBalanceCardTap(balance);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: IgnorePointer(
                                    child: OutstandingBalanceCard(
                                      name: balance.username,
                                      amount: balance.netBalance.abs(),
                                      currency: 'THB',
                                      avatar: balance.userPicture != null
                                          ? NetworkImage(balance.userPicture!)
                                          : const AssetImage(
                                                  'assets/images/char.png')
                                              as ImageProvider,
                                      status: BalanceStatus.owedToYou,
                                      width: 140,
                                    ),
                                  ),
                                );
                              } else {
                                // "You Owe" cards - completely non-interactive
                                return IgnorePointer(
                                  child: OutstandingBalanceCard(
                                    name: balance.username,
                                    amount: balance.netBalance.abs(),
                                    currency: 'THB',
                                    avatar: balance.userPicture != null
                                        ? NetworkImage(balance.userPicture!)
                                        : const AssetImage(
                                                'assets/images/char.png')
                                            as ImageProvider,
                                    status: BalanceStatus.youOwe,
                                    width: 140,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 14),
                        ],
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                const SizedBox(height: 25),

                // Upcoming Payments Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Upcoming Payments",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CountChip(value: _upcomingPayments.length),
                    ],
                  ),
                ),

                if (_upcomingPayments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No upcoming payments',
                      style: TextStyle(
                        color: AppColors.textPurple,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        for (int i = 0; i < _upcomingPayments.length; i++)
                          GestureDetector(
                            onTap: () {
                              if (kDebugMode) {
                                print('💳 Payment card $i tapped');
                              }
                              _handleUpcomingPaymentCardTap(
                                  _upcomingPayments[i]);
                            },
                            child: UpcomingPaymentCard(
                              title: _upcomingPayments[i].titleName,
                              amount: _upcomingPayments[i].totalAmount,
                              daysLeft: _upcomingPayments[i].daysLeft,
                              trailingPad:
                                  (i == _upcomingPayments.length - 1) ? 4 : 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 25),

                // Transaction History Section
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Text(
                    "Transaction History",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPurple,
                    ),
                  ),
                ),

                if (_transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No transaction history',
                      style: TextStyle(
                        color: AppColors.textPurple,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  Column(
                    children: _transactions.map((transaction) {
                      return TransactionCard(
                        category: transaction.category,
                        date: transaction.formattedDate,
                        amount: 'THB ${transaction.totalAmount}',
                        paidTo: 'Paid to ${transaction.paidToUsername}',
                        points: 0, // Points not provided by API
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ Data Models ============

class _OutstandingBalance {
  final int userId;
  final String username;
  final String? userPicture;
  final int netBalance;
  final String balanceStatus;

  _OutstandingBalance({
    required this.userId,
    required this.username,
    this.userPicture,
    required this.netBalance,
    required this.balanceStatus,
  });

  factory _OutstandingBalance.fromJson(Map<String, dynamic> json) {
    return _OutstandingBalance(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      userPicture: json['user_picture'] as String?,
      netBalance: json['net_balance'] as int,
      balanceStatus: json['balance_status'] as String,
    );
  }
}

class _UpcomingPayment {
  final int financeId;
  final int transactionId;
  final String titleName;
  final DateTime dueDate;
  final String category;
  final int totalAmount;
  final bool transactionStatus;
  final String? qrCodeImage;
  final String? paymentLink;

  _UpcomingPayment({
    required this.financeId,
    required this.transactionId,
    required this.titleName,
    required this.dueDate,
    required this.category,
    required this.totalAmount,
    required this.transactionStatus,
    this.qrCodeImage,
    this.paymentLink,
  });

  factory _UpcomingPayment.fromJson(Map<String, dynamic> json) {
    return _UpcomingPayment(
      financeId: json['finance_id'] as int,
      transactionId: json['transaction_id'] as int,
      titleName: json['title_name'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      category: json['category'] as String,
      totalAmount: json['total_amount'] as int,
      transactionStatus: json['transaction_status'] as bool,
      qrCodeImage: json['qr_code_link_image'] as String?,
      paymentLink: json['payment_link'] as String?,
    );
  }

  int get daysLeft {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inDays;
  }
}

class _Transaction {
  final int financeId;
  final int transactionId;
  final String titleName;
  final String category;
  final int totalAmount;
  final bool transactionStatus;
  final DateTime paidAt;
  final int paidToUserId;
  final String paidToUsername;
  final String? paidToUserPicture;

  _Transaction({
    required this.financeId,
    required this.transactionId,
    required this.titleName,
    required this.category,
    required this.totalAmount,
    required this.transactionStatus,
    required this.paidAt,
    required this.paidToUserId,
    required this.paidToUsername,
    this.paidToUserPicture,
  });

  factory _Transaction.fromJson(Map<String, dynamic> json) {
    return _Transaction(
      financeId: json['finance_id'] as int,
      transactionId: json['transaction_id'] as int,
      titleName: json['title_name'] as String,
      category: json['category'] as String,
      totalAmount: json['total_amount'] as int,
      transactionStatus: json['transaction_status'] as bool,
      paidAt: DateTime.parse(json['paid_at'] as String),
      paidToUserId: json['paid_to_user_id'] as int,
      paidToUsername: json['paid_to_username'] as String,
      paidToUserPicture: json['paid_to_user_picture'] as String?,
    );
  }

  String get formattedDate {
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
      'December'
    ];
    return '${paidAt.day} ${months[paidAt.month - 1]} ${paidAt.year}';
  }
}

// ============ UI Components ============

class MonthlySnapshotCard extends StatelessWidget {
  const MonthlySnapshotCard({
    super.key,
    required this.paid,
    required this.owed,
    required this.youOwe,
    this.currency = 'THB',
    this.tileHeight = 100,
    this.tileWidth = 105,
    this.gap = 19,
    this.panelPadding = const EdgeInsets.all(12),
    this.panelRadius = 8,
  });

  final int paid;
  final int owed;
  final int youOwe;
  final String currency;

  final double tileHeight;
  final double? tileWidth;
  final double gap;
  final EdgeInsets panelPadding;
  final double panelRadius;

  @override
  Widget build(BuildContext context) {
    Widget buildTile(int value, String label, Color bg) {
      final tile = _SnapshotTile(
        value: value,
        currency: currency,
        label: label,
        bg: bg,
        height: tileHeight,
      );
      return tileWidth != null
          ? SizedBox(width: tileWidth, child: tile)
          : Expanded(child: tile);
    }

    return Container(
      padding: panelPadding,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E0D5),
        borderRadius: BorderRadius.circular(panelRadius),
        border: Border.all(color: AppColors.textPurple, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildTile(paid, 'Paid', const Color(0xFFE2BDD1)),
          SizedBox(width: gap),
          buildTile(owed, 'Owes You', AppColors.accent),
          SizedBox(width: gap),
          buildTile(youOwe, 'You Owe', const Color(0xFF9DCDAA)),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.value,
    required this.currency,
    required this.label,
    required this.bg,
    required this.height,
  });

  final int value;
  final String currency;
  final String label;
  final Color bg;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textPurple, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatWithCommas(value),
            style: const TextStyle(
              color: AppColors.textPurple,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const Text(
            'THB',
            style: TextStyle(
              color: AppColors.textPurple,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPurple,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatWithCommas(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buf.write(',');
        count = 0;
      }
    }
    return buf.toString().split('').reversed.join();
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.value,
    this.height = 22,
    this.radius = 6,
    this.fontSize = 12,
  });

  final int value;
  final double height;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.textPink,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
