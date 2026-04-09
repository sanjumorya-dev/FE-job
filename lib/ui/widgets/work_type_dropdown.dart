import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';

/// Modern Multi-Select Dropdown Component
class WorkTypeDropdown extends StatefulWidget {
  final List<WorkTypeItem> items;
  final List<String> selectedIds;
  final Function(String) onSelected;
  final Function(String) onRemoved;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const WorkTypeDropdown({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.onSelected,
    required this.onRemoved,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  State<WorkTypeDropdown> createState() => _WorkTypeDropdownState();
}

class _WorkTypeDropdownState extends State<WorkTypeDropdown> {
  late FocusNode _focusNode;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isOpen ? () => setState(() => _isOpen = false) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main dropdown button
          GestureDetector(
            onTap: widget.isLoading
                ? null
                : () {
                    setState(() => _isOpen = !_isOpen);
                    _focusNode.requestFocus();
                  },
            child: Focus(
              focusNode: _focusNode,
              onFocusChange: (hasFocus) {
                if (!hasFocus && _isOpen) {
                  setState(() => _isOpen = false);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(
                    color: _isOpen ? AppColors.primary : AppColors.borderLight,
                    width: _isOpen ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: widget.selectedIds.isEmpty
                          ? const Text(
                              'Select your skills...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            )
                          : Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: widget.selectedIds.map((id) {
                                final item = widget.items.firstWhere(
                                  (item) => item.id == id,
                                  orElse: () => WorkTypeItem(id: '', name: ''),
                                );
                                return _SelectedTag(
                                  label: item.name,
                                  onRemove: () => widget.onRemoved(id),
                                );
                              }).toList(),
                            ),
                    ),
                    Icon(
                      _isOpen ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Dropdown menu
          if (_isOpen) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 320),
              child: widget.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : widget.error != null
                      ? _ErrorState(
                          error: widget.error!,
                          onRetry: widget.onRetry,
                        )
                      : widget.items.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No skills available',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: widget.items.length,
                              itemBuilder: (context, index) {
                                final item = widget.items[index];
                                final isSelected =
                                    widget.selectedIds.contains(item.id);
                                return _DropdownItem(
                                  item: item,
                                  isSelected: isSelected,
                                  onTap: () {
                                    widget.onSelected(item.id);
                                  },
                                );
                              },
                            ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dropdown item widget
class _DropdownItem extends StatelessWidget {
  final WorkTypeItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DropdownItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDescription =
        item.description != null && item.description!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppColors.primary.withOpacity(0.05),
        splashColor: AppColors.primary.withOpacity(0.08),
        child: Container(
          color: isSelected
              ? AppColors.primary.withOpacity(0.06)
              : Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: hasDescription ? 10 : 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 2 : 1.5,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                    if (hasDescription)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          item.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selected tag widget
class _SelectedTag extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _SelectedTag({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const _ErrorState({
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Work type item model
class WorkTypeItem {
  final String id;
  final String name;
  final String? description;

  WorkTypeItem({
    required this.id,
    required this.name,
    this.description,
  });
}
