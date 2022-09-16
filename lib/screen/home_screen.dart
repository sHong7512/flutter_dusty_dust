import 'package:dio/dio.dart';
import 'package:dusty_dust/container/category_card.dart';
import 'package:dusty_dust/container/hourly_card.dart';
import 'package:dusty_dust/component/main_appbar.dart';
import 'package:dusty_dust/component/main_drawer.dart';
import 'package:dusty_dust/model/stat_and_status_model.dart';
import 'package:dusty_dust/model/stat_model.dart';
import 'package:dusty_dust/repository/stat_rapository.dart';
import 'package:dusty_dust/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../const/regions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String region = regions[0];
  bool isExpanded = true;
  ScrollController scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    scrollController.addListener(scrollListener);
    fetchData();
  }

  @override
  dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final now = DateTime.now();
      final fetchTime = DateTime(now.year, now.month, now.day, now.hour);

      final box = Hive.box<StatModel>(ItemCode.PM10.name);

      if (box.values.isNotEmpty &&
          (box.values.last as StatModel).dataTime.isAtSameMomentAs(fetchTime)) {
        print('이미 최신 데이터가 있습니다.');
        return;
      }

      List<Future> futures = [];
      for (ItemCode itemCode in ItemCode.values) {
        futures.add(
          StatRepository.fetchData(itemCode: itemCode),
        );
      }
      final results = await Future.wait(futures);

      for (int i = 0; i < results.length; i++) {
        // ItemCode
        final key = ItemCode.values[i];
        // List<StatModel>
        final value = results[i];

        final box = Hive.box<StatModel>(key.name);
        for (StatModel stat in value) {
          box.put(stat.dataTime.toString(), stat);
        }

        final allKeys = box.keys.toList();

        if (allKeys.length > 24) {
          final deleteKeys = allKeys.sublist(0, allKeys.length - 24);

          box.deleteAll(deleteKeys);
        }
      }
    } on DioError catch (e) {
      print('fetch Error : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인터넷 연결이 원활하지 않습니다.'),
        ),
      );
    }
  }

  scrollListener() {
    bool isExpanded = scrollController.offset < 500 - kToolbarHeight;

    if (isExpanded != this.isExpanded) {
      setState(() {
        this.isExpanded = isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box<StatModel>(ItemCode.PM10.name).listenable(),
      builder: (context, box, widget) {
        if(box.values.isEmpty){
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // PM10 미세먼지
        final recentStat = (box.values.toList().last) as StatModel;

        final status = DataUtils.getStatusFromItemCodeAndValue(
          value: recentStat.getLevelFromRegion(region),
          itemCode: ItemCode.PM10,
        );

        return Scaffold(
          drawer: MainDrawer(
            darkColor: status.darkColor,
            lightColor: status.lightColor,
            selectedRegion: region,
            onRegionTap: (String region) {
              setState(() {
                this.region = region;
              });
              Navigator.of(context).pop();
            },
          ),
          body: Container(
            color: status.primaryColor,
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchData();
              },
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  MainAppBar(
                    stat: recentStat,
                    status: status,
                    region: region,
                    dateTime: recentStat.dataTime,
                    isExpanded: isExpanded,
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CategoryCard(
                          region: region,
                          darkColor: status.darkColor,
                          lightColor: status.lightColor,
                        ),
                        const SizedBox(height: 16.0),
                        ...ItemCode.values.map(
                          (itemCode) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: HourlyCard(
                                darkColor: status.darkColor,
                                lightColor: status.lightColor,
                                region: region,
                                itemCode: itemCode,
                              ),
                            );
                          },
                        ).toList(),
                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // return FutureBuilder<Map<ItemCode, List<StatModel>>>(
    //   future: fetchData(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       print('has Error : ${snapshot.error}');
    //       return Scaffold(
    //         body: Center(
    //           child: Text('에러가 있습니다.'),
    //         ),
    //       );
    //     }
    //
    //     if (!snapshot.hasData) {
    //       // 로딩상태
    //       return Scaffold(
    //         body: Center(
    //           child: CircularProgressIndicator(),
    //         ),
    //       );
    //     }
    //
    //     Map<ItemCode, List<StatModel>> stats = snapshot.data!;
    //     StatModel pm10RecentStat = stats[ItemCode.PM10]![0];
    //
    //     final status = DataUtils.getStatusFromItemCodeAndValue(
    //       value: pm10RecentStat.seoul,
    //       itemCode: ItemCode.PM10,
    //     );
    //
    //     final ssModel = stats.keys.map(
    //       (key) {
    //         final value = stats[key]!;
    //         final stat = value[0];
    //
    //         return StatAndStatusModel(
    //           itemCode: key,
    //           status: DataUtils.getStatusFromItemCodeAndValue(
    //             value: stat.getLevelFromRegion(region),
    //             itemCode: key,
    //           ),
    //           stat: stat,
    //         );
    //       },
    //     ).toList();
    //
    //     return Scaffold(
    //       drawer: MainDrawer(
    //         darkColor: status.darkColor,
    //         lightColor: status.lightColor,
    //         selectedRegion: region,
    //         onRegionTap: (String region) {
    //           setState(() {
    //             this.region = region;
    //           });
    //           Navigator.of(context).pop();
    //         },
    //       ),
    //       body: Container(
    //         color: status.primaryColor,
    //         child: CustomScrollView(
    //           controller: scrollController,
    //           slivers: [
    //             MainAppBar(
    //               stat: pm10RecentStat,
    //               status: status,
    //               region: region,
    //               dateTime: pm10RecentStat.dataTime,
    //               isExpanded: isExpanded,
    //             ),
    //             SliverToBoxAdapter(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
    //                 children: [
    //                   CategoryCard(
    //                     region: region,
    //                     models: ssModel,
    //                     darkColor: status.darkColor,
    //                     lightColor: status.lightColor,
    //                   ),
    //                   const SizedBox(height: 16.0),
    //                   ...stats.keys.map(
    //                     (itemCode) {
    //                       final stat = stats[itemCode]!;
    //
    //                       return Padding(
    //                         padding: const EdgeInsets.only(bottom: 16.0),
    //                         child: HourlyCard(
    //                           darkColor: status.darkColor,
    //                           lightColor: status.lightColor,
    //                           category: DataUtils.getItemCodeKrString(
    //                               itemCode: itemCode),
    //                           stats: stat,
    //                           region: region,
    //                         ),
    //                       );
    //                     },
    //                   ).toList(),
    //                   const SizedBox(height: 32.0),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}
