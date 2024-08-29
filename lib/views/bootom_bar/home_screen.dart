import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:tamil_app/ViewModel/get_all_video_view_model.dart';
import 'package:tamil_app/apiModel/api_services/api_response.dart';
import 'package:tamil_app/constant/color.dart';
import 'package:tamil_app/views/bootom_bar/subscription_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../../constant/common_text.dart';
import '../../model/res_model/get_video_model.dart';
import '../video_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller;

  //
  // DateTime dateTimeNow = DateTime.now();
  // DateTime endDate = DateTime.now().add(Duration(days: 30));
  //
  // var difference = DateTime.now()
  //     .difference(DateTime.parse('2022-10-21 10:05:00.401918'))
  //     .inDays;

  bool _isPlay = true;
  // Future<void> getVideo({String? videoUrl}) async {
  //   _controller = VideoPlayerController.network(
  //     "https://stream.mux.com/4UKhp6bhJQl600yuzvS1RpihNjp8tgvQb4IXeUdcLy02w.m3u8",
  //     videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  //   );
  //
  //   _controller.addListener(() {
  //     setState(() {});
  //   });
  //   _controller.setLooping(true);
  //   _controller.initialize().then((value) {
  //     _controller.play();
  //   });
  //
  //   // _controller.setLooping(true);
  // }

  GetAllVideoViewModel getAllVideoViewModel = Get.put(GetAllVideoViewModel());

  Future<void> getAllVideo() async {
    await getAllVideoViewModel.getAllVideoViewModel();
  }

  getTime() async {
    Timestamp time1 = dates;
    ;
    DateTime myDateTime = time1.toDate(); // Time

    var time2 = DateTime.now();
    var time3 = time2.difference(myDateTime).inSeconds;
  }

  bool? paymentData;
  var dates;
  @override
  void initState() {
    //getVideo();
    getAllVideo();

    // log('datess${endDate.toString()}');

    // log('differnce$difference');
    getUserData();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void getUserData() async {
    final user = await FirebaseFirestore.instance
        .collection('email')
        .doc('${FirebaseAuth.instance.currentUser!.uid}')
        .get();
    Map<String, dynamic>? getUserData = user.data();
    setState(() {
      paymentData = getUserData!['payment'];
      dates = getUserData['createdAt'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.h),
        child: Container(
          height: 120.h,
          width: Get.width,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.w, top: 35.h),
                child: SvgPicture.asset(
                  'assets/images/svg/splash.svg',
                  height: 76.23.h,
                  width: 76.23.w,
                ),
              ),

              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 22.w, left: 22.w),
                child: GestureDetector(
                  onTap: () {
                    Share.share(
                      'https://tamilapp.page.link/H3Ed',
                    );
                    log('Share');
                  },
                  child: Image(
                    height: 28.h,
                    width: 28.w,
                    image: AssetImage(
                      'assets/images/png/share.png',
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.only(right: 22.w, left: 22.w),
              //   child: SvgPicture.asset(
              //     'assets/images/svg/notification.svg',
              //     height: 28.h,
              //     width: 28.w,
              //   ),
              // ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 5.h),
          GetBuilder<GetAllVideoViewModel>(
            builder: (controller) {
              if (controller.getAllVideoApiResponse.status == Status.COMPLETE) {
                GetAllVideoResponseModel response =
                    controller.getAllVideoApiResponse.data;
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('VideoData')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Text(""));
                    }
                    if (snapshot.hasData) {
                      if (response.data!.length == 0) {
                        return Column(
                          children: [
                            SizedBox(height: 100.h),
                            Lottie.asset('assets/images/png/nodata.json')
                          ],
                        );
                      } else {
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: response.data!.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              DateTime myDateDemo =
                                  (snapshot.data!.docs[index]["time"]).toDate();

                              //  var t = DateFormat.jm().format(myDateDemo);
                              var t = DateFormat.yMMMd()
                                  .add_jm()
                                  .format(myDateDemo);

                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.h),
                                child: GestureDetector(
                                  onTap: () {
                                    index == 0 || paymentData == true
                                        ? Get.to(
                                            () => VideoViewScreen(
                                              videoFile:
                                                  'https://stream.mux.com/${response.data![index].playbackIds![0].id}.m3u8',
                                            ),
                                            transition: Transition.fade,
                                          )
                                        : Get.to(() => '');
                                  },
                                  child: Container(
                                    // height: 480.h,
                                    width: Get.width,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade400,
                                          offset: Offset(1, 1.8),
                                          spreadRadius: 1.5,
                                          blurRadius: 3,
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                index == 0 ||
                                                        paymentData == true
                                                    ? Get.to(
                                                        () => VideoViewScreen(
                                                          videoFile:
                                                              'https://stream.mux.com/${response.data![index].playbackIds![0].id}.m3u8',
                                                        ),
                                                        transition:
                                                            Transition.fade,
                                                      )
                                                    : Get.to(() => '');
                                              },
                                              child: Container(
                                                height: 300.h,
                                                width: Get.width,
                                                alignment: Alignment.center,
                                                // child: ClipRRect(
                                                //   child: Image.network(
                                                //     "https://image.mux.com/${response.data![index].playbackIds![0].id}/thumbnail.jpg",
                                                //     fit: BoxFit.fill,
                                                //   ),
                                                //   borderRadius: BorderRadius.circular(16.r),
                                                // ),
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        // "https://image.mux.com/${response.data![index].playbackIds![0].id}/thumbnail.jpg"
                                                        "https://image.mux.com/${response.data![index].playbackIds![0].id}/animated.gif?width=640&fps=5"),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.r),
                                                ),
                                              ),
                                            ),
                                            // _isPlay == false
                                            //     ? Positioned(
                                            //         top: 130.h,
                                            //         left: 160.w,
                                            //         child: InkWell(
                                            //           onTap: () {
                                            //             setState(() {
                                            //               _isPlay = true;
                                            //             });
                                            //             _controller.play();
                                            //           },
                                            //           child: SvgPicture.asset(
                                            //             'assets/images/svg/video.svg',
                                            //             height: 56.h,
                                            //             width: 56.w,
                                            //           ),
                                            //         ),
                                            //       )
                                            //     : InkWell(
                                            //         onTap: () {
                                            //           setState(() {
                                            //             _isPlay = false;
                                            //           });
                                            //           _controller.pause();
                                            //         },
                                            //         child: SizedBox(
                                            //           height: 300.h,
                                            //           width: 300.w,
                                            //         ),
                                            //       ),
                                          ],
                                        ),
                                        SizedBox(height: 26.h),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        // buildCommonText(response, index),
                                                        Flexible(
                                                          child: CommonText(
                                                            text:
                                                                '${snapshot.data?.docs[index]['title']}',
                                                            fontSize: 20.sp,
                                                            textAlign: TextAlign
                                                                .center,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        SizedBox(width: 14.w),
                                                        index == 0
                                                            ? Text('')
                                                            : paymentData ==
                                                                    true
                                                                ? Text('')
                                                                : SvgPicture
                                                                    .asset(
                                                                    'assets/images/svg/lock.svg',
                                                                    height:
                                                                        20.h,
                                                                    width: 16.w,
                                                                  )
                                                      ],
                                                    ),
                                                    SizedBox(height: 15.h),
                                                    CommonText(
                                                      text:
                                                          '${snapshot.data?.docs[index]['Description']}',
                                                      fontSize: 14.sp,
                                                      color: PickColor
                                                          .secondary1TextColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      overflow:
                                                          TextOverflow.visible,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Spacer(),
                                              index == 0
                                                  ? MaterialButton(
                                                      height: 62.h,
                                                      minWidth: 146.w,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.r),
                                                        side: BorderSide(
                                                            color: PickColor
                                                                .buttonColor),
                                                      ),
                                                      onPressed: () {
                                                        print('view');
                                                        Get.to(
                                                          () => VideoViewScreen(
                                                            videoFile:
                                                                'https://stream.mux.com/${response.data![index].playbackIds![0].id}.m3u8',
                                                          ),
                                                          transition:
                                                              Transition.fade,
                                                        );
                                                      },
                                                      child: CommonText(
                                                        text: 'View',
                                                        color: PickColor
                                                            .buttonColor,
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ))
                                                  : paymentData == true
                                                      ? MaterialButton(
                                                          height: 62.h,
                                                          minWidth: 146.w,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.r),
                                                            side: BorderSide(
                                                                color: PickColor
                                                                    .buttonColor),
                                                          ),
                                                          onPressed: () {
                                                            print('view');
                                                            Get.to(
                                                              () =>
                                                                  VideoViewScreen(
                                                                videoFile:
                                                                    'https://stream.mux.com/${response.data![index].playbackIds![0].id}.m3u8',
                                                              ),
                                                              transition:
                                                                  Transition
                                                                      .fade,
                                                            );
                                                          },
                                                          child: CommonText(
                                                            text: 'View',
                                                            color: PickColor
                                                                .buttonColor,
                                                            fontSize: 20.sp,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ))
                                                      : MaterialButton(
                                                          height: 62.h,
                                                          minWidth: 130.w,
                                                          color: PickColor
                                                              .buttonColor,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.r),
                                                            side: BorderSide(
                                                                color: PickColor
                                                                    .buttonColor),
                                                          ),
                                                          onPressed: () {
                                                            Get.to(() =>
                                                                SubScrIPTionScreen());
                                                          },
                                                          child: CommonText(
                                                            text:
                                                                'Upgrade to View',
                                                            color: Colors.white,
                                                            fontSize: 20.sp,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ))
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 31.h),
                                        Center(
                                          child: CommonText(
                                            text: 'Last updated $t',
                                            fontSize: 14.sp,
                                            color:
                                                PickColor.secondary1TextColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    } else {
                      return SizedBox();
                    }
                  },
                );
              } else {
                if (controller.getAllVideoApiResponse.status == Status.ERROR) {
                  return Center(child: Text('Somthing Went Wrong'));
                }
                // return Center(
                //     child: CircularProgressIndicator(
                //         color: PickColor.buttonColor));
                return Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: PickColor.buttonColor,
                    size: 50.h,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildCommonText(GetAllVideoResponseModel response, int index) {
    try {
      return CommonText(
        text: '${response.data![index].tracks![0].type} ',
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
      );
    } catch (e) {
      return SizedBox();
    }
  }
}
