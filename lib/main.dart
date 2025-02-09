import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mudkip_frontend/screens/app_shell.dart';
import 'package:mudkip_frontend/mudkipc.dart';
import 'package:mudkip_frontend/theme/theme_constants.dart';
import 'package:mudkip_frontend/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mudkip_frontend/screens.dart';

ThemeManager themeManager = ThemeManager();
late PackageInfo packageInfo;
late File logFile;
final router = GoRouter(initialLocation: "/pc", routes: <RouteBase>[
  GoRoute(
      path: "/settings",
      builder: (context, state) {
        return const SettingsScreen();
      }),
  GoRoute(
      path: "/about",
      builder: (context, state) {
        return const AboutScreen();
      }),
  GoRoute(
      path: "/preview",
      builder: (context, state) {
        return PreviewPanel(object: state.extra! as Future<dynamic>);
      }),
  ShellRoute(
      routes: <RouteBase>[
        GoRoute(
          path: "/pc",
          builder: (context, state) {
            return const PCView();
          },
        ),
        GoRoute(
            path: "/pokedex",
            builder: (context, state) {
              return const PokeDexView();
            }),
      ],
      builder: (context, state, child) {
        return AppShell(child: child);
      }),
]);

void main(List<String> args) async {
  logFile = File("${await MudkiPC.cacheFolder}log.txt");
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print("${record.level.name}: ${record.time}: ${record.message}");
    if (record.level == Level.INFO ||
        record.level == Level.WARNING ||
        record.level == Level.SEVERE) {
      logFile.writeAsStringSync(
          '\n${record.level.name}: ${record.time}: ${record.message}',
          mode: FileMode.append);
    }
  });
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await Settings.doPrefs();
  packageInfo = await PackageInfo.fromPlatform();
  await PokeAPI.create();
  await PC.create();
  if (args.firstOrNull == 'multi_window') {
    // ignore: unused_local_variable
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;
    switch (argument['appId']) {
      case "pkmnmanager":
        break;
      default:
        break;
    }
  } else {
    runApp(ChangeNotifierProvider(
        create: (context) => ThemeManager(),
        builder: (context, _) {
          final themeProvider = Provider.of<ThemeManager>(context);
          return MaterialApp.router(
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeProvider.themeMode,
              routerDelegate: router.routerDelegate,
              routeInformationParser: router.routeInformationParser,
              routeInformationProvider: router.routeInformationProvider);
        }));
  }
}
