// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'constants/colors.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/owner_viewmodel.dart';
import 'viewmodels/labour_viewmodel.dart';
import 'ui/screens/splash_screen.dart';

void main() {
  runApp(const DihaadiApp());
}

class DihaadiApp extends StatelessWidget {
  const DihaadiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OwnerViewModel()),
        ChangeNotifierProvider(create: (_) => LabourViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.success,
            tertiary: AppColors.warningOrange,
            background: AppColors.background,
            surface: AppColors.surface,
            error: AppColors.error,
            onPrimary: AppColors.textMain,
            onSecondary: Colors.white,
            onBackground: AppColors.textMain,
            onSurface: AppColors.textMain,
            onError: Colors.white,
          ),
          cardColor: AppColors.surface,
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: AppColors.textMain,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
              .apply(
                bodyColor: AppColors.textMain,
                displayColor: AppColors.textMain,
              )
              .copyWith(
                headlineSmall: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
                titleLarge: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
                bodyMedium: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMain,
                ),
                bodySmall: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: AppColors.primaryDark, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            hintStyle: TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
            labelStyle: TextStyle(
              color: AppColors.textMain,
              fontSize: 14,
            ),
            prefixIconColor: AppColors.textSecondary,
            suffixIconColor: AppColors.textSecondary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textMain,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: BorderSide(color: AppColors.primaryDark, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              textStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textMain,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.background,
            selectedColor: AppColors.primaryLight,
            labelStyle: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMain,
            ),
            side: BorderSide(color: AppColors.border),
          ),
          cardTheme: CardThemeData(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.borderLight),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primaryDark,
            unselectedItemColor: AppColors.textSecondary,
            selectedIconTheme: const IconThemeData(size: 24),
            unselectedIconTheme: const IconThemeData(size: 22),
          ),
          dividerTheme: DividerThemeData(
            color: AppColors.divider,
            thickness: 0.5,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
