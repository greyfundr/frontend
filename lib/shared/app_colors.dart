import 'package:flutter/material.dart';

const appPrimaryColor = Color(0xff017981);

const appSecondaryColor = Color(0xffFC643A);


const greyTextColor = Color(0xff828282);

const borderColor = Color(0xffE0E0E0);

const Color debitColor = Color.fromARGB(255, 254, 237, 237);

const Color creditColor = Color.fromARGB(255, 232, 250, 228);

const Color criticalColor = Color(0xFFE91616);

const Color successColor = Color(0xFF32B113);

const Color unselectedBottomNavItemColor = Color(0xFF98A2B3);

const Color shimmerLoaderColor = Color(0xFFCCCCCC);

var subscriptionPlanGradient = LinearGradient(
  colors: [
    const Color(0xffAFD3FF),
    const Color(0xff127EFF),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);


var studyPlanContainerGradient = LinearGradient(
  colors: [
    const Color(0xffAFD3FF).withOpacity(.44),
    const Color(0xff127EFF).withOpacity(.6),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);