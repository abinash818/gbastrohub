import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final String _adminWhatsAppNumber = '919600666225'; // Included India country code +91

  String _formatDuration(int days, double price) {
    String durationText = '$days Days';
    if (days >= 365 && days % 365 == 0) {
      int years = days ~/ 365;
      durationText = '$years ${years == 1 ? 'Year' : 'Years'}';
    } else if (days >= 30 && days % 30 == 0) {
      int months = days ~/ 30;
      durationText = '$months ${months == 1 ? 'Month' : 'Months'}';
    }
    return '₹${price.toStringAsFixed(0)} / $durationText';
  }

  Future<void> _requestPlan(SubscriptionPlan plan) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'Unknown User';
    final userEmail = user?.email ?? 'Unknown Email';
    final userPhone = user?.phoneNumber ?? 'Unknown Phone';

    final text = 'Hi Admin,\n\nI would like to subscribe to the *${plan.name}* plan (Rs. ${plan.price}).\n\nMy Details:\nUser ID: $userId\nEmail: $userEmail\nPhone: $userPhone';
    
    final encodedText = Uri.encodeComponent(text);
    final url = Uri.parse('https://wa.me/$_adminWhatsAppNumber?text=$encodedText');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<SubscriptionPlan>>(
        future: _subscriptionService.getActivePlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading plans: ${snapshot.error}'));
          }

          final plans = snapshot.data;

          if (plans == null || plans.isEmpty) {
            return const Center(
              child: Text(
                'No active subscription plans available right now.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(plan.durationDays, plan.price),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(height: 24),
                      ...plan.features.map((feature) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(feature)),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _requestPlan(plan),
                          icon: const Icon(Icons.send),
                          label: const Text('Request Plan via WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
