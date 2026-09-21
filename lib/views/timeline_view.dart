import 'package:flutter/material.dart';

class TimelineView extends StatelessWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mine Feed #${index + 1}',
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    const Text('10分前', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('JSフリーで爆速表示される記事サンプルタイトル #${index + 1}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Rust側のクリーンエンジンによって不要なスクリプトや広告が自動除去された本文がここに読み込まれます...',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
