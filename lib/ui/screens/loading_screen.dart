import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  static const String _loaderAsset = 'assets/animations/liquid_loader.json';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: FutureBuilder<String>(
          future: rootBundle.loadString(_loaderAsset),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                !snapshot.data!.contains('"layers": []')) {
              return Lottie.asset(
                _loaderAsset,
                width: 180,
                height: 180,
                repeat: true,
              );
            }

            return LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.primary,
              size: 60,
            );
          },
        ),
      ),
    );
  }
}
