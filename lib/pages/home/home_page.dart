import 'package:azkark/pages/quran/quran.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/services_export.dart';
import '../../util/helpers.dart';
import '../../pages/search/search_azkar.dart';
import '../../util/navigate_between_pages/fade_route.dart';
import '../../util/print_log.dart';
import '../../widgets/search_widget/search_bar.dart';
import '../../util/navigate_between_pages/scale_route.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/asmaallah/view_asmaallah.dart';
import '../../pages/prayer/view_prayer.dart';
import '../../pages/categories/all_categories.dart';
import '../../pages/favorites/view_favorites.dart';
import '../../pages/sebha/items_sebha.dart';
import '../../util/background.dart';
import '../../models/section_model.dart';
import '../categories/categories_of_section.dart';
import '../../providers/sections_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../util/colors.dart';
import '../prayerTimings/prayTimes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future sendPermissionNotification() async {
    await Permission.notification.request();
    if (await Permission.notification.status.isGranted) {
      // Use notification.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("يجب عليك السماح للإشعارات لتنبيهك لوقت الصلاة")));
      printLog(
          stateID: "510532",
          data: "Permission Notification not accepted",
          isSuccess: false);
    }
  }

  Future sendPermissionLocation() async {
    await Permission.location.request();
    if (await Permission.location.status.isGranted) {
      // Use location.
      await startAzanNotification();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "يجب عليك السماح بتحديد الموقع لجب مواعيد الصلاة حسب منطقتك")));
      printLog(
          stateID: "528943",
          data: "Permission location not accepted",
          isSuccess: false);
    }
  }

  @override
  void initState() {
    sendPermissionNotification();
    sendPermissionLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sectionsProvider =
        Provider.of<SectionsProvider>(context, listen: false);

    return Stack(
      children: <Widget>[
        const Background(),
        Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.blue,
            title: Text(
              translate(context, 'home_bar'),
              style: TextStyle(
                color: Colors.blue[50],
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              SearchBar(
                title: '${translate(context, 'search_for_zekr')} . . . ',
                onTap: () => Navigator.push(
                    context,
                    FadeRoute(
                      page: const SearchForZekr(),
                    )),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      _buildFirstList(context),
                      _buildAllAzkarCard('عرض كل الأذكار', context),
                      for (int i = 0; i < sectionsProvider.length; i += 2)
                        _buildRowCategories(sectionsProvider, i, context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFirstList(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.25,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildItemsCard(
              context: context,
              text: translate(context, 'favorite_bar'),
              pathIcon: 'assets/images/icons/favorites/favorite_256px.png',
              onTap: () => Navigator.push(
                context,
                ScaleRoute(page: const FavoritesView()),
              ),
            ),
          ),
          _buildItemsCard(
            context: context,
            text: translate(context, 'sebha_bar'),
            pathIcon: 'assets/images/icons/sebha/sebha_256px.png',
            onTap: () => Navigator.push(
              context,
              ScaleRoute(page: const ItemsSebha()),
            ),
          ),
          //

          _buildItemsCard(
            context: context,
            text: translate(context, 'quran_bar'),
            pathIcon: 'assets/images/icons/quran/quran.png',
            onTap: () => Navigator.push(
              context,
              ScaleRoute(page: const Quran()),
            ),
          ),

          _buildItemsCard(
            context: context,
            text: translate(context, 'Prayer Timings_bar'),
            pathIcon: 'assets/images/icons/quran/time.png',
            onTap: () async {
              await Permission.location.request();
              if (await Permission.location.status.isGranted) {
                // Use location.
                Navigator.push(
                  context,
                  ScaleRoute(page: const PrayTimes()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        "يجب عليك السماح بتحديد الموقع لجب مواعيد الصلاة حسب منطقتك")));
                printLog(
                    stateID: "528943",
                    data: "Permission not accepted",
                    isSuccess: false);
              }
            },
          ),
          //

          _buildItemsCard(
            context: context,
            text: translate(context, 'prayer_bar'),
            pathIcon: 'assets/images/icons/prayer/prayer_256px.png',
            onTap: () => Navigator.push(
              context,
              ScaleRoute(page: const ViewPrayer()),
            ),
          ),
          _buildItemsCard(
            context: context,
            text: translate(context, 'asmaallah_bar'),
            pathIcon: 'assets/images/icons/asmaallah/allah_256px.png',
            onTap: () => Navigator.push(
              context,
              ScaleRoute(page: const ViewAsmaAllah()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _buildItemsCard(
              context: context,
              text: translate(context, 'settings_bar'),
              pathIcon: '0',
              onTap: () => Navigator.push(
                context,
                ScaleRoute(page: const Settings()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(
      {BuildContext context, String text, String pathIcon, Function onTap}) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        Card(
          color: blue[300],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            highlightColor: blue[400],
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              height: size.height * 0.1,
              width: size.width * 0.15,
              child: pathIcon == '0'
                  ? Icon(
                      Icons.settings,
                      color: const Color(0xff030056),
                      size: size.width * 0.12,
                    )
                  : Image.asset(
                      pathIcon,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * 0.18,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: blue,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllAzkarCard(String text, BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        color: blue[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          highlightColor: blue[400],
          borderRadius: BorderRadius.circular(10),
          onTap: () =>
              Navigator.push(context, FadeRoute(page: const ViewAllCategories())),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(right: 5.0),
                  height: size.height * 0.06,
                  child: Image.asset(
                    'assets/images/sections/8_128px.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w700,
                      fontSize: size.width * 0.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowCategories(
      SectionsProvider sectionsProvider, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCategoryCard(sectionsProvider.getSection(index), context),
          _buildCategoryCard(sectionsProvider.getSection(index + 1), context),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(SectionModel sectionModel, BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Card(
      color: blue[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        height: size.height * 0.25,
        width: size.width * 0.45,
        child: InkWell(
          highlightColor: blue[400],
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.push(
            context,
            FadeRoute(page: CategoriesOfSection(sectionModel.id)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    // height: size.height*0.15,
                    width: size.width * 0.4,
                    child: Image.asset(
                      'assets/images/sections/' +
                          sectionModel.id.toString() +
                          '.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  sectionModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
