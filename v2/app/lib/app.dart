import 'package:flutter/material.dart';

import 'design_system/theme.dart';
import 'features/shell/home_shell.dart';
import 'features/shell/permission_gate.dart';

class OneTouchApp extends StatelessWidget {
  const OneTouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '원터치 v2',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const PermissionGate(child: HomeShell()),
    );
  }
}
