import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tài khoản', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Thành phố: '),
              Expanded(
                child: TextFormField(
                  initialValue: provider.city,
                  onFieldSubmitted: (v) => provider.setCity(v),
                  decoration: const InputDecoration(
                    hintText: 'Nhập thành phố (vd: Hanoi, Ho Chi Minh)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/api-keys'),
            icon: const Icon(Icons.vpn_key),
            label: const Text('Cài đặt API Keys'),
          ),
        ],
      ),
    );
  }
}
