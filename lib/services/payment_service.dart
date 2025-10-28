import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment(int amount, String currency) async {
    try {
      paymentIntent = await _createPaymentIntent(amount, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Foddie',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      paymentIntent = null;
    } on StripeException catch (e) {
      throw Exception('Payment cancelled: $e');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(
    int amount,
    String currency,
  ) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer <Your_Secret_Key>',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'amount': (amount * 100).toString(), 'currency': currency},
    );
    return jsonDecode(response.body);
  }
}
