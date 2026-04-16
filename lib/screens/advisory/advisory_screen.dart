// screens/advisory/advisory_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:agriconnect/providers/advisory_provider.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/utils/app_theme.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});
  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _crop = 'Wheat';
  String _season = 'Winter (Rabi)';

  final _crops = ['Wheat', 'Rice', 'Corn', 'Tomato', 'Onion', 'Potato', 'Soybean'];
  final _seasons = ['Winter (Rabi)', 'Summer (Kharif)', 'Spring'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = context.read<AuthProvider>().user?.location ?? 'Chennai';
      context.read<AdvisoryProvider>().getInitialAdvice(location);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final advisory = context.watch<AdvisoryProvider>();
    if (advisory.messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Advisory'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [const Icon(Icons.lightbulb_outline), const SizedBox(width: 12)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('AI-powered farming recommendations',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ),
        ),
      ),
      body: Column(children: [
        // Crop & Season selector
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select your crop & season',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Dropdown(
                value: _crop, items: _crops, label: 'Crop',
                onChanged: (v) { setState(() => _crop = v!); advisory.setCrop(v!); },
              )),
              const SizedBox(width: 10),
              Expanded(child: _Dropdown(
                value: _season, items: _seasons, label: 'Season',
                onChanged: (v) { setState(() => _season = v!); advisory.setSeason(v!); },
              )),
            ]),
          ]),
        ),

        // Weather card
        if (advisory.weather != null)
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Today's Weather",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              Text(advisory.weather!.location,
                  style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 12)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _WeatherStat(icon: '🌧', value: '${advisory.weather!.humidity}%', label: 'Humidity'),
                _WeatherStat(icon: '💨', value: '${advisory.weather!.windSpeed} km/h', label: 'Wind'),
                _WeatherStat(icon: '🌡', value: '${advisory.weather!.temp}°C', label: 'Temp'),
              ]),
            ]),
          ),

        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: advisory.messages.length + (advisory.isLoading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == advisory.messages.length) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _TypingIndicator(),
                  ),
                );
              }
              final msg = advisory.messages[i];
              return _ChatBubble(text: msg.text, isUser: msg.isUser);
            },
          ),
        ),

        // Chat input
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                decoration: InputDecoration(
                  hintText: 'Ask your crop question…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_msgCtrl.text.trim().isEmpty) return;
                advisory.sendMessage(_msgCtrl.text.trim());
                _msgCtrl.clear();
              },
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;
  const _Dropdown({required this.value, required this.items, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: onChanged,
          ),
        ],
      );
}

class _WeatherStat extends StatelessWidget {
  final String icon, value, label;
  const _WeatherStat({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          Text(label, style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 10)),
        ]),
      );
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});
  @override
  Widget build(BuildContext context) => Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: isUser ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isUser ? null : Border.all(color: AppTheme.border),
          ),
          child: Text(text,
              style: TextStyle(fontSize: 13, color: isUser ? Colors.white : AppTheme.textPrimary,
                  height: 1.5)),
        ),
      );
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 6, height: 6, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
          SizedBox(width: 8),
          Text('Advisor is typing…', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      );
}
