import 'package:flutter/foundation.dart';
import 'payment_method_model.dart';
import 'payment_strategy.dart';

/// PaymentProcessor orchestrates payment strategies following Clean Architecture
/// and SOLID Dependency Inversion & Open/Closed Principles.
class PaymentProcessor extends ChangeNotifier {
  final Map<PaymentMethodType, PaymentStrategy> _strategies = {};
  PaymentMethodType _selectedMethod = PaymentMethodType.card;
  bool _isProcessing = false;
  PaymentTransactionResult? _lastResult;
  String? _lastErrorMessage;

  PaymentProcessor({List<PaymentStrategy>? customStrategies}) {
    if (customStrategies != null && customStrategies.isNotEmpty) {
      for (final strategy in customStrategies) {
        _strategies[strategy.type] = strategy;
      }
    } else {
      _registerDefaultStrategies();
    }
  }

  void _registerDefaultStrategies() {
    registerStrategy(CardPaymentStrategy());
    registerStrategy(UpiPaymentStrategy());
    registerStrategy(WalletPaymentStrategy());
    registerStrategy(NetBankingPaymentStrategy());
    registerStrategy(BnplPaymentStrategy());
    registerStrategy(CodPaymentStrategy());
  }

  /// Register or override any payment strategy (Open/Closed Principle)
  void registerStrategy(PaymentStrategy strategy) {
    _strategies[strategy.type] = strategy;
  }

  List<PaymentStrategy> get availableStrategies => _strategies.values.toList();

  PaymentMethodType get selectedMethod => _selectedMethod;

  PaymentStrategy get currentStrategy {
    final strategy = _strategies[_selectedMethod];
    if (strategy == null) {
      throw StateError('No strategy registered for method $_selectedMethod');
    }
    return strategy;
  }

  bool get isProcessing => _isProcessing;
  PaymentTransactionResult? get lastResult => _lastResult;
  String? get lastErrorMessage => _lastErrorMessage;

  void selectMethod(PaymentMethodType method) {
    if (_selectedMethod != method) {
      _selectedMethod = method;
      _lastErrorMessage = null;
      notifyListeners();
    }
  }

  /// Validates details using currently active strategy
  PaymentValidationResult validateDetails(PaymentDetails details) {
    return currentStrategy.validate(details);
  }

  /// Executes payment through the current strategy
  Future<PaymentTransactionResult> processPayment({
    required PaymentDetails details,
    required double amount,
  }) async {
    _isProcessing = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      final validation = currentStrategy.validate(details);
      if (!validation.isValid) {
        _isProcessing = false;
        _lastErrorMessage = validation.errorMessage ?? 'Validation failed';
        notifyListeners();
        return PaymentTransactionResult(
          isSuccess: false,
          transactionId: '',
          message: _lastErrorMessage!,
          methodType: _selectedMethod,
          amount: amount,
          timestamp: DateTime.now(),
        );
      }

      final result = await currentStrategy.executePayment(
        details: details,
        amount: amount,
      );

      _lastResult = result;
      _isProcessing = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isProcessing = false;
      _lastErrorMessage = 'Payment processing error: ${e.toString()}';
      notifyListeners();
      return PaymentTransactionResult(
        isSuccess: false,
        transactionId: '',
        message: _lastErrorMessage!,
        methodType: _selectedMethod,
        amount: amount,
        timestamp: DateTime.now(),
      );
    }
  }

  void reset() {
    _isProcessing = false;
    _lastResult = null;
    _lastErrorMessage = null;
    notifyListeners();
  }
}
