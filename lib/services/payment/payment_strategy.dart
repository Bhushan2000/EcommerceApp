import 'dart:math';
import 'package:uuid/uuid.dart';
import 'payment_method_model.dart';

/// Abstract payment strategy following Strategy Pattern and SOLID Open/Closed Principle.
abstract class PaymentStrategy {
  PaymentMethodType get type;
  String get name => type.displayName;
  String get subtitle => type.subtitle;
  String? get badgeText => type.badgeText;

  /// Validates specific credentials or inputs for this payment strategy
  PaymentValidationResult validate(PaymentDetails details);

  /// Executes the transaction logic (asynchronous processor simulation or API bridge)
  Future<PaymentTransactionResult> executePayment({
    required PaymentDetails details,
    required double amount,
  });
}

/// Strategy for Credit and Debit Card payments
class CardPaymentStrategy implements PaymentStrategy {
  @override
  PaymentMethodType get type => PaymentMethodType.card;
  @override
  String get name => type.displayName;
  @override
  String get subtitle => type.subtitle;
  @override
  String? get badgeText => type.badgeText;

  @override
  PaymentValidationResult validate(PaymentDetails details) {
    final rawNumber = details.cardNumber?.replaceAll(' ', '').trim() ?? '';
    if (rawNumber.length < 15 || rawNumber.length > 19) {
      return PaymentValidationResult.failure('Enter a valid 16-digit card number');
    }

    if (details.cardHolder == null || details.cardHolder!.trim().isEmpty) {
      return PaymentValidationResult.failure('Enter the cardholder name');
    }

    final expiry = details.expiryDate?.trim() ?? '';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(expiry)) {
      return PaymentValidationResult.failure('Enter valid expiry in MM/YY format');
    }

    final cvv = details.cvv?.trim() ?? '';
    if (cvv.length < 3 || cvv.length > 4) {
      return PaymentValidationResult.failure('Enter a valid 3 or 4 digit CVV');
    }

    return PaymentValidationResult.success();
  }

  @override
  Future<PaymentTransactionResult> executePayment({
    required PaymentDetails details,
    required double amount,
  }) async {
    // Simulate tokenized gateway encryption delay
    await Future.delayed(const Duration(milliseconds: 900));

    final txId = 'TXN-CARD-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    return PaymentTransactionResult(
      isSuccess: true,
      transactionId: txId,
      message: 'Card authorized successfully via 256-bit SSL encryption',
      methodType: type,
      amount: amount,
      timestamp: DateTime.now(),
    );
  }
}

/// Strategy for Unified Payments Interface (UPI) & QR payments
class UpiPaymentStrategy implements PaymentStrategy {
  @override
  PaymentMethodType get type => PaymentMethodType.upi;
  @override
  String get name => type.displayName;
  @override
  String get subtitle => type.subtitle;
  @override
  String? get badgeText => type.badgeText;

  @override
  PaymentValidationResult validate(PaymentDetails details) {
    final upiId = details.upiId?.trim() ?? '';
    if (upiId.isEmpty) {
      return PaymentValidationResult.failure('Please enter your UPI ID');
    }
    if (!upiId.contains('@') || upiId.endsWith('@')) {
      return PaymentValidationResult.failure('Enter valid UPI ID (e.g. mobile@okaxis / user@paytm)');
    }
    return PaymentValidationResult.success();
  }

  @override
  Future<PaymentTransactionResult> executePayment({
    required PaymentDetails details,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final txId = 'TXN-UPI-${Random().nextInt(900000) + 100000}';
    return PaymentTransactionResult(
      isSuccess: true,
      transactionId: txId,
      message: 'Instant UPI debit approved via NPCI gateway',
      methodType: type,
      amount: amount,
      timestamp: DateTime.now(),
    );
  }
}

/// Strategy for Digital Wallets (Apple Pay, Google Wallet, Express Wallet)
class WalletPaymentStrategy implements PaymentStrategy {
  @override
  PaymentMethodType get type => PaymentMethodType.wallets;
  @override
  String get name => type.displayName;
  @override
  String get subtitle => type.subtitle;
  @override
  String? get badgeText => type.badgeText;

  @override
  PaymentValidationResult validate(PaymentDetails details) {
    if (details.walletName == null || details.walletName!.trim().isEmpty) {
      return PaymentValidationResult.failure('Select an active digital wallet');
    }
    return PaymentValidationResult.success();
  }

  @override
  Future<PaymentTransactionResult> executePayment({
    required PaymentDetails details,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final txId = 'TXN-WLT-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    return PaymentTransactionResult(
      isSuccess: true,
      transactionId: txId,
      message: '${details.walletName ?? "Digital Wallet"} 1-Tap payment authorized',
      methodType: type,
      amount: amount,
      timestamp: DateTime.now(),
    );
  }
}

/// Strategy for Net Banking payments
class NetBankingPaymentStrategy implements PaymentStrategy {
  @override
  PaymentMethodType get type => PaymentMethodType.netBanking;
  @override
  String get name => type.displayName;
  @override
  String get subtitle => type.subtitle;
  @override
  String? get badgeText => type.badgeText;

  @override
  PaymentValidationResult validate(PaymentDetails details) {
    if (details.bankName == null || details.bankName!.trim().isEmpty) {
      return PaymentValidationResult.failure('Please choose your bank for Net Banking');
    }
    return PaymentValidationResult.success();
  }

  @override
  Future<PaymentTransactionResult> executePayment({
    required PaymentDetails details,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final txId = 'TXN-NETB-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    return PaymentTransactionResult(
      isSuccess: true,
      transactionId: txId,
      message: 'Bank authorization confirmed from ${details.bankName}',
      methodType: type,
      amount: amount,
      timestamp: DateTime.now(),
    );
  }
}

/// Strategy for Cash on Delivery (COD)
class CodPaymentStrategy implements PaymentStrategy {
  @override
  PaymentMethodType get type => PaymentMethodType.cod;
  @override
  String get name => type.displayName;
  @override
  String get subtitle => type.subtitle;
  @override
  String? get badgeText => type.badgeText;

  @override
  PaymentValidationResult validate(PaymentDetails details) {
    if (!details.codConfirmed) {
      return PaymentValidationResult.failure('Please confirm your Cash on Delivery readiness');
    }
    return PaymentValidationResult.success();
  }

  @override
  Future<PaymentTransactionResult> executePayment({
    required PaymentDetails details,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final txId = 'COD-ORDER-${Random().nextInt(900000) + 100000}';
    return PaymentTransactionResult(
      isSuccess: true,
      transactionId: txId,
      message: 'Cash on Delivery confirmed. Prepare exact cash or digital UPI on package arrival.',
      methodType: type,
      amount: amount,
      timestamp: DateTime.now(),
    );
  }
}

/// Strategy for Buy Now Pay Later (BNPL) / 0% Interest Installments
class BnplPaymentStrategy implements PaymentStrategy {
  @override
  PaymentMethodType get type => PaymentMethodType.bnpl;
  @override
  String get name => type.displayName;
  @override
  String get subtitle => type.subtitle;
  @override
  String? get badgeText => type.badgeText;

  @override
  PaymentValidationResult validate(PaymentDetails details) {
    if (details.installmentsCount < 1 || details.installmentsCount > 12) {
      return PaymentValidationResult.failure('Choose a valid installment tenure');
    }
    return PaymentValidationResult.success();
  }

  @override
  Future<PaymentTransactionResult> executePayment({
    required PaymentDetails details,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final monthly = (amount / details.installmentsCount).toStringAsFixed(2);
    final txId = 'BNPL-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    return PaymentTransactionResult(
      isSuccess: true,
      transactionId: txId,
      message:
          '0% EMI approved. First installment of \$$monthly due in 30 days.',
      methodType: type,
      amount: amount,
      timestamp: DateTime.now(),
    );
  }
}
