import 'dart:math' as math;

import 'package:fintrack/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center ,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.0,
                      backgroundImage: AssetImage('assets/profile.jpeg'),
                    ),
                    SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Putri",
                          style: TextStyle(
                            color: ColorPallete.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Otw kaya",
                          style: TextStyle(
                            color: ColorPallete.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.notifications_none_outlined,
                  size: 34,
                  color: ColorPallete.white,
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 28
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 62, 96, 39),
                    const Color.fromARGB(255, 30, 50, 30),
                    const Color.fromARGB(255, 25, 42, 25),
                    const Color.fromARGB(255, 49, 102, 39),
                  ],
                  transform: GradientRotation(220 * (math.pi / 180)),
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                spacing: 4,
                children: [
                  Text(
                    "Total Uang",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    "Rp1.000.000",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8F5C7),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.arrow_down,
                                color: const Color(0xFF2D4C2D),
                                size: 18
                              )
                            )
                          ),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text(
                                "Pendapatan",
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              Text(
                                "Rp100.000",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8F5C7),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.arrow_up,
                                color: const Color(0xFFD84747) ,
                                size: 18
                              )
                            )
                          ),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text(
                                "Pengeluaran",
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              Text(
                                "Rp100.000",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ]
                    
                  )
                ],
              ),
            ),
            SizedBox(height: 36.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transaksi Terbaru",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "Lihat semua",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: ColorPallete.greenLight,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  )
                )
              ],
            ),
            SizedBox(height: 12.0),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: ColorPallete.black,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        "Kebutuhan",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Makan bakso",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300
                        )
                      )
                    ]
                  ),
                  Text(
                    "Rp 15.000",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      // color: ColorPallete.greenLight
                    )
                  ),
                ]
              ),
            ),
            SizedBox(height: 12.0),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: ColorPallete.black,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        "Kebutuhan",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Makan bakso",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300
                        )
                      )
                    ]
                  ),
                  Text(
                    "Rp 15.000",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      // color: ColorPallete.red,
                    )
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
