import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/data/services/rating_service.dart';

class WorkerRatingScreen extends StatefulWidget {
  final String workerName;
  final String jobTitle;
  final String? workerId;
  final String? requirementId;

  const WorkerRatingScreen({
    super.key,
    required this.workerName,
    required this.jobTitle,
    this.workerId,
    this.requirementId,
  });

  @override
  State<WorkerRatingScreen> createState() => _WorkerRatingScreenState();
}

class _WorkerRatingScreenState extends State<WorkerRatingScreen> {
  int _rating = 0;
  int _hoverRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  bool _isCheckingRating = true;
  bool _canRate = false;
  String? _ratingError;
  final RatingService _ratingService = RatingService();

  final List<String> _quickFeedback = [
    'Excellent work!',
    'Very professional',
    'Completed on time',
    'Good communication',
    'Skilled worker',
    'Would hire again',
  ];

  final List<String> _selectedFeedback = [];

  @override
  void initState() {
    super.initState();
    _checkCanRate();
  }

  Future<void> _checkCanRate() async {
    if (widget.requirementId == null || widget.requirementId!.isEmpty) {
      setState(() {
        _isCheckingRating = false;
        _canRate = false;
        _ratingError = 'Invalid job ID';
      });
      return;
    }

    final canRate = await _ratingService.canRateJob(widget.requirementId!);
    if (mounted) {
      setState(() {
        _isCheckingRating = false;
        _canRate = canRate;
        if (!canRate) {
          _ratingError = 'Rating period expired. You can only rate within 7 days of job completion.';
        }
      });
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _toggleFeedback(String feedback) {
    setState(() {
      if (_selectedFeedback.contains(feedback)) {
        _selectedFeedback.remove(feedback);
      } else {
        _selectedFeedback.add(feedback);
      }
    });
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_canRate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_ratingError ?? 'Rating not allowed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _ratingService.rateWorker(
        workerId: widget.workerId ?? '',
        requirementId: widget.requirementId ?? '',
        rating: _rating,
        feedback: _feedbackController.text.trim(),
        tags: _selectedFeedback,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to submit rating: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }

    if (mounted) setState(() => _isSubmitting = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success,
          ),
          content: const Text(
            'Thank you for your feedback!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close chat detail
                  Navigator.pop(context); // Return to chat list
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rate Worker'),
        centerTitle: true,
      ),
      body: _isCheckingRating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Worker Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.workerName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.jobTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Rating Period Error
                  if (!_canRate && _ratingError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _ratingError!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Rating Section
                  const Text(
                    'How was the worker?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your feedback helps other owners',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Star Rating
                  Center(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoverRating = 0),
                      onExit: (_) => setState(() => _hoverRating = 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          final isActive = starValue <= _rating;
                          final isHovered = starValue <= _hoverRating && _hoverRating > 0;

                          return MouseRegion(
                            onEnter: (_) => setState(() => _hoverRating = starValue),
                            onExit: (_) => setState(() => _hoverRating = 0),
                            child: GestureDetector(
                              onTap: _canRate ? () => setState(() => _rating = starValue) : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  isActive || isHovered
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 48,
                                  color: isActive || isHovered
                                      ? const Color(0xFFFFB800)
                                      : AppColors.border,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  if (_rating > 0) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _getRatingText(_rating),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Quick Feedback Tags
                  const Text(
                    'Quick Feedback (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickFeedback.map((feedback) {
                      final isSelected = _selectedFeedback.contains(feedback);
                      return GestureDetector(
                        onTap: _canRate ? () => _toggleFeedback(feedback) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Text(
                            feedback,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textMain,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Detailed Feedback
                  const Text(
                    'Detailed Feedback (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: TextField(
                      controller: _feedbackController,
                      enabled: _canRate,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe the quality, punctuality, and overall experience...',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (!_canRate || _isSubmitting) ? null : _submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit Rating',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor 😞';
      case 2:
        return 'Fair 😐';
      case 3:
        return 'Good 🙂';
      case 4:
        return 'Very Good 😊';
      case 5:
        return 'Excellent! 🌟';
      default:
        return '';
    }
  }
}