import 'package:material_ui/material_ui.dart';
import 'export/packages.dart';
import 'export/bloc.dart';
import '../features/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Localizations(
       locale: const Locale('en', 'US'),
      delegates: GlobalMaterialLocalizations.delegates,
      isApplicationLevel: true,
      child:  MaterialApp(
      title: 'Асатуллаев Лаба',
      locale: const Locale('en', 'US'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color(0xffEEEEEE),
          surface: const Color(0xff0A0A0A),
          onSurface: const Color(0xff1A1A1A),
          primary: const Color(0xffEEEEEE),
          secondary: const Color(0xff565656),
          tertiary: const Color(0xff282828),
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => DatabaseBloc())
        ],
        child: const MyHomePage(title: 'Асатуллаев лаборанторная'),
        )
      ),
    );
  }
}