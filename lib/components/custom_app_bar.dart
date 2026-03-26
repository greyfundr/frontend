import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final Widget? content;
  final bool hasDrawer;
  final List<Widget>? actions;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool centerTitle;
  final VoidCallback? onBack;
  const CustomAppBar({
    super.key,
    this.title = "",
    this.leading,
    this.content,
    this.actions,
    this.hasDrawer = false,
    this.scaffoldKey,
    this.centerTitle = true,
    this.onBack
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  AppBar build(BuildContext context) {
    return AppBar(
    centerTitle: widget.centerTitle,
      actions: widget.actions,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: widget.content != null ? true : false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      leadingWidth: 70,
      leading: widget.hasDrawer
          ? IconButton(
              onPressed: () {
                print(widget.scaffoldKey!.currentState!.isDrawerOpen);
                widget.scaffoldKey!.currentState!.openDrawer();
              },
              icon: const Icon(Icons.menu),
            )
          : Padding(
              padding: EdgeInsets.only(left: SizeConfig.widthOf(5)),
              child:
                  widget.leading ??
                  SizedBox(
                    height: 40,
                    child: AdaptiveIcons(
                      onTap: () {widget.onBack != null ? widget.onBack!() : Get.close(1);},
                      iconName: "arrow.left.circle",
                      iconData: Icons.arrow_back,
                    ),
                  ),
            ),
      title:
          widget.content ??
          Text(
            widget.title,
            style: txStyle20.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
          ),
      elevation: 0,
    );
  }
}
