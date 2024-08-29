import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tamil_app/constant/color.dart';
import 'package:tamil_app/constant/common_button.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:upi_india/upi_india.dart';
import 'package:upi_india/upi_response.dart';
import '../../constant/common_text.dart';
import '../../controller/network_checker.dart';

class SubScrIPTionScreen extends StatefulWidget {
  const SubScrIPTionScreen({Key? key}) : super(key: key);

  @override
  State<SubScrIPTionScreen> createState() => _SubScriPtionScreenState();
}

class _SubScriPtionScreenState extends State<SubScrIPTionScreen> {
  late Razorpay _razorpay;
  int? amounts;
  double? paying;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Success Response: $response');

    FirebaseFirestore.instance
        .collection('email')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      'payment': true,
      'createdAt': DateTime.now().toString(),
      'plan': amounts,
    });
    Get.snackbar(
        duration: Duration(seconds: 2),
        backgroundColor: PickColor.buttonColor,
        colorText: Colors.white,
        'PAYMENT SUCCESS',
        response.paymentId!);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response:$response');

    Fluttertoast.showToast(
        msg:
            "ERROR123: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT);
  }

  ConnectivityProvider _connectivityProvider = Get.put(ConnectivityProvider());

  @override
  void initState() {
    super.initState();
    _connectivityProvider.startMonitoring();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
    //   setState(() {
    //     apps = value;
    //   });
    // }).catchError((e) {
    //   apps = [];
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout({required int amount}) async {
    var options = {
      'key': 'rzp_test_FMi1AoD3fsag35',
      'amount': amount,
      'currency': 'INR',
      'name': 'Talk Tamil',
      'description': '',
      'send_sms_hash': true,
      'prefill': {'contact': '', 'email': ''},
      'external': {
        'wallets': [
          'paytm',
        ],
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error_razorpay: $e');
    }
  }

  /// pay with Upi ///

  Future<UpiResponse>? _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: '7046772418@ybl',
      receiverName: 'abc',
      transactionRefId: 'TestingUpiIndiaPlugin',
      transactionNote: 'Not actual. Just an example.',
      amount: paying!,
    );
  }

  Widget displayUpiApps() {
    if (apps == null)
      return Center(child: CircularProgressIndicator());
    else if (apps!.length == 0)
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    else
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app);
                  setState(() {});
                },
                child: Container(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        // FirebaseFirestore.instance
        //     .collection('email')
        //     .doc(FirebaseAuth.instance.currentUser?.uid)
        //     .update({
        //   'payment': true,
        //   'createdAt': DateTime.now().toString(),
        //   'plan': paying,
        // });
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        FirebaseFirestore.instance
            .collection('email')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'payment': true,
          'createdAt': DateTime.now().toString(),
          'plan': paying,
        });
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
            body,
            style: value,
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // leading: GestureDetector(
          //   onTap: () {
          //     // Get.back();
          //   },
          //   child: Icon(
          //     Icons.arrow_back_ios_rounded,
          //     color: Colors.black,
          //     size: 20.h,
          //   ),
          // ),
          title: CommonText(
            text: 'Subscription',
            fontSize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
          centerTitle: true,
        ),
        body: GetBuilder<ConnectivityProvider>(
          builder: (controller) {
            if (controller.isOnline!) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Center(
                        child: SvgPicture.asset(
                            'assets/images/svg/subscription.svg',
                            height: 230.h,
                            width: 375.w),
                      ),
                      SizedBox(height: 33.h),
                      CommonText(
                        text:
                            'Choose between monthly and yearly\n payment options.',
                        fontSize: 16.sp,
                        textAlign: TextAlign.center,
                        color: PickColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 43.h),
                      Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: Color(0xffF8EEF3),
                          borderRadius: BorderRadius.circular(19.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 19.h),
                          child: Column(
                            children: [
                              SizedBox(height: 19.h),
                              CommonText(
                                text: 'Monthly',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              SizedBox(height: 33.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonText(
                                    text: '₹99',
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  CommonText(
                                    text: '/MO',
                                    fontSize: 40.sp,
                                    color: PickColor.secondary1TextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              SizedBox(height: 27.h),
                              CommonText(
                                text: 'Pay every month',
                                fontSize: 16.sp,
                                color: PickColor.secondary1TextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(height: 36.h),
                              MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      print('Razorpay');
                                      setState(() {
                                        amounts = 99;
                                      });
                                      openCheckout(amount: 100 * 99);
                                    });
                                    // showModalBottomSheet(
                                    //   isScrollControlled: true,
                                    //   backgroundColor: Colors.transparent,
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     return Container(
                                    //       height: 500.h,
                                    //       decoration: BoxDecoration(
                                    //         borderRadius:
                                    //             BorderRadius.circular(10.r),
                                    //         color: Colors.white,
                                    //       ),
                                    //       margin: EdgeInsets.only(
                                    //         bottom: 40.h,
                                    //         left: 20.w,
                                    //         right: 20.w,
                                    //       ),
                                    //       child: Column(
                                    //         children: <Widget>[
                                    //           displayUpiApps(),
                                    //           Expanded(
                                    //             child: StatefulBuilder(
                                    //               builder: (BuildContext
                                    //                       context,
                                    //                   void Function(
                                    //                           void Function())
                                    //                       setState) {
                                    //                 return FutureBuilder(
                                    //                   future: _transaction,
                                    //                   builder: (BuildContext
                                    //                           context,
                                    //                       AsyncSnapshot<
                                    //                               UpiResponse>
                                    //                           snapshot) {
                                    //                     if (snapshot
                                    //                             .connectionState ==
                                    //                         ConnectionState
                                    //                             .done) {
                                    //                       if (snapshot
                                    //                           .hasError) {
                                    //                         return Center(
                                    //                           child: Text(
                                    //                             _upiErrorHandler(
                                    //                                 snapshot
                                    //                                     .error
                                    //                                     .runtimeType),
                                    //                             style: header,
                                    //                           ), // Print's text message on screen
                                    //                         );
                                    //                       }
                                    //
                                    //                       // If we have data then definitely we will have UpiResponse.
                                    //                       // It cannot be null
                                    //                       UpiResponse
                                    //                           _upiResponse =
                                    //                           snapshot.data!;
                                    //
                                    //                       // Data in UpiResponse can be null. Check before printing
                                    //                       String txnId =
                                    //                           _upiResponse
                                    //                                   .transactionId ??
                                    //                               'N/A';
                                    //                       String resCode =
                                    //                           _upiResponse
                                    //                                   .responseCode ??
                                    //                               'N/A';
                                    //                       String txnRef =
                                    //                           _upiResponse
                                    //                                   .transactionRefId ??
                                    //                               'N/A';
                                    //                       String status =
                                    //                           _upiResponse
                                    //                                   .status ??
                                    //                               'N/A';
                                    //                       String approvalRef =
                                    //                           _upiResponse
                                    //                                   .approvalRefNo ??
                                    //                               'N/A';
                                    //                       _checkTxnStatus(
                                    //                           status);
                                    //
                                    //                       return Padding(
                                    //                         padding:
                                    //                             const EdgeInsets
                                    //                                 .all(8.0),
                                    //                         child: Column(
                                    //                           mainAxisAlignment:
                                    //                               MainAxisAlignment
                                    //                                   .center,
                                    //                           children: <
                                    //                               Widget>[
                                    //                             displayTransactionData(
                                    //                                 'Transaction Id',
                                    //                                 txnId),
                                    //                             displayTransactionData(
                                    //                                 'Response Code',
                                    //                                 resCode),
                                    //                             displayTransactionData(
                                    //                                 'Reference Id',
                                    //                                 txnRef),
                                    //                             displayTransactionData(
                                    //                                 'Status',
                                    //                                 status
                                    //                                     .toUpperCase()),
                                    //                             displayTransactionData(
                                    //                                 'Approval No',
                                    //                                 approvalRef),
                                    //                           ],
                                    //                         ),
                                    //                       );
                                    //                     } else
                                    //                       return Center(
                                    //                         child: Text(''),
                                    //                       );
                                    //                   },
                                    //                 );
                                    //               },
                                    //             ),
                                    //           )
                                    //         ],
                                    //       ),
                                    //     );
                                    //   },
                                    // );
                                    // openCheckout(amount: 100 * 99);
                                  },
                                  height: 62.h,
                                  minWidth: Get.width,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    side: BorderSide(
                                        color: PickColor.buttonColor),
                                  ),
                                  child: CommonText(
                                    text: 'Pay with RazorPay',
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: PickColor.buttonColor,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 26.h),
                      Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: Color(0xffF8EEF3),
                          borderRadius: BorderRadius.circular(19.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 20.h),
                          child: Column(
                            children: [
                              SizedBox(height: 19.h),
                              CommonText(
                                text: 'Annual',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              SizedBox(height: 33.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonText(
                                    text: '₹999',
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  CommonText(
                                    text: '/Year',
                                    fontSize: 40.sp,
                                    color: PickColor.secondary1TextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              SizedBox(height: 27.h),
                              CommonText(
                                text: 'valid for 1 year',
                                fontSize: 16.sp,
                                color: PickColor.secondary1TextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(height: 36.h),
                              // CommonButton(
                              //   text: 'Pay with Upi',
                              //   onPressed: () async {
                              //     setState(() {
                              //       paying = 999;
                              //     });
                              //     showModalBottomSheet(
                              //       isScrollControlled: true,
                              //       backgroundColor: Colors.transparent,
                              //       context: context,
                              //       builder: (BuildContext context) {
                              //         return Container(
                              //           height: 500.h,
                              //           decoration: BoxDecoration(
                              //             borderRadius:
                              //                 BorderRadius.circular(10.r),
                              //             color: Colors.white,
                              //           ),
                              //           margin: EdgeInsets.only(
                              //             bottom: 40.h,
                              //             left: 20.w,
                              //             right: 20.w,
                              //           ),
                              //           child: Column(
                              //             children: <Widget>[
                              //               displayUpiApps(),
                              //               Expanded(
                              //                 child: StatefulBuilder(
                              //                   builder: (BuildContext context,
                              //                       void Function(
                              //                               void Function())
                              //                           setState) {
                              //                     return FutureBuilder(
                              //                       future: _transaction,
                              //                       builder:
                              //                           (BuildContext context,
                              //                               AsyncSnapshot<
                              //                                       UpiResponse>
                              //                                   snapshot) {
                              //                         if (snapshot
                              //                                 .connectionState ==
                              //                             ConnectionState
                              //                                 .done) {
                              //                           if (snapshot.hasError) {
                              //                             return Center(
                              //                               child: Text(
                              //                                 _upiErrorHandler(
                              //                                     snapshot.error
                              //                                         .runtimeType),
                              //                                 style: header,
                              //                               ), // Print's text message on screen
                              //                             );
                              //                           }
                              //
                              //                           // If we have data then definitely we will have UpiResponse.
                              //                           // It cannot be null
                              //                           UpiResponse
                              //                               _upiResponse =
                              //                               snapshot.data!;
                              //
                              //                           // Data in UpiResponse can be null. Check before printing
                              //                           String txnId = _upiResponse
                              //                                   .transactionId ??
                              //                               'N/A';
                              //                           String resCode =
                              //                               _upiResponse
                              //                                       .responseCode ??
                              //                                   'N/A';
                              //                           String txnRef = _upiResponse
                              //                                   .transactionRefId ??
                              //                               'N/A';
                              //                           String status =
                              //                               _upiResponse
                              //                                       .status ??
                              //                                   'N/A';
                              //                           String approvalRef =
                              //                               _upiResponse
                              //                                       .approvalRefNo ??
                              //                                   'N/A';
                              //                           _checkTxnStatus(status);
                              //
                              //                           return Padding(
                              //                             padding:
                              //                                 const EdgeInsets
                              //                                     .all(8.0),
                              //                             child: Column(
                              //                               mainAxisAlignment:
                              //                                   MainAxisAlignment
                              //                                       .center,
                              //                               children: <Widget>[
                              //                                 displayTransactionData(
                              //                                     'Transaction Id',
                              //                                     txnId),
                              //                                 displayTransactionData(
                              //                                     'Response Code',
                              //                                     resCode),
                              //                                 displayTransactionData(
                              //                                     'Reference Id',
                              //                                     txnRef),
                              //                                 displayTransactionData(
                              //                                     'Status',
                              //                                     status
                              //                                         .toUpperCase()),
                              //                                 displayTransactionData(
                              //                                     'Approval No',
                              //                                     approvalRef),
                              //                               ],
                              //                             ),
                              //                           );
                              //                         } else
                              //                           return Center(
                              //                             child: Text(''),
                              //                           );
                              //                       },
                              //                     );
                              //                   },
                              //                 ),
                              //               )
                              //             ],
                              //           ),
                              //         );
                              //       },
                              //     );
                              //     // var m = DateTime.parse(
                              //     //     '2021-09-19 18:55:22.448842');
                              //     // final birthday = DateTime(1967, 10, 12);
                              //     // final date2 = DateTime.now();
                              //     // final difference =
                              //     //     date2.difference(birthday).inDays;
                              //   },
                              // ),
                              SizedBox(height: 14.h),
                              CommonButton(
                                  onPressed: () {
                                    print('Razorpay');
                                    setState(() {
                                      amounts = 999;
                                    });
                                    openCheckout(amount: 100 * 999);
                                    // Get.back();
                                  },
                                  text: 'Pay with Razorpay'),
                              SizedBox(
                                height: 100.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // SizedBox(height: 46.h),
                      // CommonText(
                      //   text: 'QR Code for UPI Payments',
                      //   fontSize: 20.sp,
                      //   fontWeight: FontWeight.w600,
                      // ),
                      // SizedBox(height: 39.h),
                      // CommonText(
                      //   text:
                      //       'You can also scan the QR code below to pay.\n Please add your email address in the\n transaction description.',
                      //   fontSize: 14.sp,
                      //   textAlign: TextAlign.center,
                      //   fontWeight: FontWeight.w500,
                      //   color: PickColor.secondaryTextColor,
                      // ),
                      // SizedBox(height: 43.h),
                      // SvgPicture.asset(
                      //   'assets/images/svg/qr.svg',
                      //   height: 394.h,
                      //   width: 394.w,
                      // ),
                      // CommonText(
                      //   text: 'bhgsbjih@lihsdxj',
                      //   fontSize: 14.sp,
                      //   textAlign: TextAlign.center,
                      //   fontWeight: FontWeight.w500,
                      //   color: PickColor.secondaryTextColor,
                      // ),
                      // SizedBox(height: 46.h),
                    ],
                  ),
                ),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child:
                          Lottie.asset('assets/images/png/no_internet2.json')),
                  SizedBox(height: 30.h),
                  Text('Please Check Your Internet Connection',
                      style: TextStyle(
                          fontSize: 20.sp, color: PickColor.buttonColor)),
                ],
              );
            }
          },
        ));
  }
}
