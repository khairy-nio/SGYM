import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';

class AiImageScreen extends StatefulWidget {
  const AiImageScreen({super.key});

  @override
  State<AiImageScreen> createState() => _AiImageScreenState();
}

class _AiImageScreenState extends State<AiImageScreen> {
  bool _isAnalyzing = false;
  bool _showResult = false;

  void _analyzeImage() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Product Analyzer'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1579722820308-d74e571900a9?w=400'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_showResult && !_isAnalyzing)
              AppButton(label: 'Analyze Image ✨', onPressed: _analyzeImage, icon: Icons.auto_awesome),
            if (_isAnalyzing)
              const Center(child: Column(
                children: [
                  CircularProgressIndicator(color: AppColors.secondary),
                  SizedBox(height: 16),
                  Text('AI is analyzing your product...'),
                ],
              )),
            if (_showResult) ...[
              Text('AI Suggestions', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              AppTextField(label: 'Suggested Title', hint: '', controller: TextEditingController(text: 'Whey Protein Isolate - 2lbs')),
              const SizedBox(height: 16),
              AppTextField(label: 'Suggested Description', hint: '', maxLines: 3, controller: TextEditingController(text: 'High-quality whey protein isolate for muscle recovery. Contains 25g of protein per serving.')),
              const SizedBox(height: 24),
              AppButton(label: 'Use Details', onPressed: () => context.pop()),
            ],
          ],
        ),
      ),
    );
  }
}
