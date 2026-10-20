import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/services/payment/payment_method_model.dart';
import 'package:ecommerce_app/services/payment/payment_processor.dart';
import 'package:ecommerce_app/services/payment/payment_strategy.dart';

void main() {
  group('Clean Architecture Payment Strategies & SOLID Tests', () {
    test('CardPaymentStrategy validates card number, expiry, and CVV strictly', () {
      final strategy = CardPaymentStrategy();

      // Invalid card number
      final invalidCard = strategy.validate(const PaymentDetails(
        methodType: PaymentMethodType.card,
        cardNumber: '123',
        cardHolder: 'Alex Morgan',
        expiryDate: '12/28',
        cvv: '123',
      ));
      expect(invalidCard.isValid, false);
      expect(invalidCard.errorMessage, contains('16-digit card number'));

      // Invalid cardholder
      final invalidHolder = strategy.validate(const PaymentDetails(
        methodType: PaymentMethodType.card,
        cardNumber: '4242 4242 4242 4242',
        cardHolder: '',
        expiryDate: '12/28',
        cvv: '123',
      ));
      expect(invalidHolder.isValid, false);
      expect(invalidHolder.errorMessage, contains('cardholder name'));

      // Invalid expiry
      final invalidExpiry = strategy.validate(const PaymentDetails(
        methodType: PaymentMethodType.card,
        cardNumber: '4242 4242 4242 4242',
        cardHolder: 'Alex Morgan',
        expiryDate: '13/99', // Month 13 is invalid
        cvv: '123',
      ));
      expect(invalidExpiry.isValid, false);
      expect(invalidExpiry.errorMessage, contains('MM/YY'));

      // Valid card
      final valid = strategy.validate(const PaymentDetails(
        methodType: PaymentMethodType.card,
        cardNumber: '4242 4242 4242 4242',
        cardHolder: 'Alex Morgan',
        expiryDate: '12/28',
        cvv: '123',
      ));
      expect(valid.isValid, true);
    });

    test('UpiPaymentStrategy validates VPA syntax (@handle)', () {
      final strategy = UpiPaymentStrategy();

      final invalidNoHandle = strategy.validate(const PaymentDetails(
        methodType: PaymentMethodType.upi,
        upiId: 'alexshopper',
      ));
      expect(invalidNoHandle.isValid, false);
      expect(invalidNoHandle.errorMessage, contains('valid UPI ID'));

      final validUpi = strategy.validate(const PaymentDetails(
        methodType: PaymentMethodType.upi,
        upiId: 'alex@okaxis',
      ));
      expect(validUpi.isValid, true);
    });

    test('BnplPaymentStrategy validates tenure and accurately splits installments', () async {
      final strategy = BnplPaymentStrategy();

      final invalid = strategy.validate(const PaymentDetails(
        methodType: PaymentMethodType.bnpl,
        installmentsCount: 0,
      ));
      expect(invalid.isValid, false);

      final valid = strategy.validate(const PaymentDetails(
        methodType: PaymentMethodType.bnpl,
        installmentsCount: 3,
      ));
      expect(valid.isValid, true);

      final result = await strategy.executePayment(
        details: const PaymentDetails(
          methodType: PaymentMethodType.bnpl,
          installmentsCount: 3,
        ),
        amount: 300.0,
      );
      expect(result.isSuccess, true);
      expect(result.transactionId, startsWith('BNPL-'));
      expect(result.message, contains('\$100.00'));
    });

    test('PaymentProcessor conforms to SOLID Open/Closed and Dependency Inversion', () async {
      final processor = PaymentProcessor();

      // Check default registered strategies
      expect(processor.availableStrategies.length, 6);

      // Select UPI
      processor.selectMethod(PaymentMethodType.upi);
      expect(processor.selectedMethod, PaymentMethodType.upi);
      expect(processor.currentStrategy, isA<UpiPaymentStrategy>());

      // Test processing with valid UPI
      final txResult = await processor.processPayment(
        details: const PaymentDetails(
          methodType: PaymentMethodType.upi,
          upiId: 'shopper@upi',
        ),
        amount: 150.0,
      );

      expect(txResult.isSuccess, true);
      expect(txResult.methodType, PaymentMethodType.upi);
      expect(processor.lastResult, isNotNull);
      expect(processor.lastResult!.transactionId, startsWith('TXN-UPI-'));
    });
  });
}
