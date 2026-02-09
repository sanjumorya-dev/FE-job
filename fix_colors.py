#!/usr/bin/env python3
import re
import os

files = [
    "lib/ui/screens/owner/owner_dashboard.dart",
    "lib/ui/screens/labour/labour_dashboard.dart",
    "lib/ui/screens/auth/login_screen.dart",
    "lib/ui/screens/profile_screen.dart"
]

replacements = {
    r'\bkPrimary\b': 'AppColors.primary',
    r'\bkSurface\b': 'AppColors.surface',
    r'\bkText\b': 'AppColors.textMain',
    r'\bkTextSecondary\b': 'AppColors.textSecondary',
    r'\bkSurfaceLight\b': 'AppColors.borderLight',
    r'\bkBackground\b': 'AppColors.background',
    r'\bkError\b': 'AppColors.error',
    r'\bkSuccess\b': 'AppColors.success',
    r'\bkSecondary\b': 'AppColors.success',
}

for file_path in files:
    full_path = os.path.join(os.getcwd(), file_path)
    if os.path.exists(full_path):
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        for pattern, replacement in replacements.items():
            content = re.sub(pattern, replacement, content)
        
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {file_path}")
    else:
        print(f"File not found: {file_path}")

print("All files updated successfully!")
