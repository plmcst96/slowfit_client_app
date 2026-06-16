import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../l10n/app_localizations.dart';
import '../provider/bottom_bar_provider.dart';

class FloatingBottomBar extends ConsumerWidget {
  final int currentIndex;

  const FloatingBottomBar({super.key, required this.currentIndex});

  List<Widget> _buildItems(BuildContext context, WidgetRef ref) {
    List<Map<String, dynamic>> items = [
      {'icon': FontAwesomeIcons.house, 'label': 'Home'},
      {
        'icon': FontAwesomeIcons.dumbbell,
        'label': AppLocalizations.of(context)!.training,
      },
      {
        'icon': FontAwesomeIcons.appleWhole,
        'label': AppLocalizations.of(context)!.nutrition,
      },
      {
        'icon': FontAwesomeIcons.person,
        'label': AppLocalizations.of(context)!.profile,
      },
    ];

    return List.generate(items.length, (index) {
      final isSelected = currentIndex == index;
      final iconColor = isSelected ? Colors.pink : Colors.white;

      Widget iconWidget = FaIcon(
        items[index]['icon'] as FaIconData,
        color: iconColor,
        size: isSelected ? 26 : 24,
      );

      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            ref.read(bottomBarProvider.notifier).updateIndex(index);
            _navigateToPage(index, context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    items[index]['label'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSelected ? 13 : 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: true,
      minimum: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600, // evita che la barra si allarghi troppo su tablet
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),

              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildItems(context, ref),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index, BuildContext context) {
    String targetRoute = '';
    switch (index) {
      case 0:
        targetRoute = '/home';
        break;
      case 1:
        targetRoute = '/training';
        break;
      case 2:
        targetRoute = '/nutrition';
        break;
      case 3:
        targetRoute = '/profile';
        break;
    }

    if (ModalRoute.of(context)?.settings.name != targetRoute) {
      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
    }
  }
}

/// Bottom bar dell'area PERSONAL TRAINER (roleId 2).
///
/// Usa rotte `/trainer-*` distinte da quelle client per evitare collisioni.
class CustomBottomBar extends ConsumerWidget {
  const CustomBottomBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      {'icon': FontAwesomeIcons.house, 'label': 'Home'},
      {
        'icon': FontAwesomeIcons.dumbbell,
        'label': AppLocalizations.of(context)!.training,
      },
      {
        'icon': FontAwesomeIcons.utensils,
        'label': AppLocalizations.of(context)!.nutrition,
      },
      {
        'icon': FontAwesomeIcons.userGroup,
        'label': AppLocalizations.of(context)!.client,
      },
      {
        'icon': FontAwesomeIcons.userLarge,
        'label': AppLocalizations.of(context)!.profile,
      },
    ];

    return SafeArea(
      bottom: true,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final isSelected = currentIndex == index;
                final iconColor = isSelected ? Colors.pink : Colors.white;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      ref.read(bottomBarProvider.notifier).updateIndex(index);
                      _navigateToPage(index, context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            items[index]['icon'] as FaIconData,
                            color: iconColor,
                            size: isSelected ? 24 : 20,
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              items[index]['label'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isSelected ? 13 : 10,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: iconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index, BuildContext context) {
    String targetRoute = '';
    switch (index) {
      case 0:
        targetRoute = '/trainer-home';
        break;
      case 1:
        targetRoute = '/trainer-exercise';
        break;
      case 2:
        targetRoute = '/trainer-nutrition';
        break;
      case 3:
        targetRoute = '/trainer-clients';
        break;
      case 4:
        targetRoute = '/trainer-profile';
        break;
    }

    if (ModalRoute.of(context)?.settings.name != targetRoute) {
      if (Navigator.canPop(context)) {
        Navigator.pushNamedAndRemoveUntil(
            context, targetRoute, (route) => false);
      } else {
        Navigator.pushReplacementNamed(context, targetRoute);
      }
    }
  }
}
