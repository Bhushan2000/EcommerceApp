import 'package:flutter/material.dart';

/// Enum representing all supported payment methods in the application
enum PaymentMethodType {
  card,
  upi,
  wallets,
  netBanking,
  cod,
  bnpl,
}

extension PaymentMethodTypeExtension on PaymentMethodType {
  String get id {
    switch (this) {
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.upi:
        return 'upi';
      case PaymentMethodType.wallets:
        return 'wallets';
      case PaymentMethodType.netBanking:
        return 'net_banking';
      case PaymentMethodType.cod:
        return 'cod';
      case PaymentMethodType.bnpl:
        return 'bnpl';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethodType.card:
        return 'Credit / Debit Card';
      case PaymentMethodType.upi:
        return 'UPI / QR Payment';
      case PaymentMethodType.wallets:
        return 'Digital Wallets & One-Tap';
      case PaymentMethodType.netBanking:
        return 'Net Banking';
      case PaymentMethodType.cod:
        return 'Cash on Delivery';
      case PaymentMethodType.bnpl:
        return 'Buy Now Pay Later (EMI)';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethodType.card:
        return 'Visa, Mastercard, Amex, RuPay';
      case PaymentMethodType.upi:
        return 'Google Pay, PhonePe, Paytm, BHIM';
      case PaymentMethodType.wallets:
        return 'Apple Pay, Google Wallet, Aura Pay';
      case PaymentMethodType.netBanking:
        return 'All Major Indian & International Banks';
      case PaymentMethodType.cod:
        return 'Pay cash or card upon package delivery';
      case PaymentMethodType.bnpl:
        return 'Split into 3 monthly installments at 0% fee';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.card:
        return Icons.credit_card_rounded;
      case PaymentMethodType.upi:
        return Icons.qr_code_scanner_rounded;
      case PaymentMethodType.wallets:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethodType.netBanking:
        return Icons.account_balance_rounded;
      case PaymentMethodType.cod:
        return Icons.local_atm_rounded;
      case PaymentMethodType.bnpl:
        return Icons.calendar_month_rounded;
    }
  }

  String? get badgeText {
    switch (this) {
      case PaymentMethodType.card:
        return null;
      case PaymentMethodType.upi:
        return 'Instant 0% Fee';
      case PaymentMethodType.wallets:
        return 'Fastest';
      case PaymentMethodType.netBanking:
        return null;
      case PaymentMethodType.cod:
        return null;
      case PaymentMethodType.bnpl:
        return '0% Interest';
    }
  }
}

/// Domain entity holding specific details entered for a chosen payment method
class PaymentDetails {
  final PaymentMethodType methodType;

  // Card details
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  final String? cvv;

  // UPI details
  final String? upiId;

  // Wallet details
  final String? walletName;

  // Net banking details
  final String? bankName;

  // BNPL details
  final int installmentsCount;

  // COD confirmation
  final bool codConfirmed;

  const PaymentDetails({
    required this.methodType,
    this.cardNumber,
    this.cardHolder,
    this.expiryDate,
    this.cvv,
    this.upiId,
    this.walletName,
    this.bankName,
    this.installmentsCount = 3,
    this.codConfirmed = true,
  });

  String get summaryDescription {
    switch (methodType) {
      case PaymentMethodType.card:
        if (cardNumber != null && cardNumber!.length >= 4) {
          final last4 = cardNumber!.replaceAll(' ', '').trim();
          final visibleLast4 = last4.length > 4 ? last4.substring(last4.length - 4) : last4;
          return 'Card ending in •••• $visibleLast4';
        }
        return 'Credit / Debit Card';
      case PaymentMethodType.upi:
        return upiId?.isNotEmpty == true ? 'UPI ($upiId)' : 'UPI Payment';
      case PaymentMethodType.wallets:
        return walletName ?? 'Digital Wallet';
      case PaymentMethodType.netBanking:
        return bankName != null ? 'Net Banking ($bankName)' : 'Net Banking';
      case PaymentMethodType.cod:
        return 'Cash on Delivery';
      case PaymentMethodType.bnpl:
        return 'Aura Pay Later ($installmentsCount installments)';
    }
  }
}

/// Validation result contract
class PaymentValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PaymentValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory PaymentValidationResult.success() => const PaymentValidationResult(isValid: true);
  factory PaymentValidationResult.failure(String message) =>
      PaymentValidationResult(isValid: false, errorMessage: message);
}

/// Immutable record of a processed payment transaction
class PaymentTransactionResult {
  final bool isSuccess;
  final String transactionId;
  final String message;
  final PaymentMethodType methodType;
  final double amount;
  final DateTime timestamp;

  const PaymentTransactionResult({
    required this.isSuccess,
    required this.transactionId,
    required this.message,
    required this.methodType,
    required this.amount,
    required this.timestamp,
  });
}
