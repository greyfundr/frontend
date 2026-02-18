// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';

class CustomTextField extends StatefulWidget {
  final bool darkenText;
  final bool? hasLeading;
  final bool? isDate;
  final bool isCard;
  final bool? readOnly;
  final bool? changePhoneNumber;
  final int? maxLines;
  final String? prefix;
  final String? hintText;
  final String? labelText;
  final bool? hasBorder;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String? imgUri;
  final bool isRequired;
  final bool autoFocus;
  final TextInputFormatter? formatters;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? onChanged;

  ///labelText cannot be used when hintText is used
  const CustomTextField({
    super.key,
    this.hasLeading = false,
    this.isDate = false,
    this.isCard = false,
    this.readOnly = false,
    this.changePhoneNumber = false,
    this.formatters,
    this.maxLines,
    this.validator,
    this.prefix,
    this.hintText,
    this.labelText,
    this.hasBorder,
    this.obscureText = false,
    this.suffixIcon,
    this.onTap,
    this.imgUri,
    this.controller,
    this.textInputAction = TextInputAction.done,
    this.textInputType,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.onChanged,
    this.darkenText = false,
    this.isRequired = false,
    this.autoFocus = false,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool hide = false;
  FocusNode myFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    hide = widget.obscureText;
    if (widget.autoFocus) {
      myFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          myFocusNode.requestFocus();
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText?.isNotEmpty ?? false)
            Row(
              children: [
                Text(
                  "${widget.labelText}",
                  style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                ),
                if (widget.isRequired)
                  Text(
                    "*",
                    style: txStyle13.copyWith(color: Colors.red),
                  ).paddingOnly(left: 2),
              ],
            ),
          Gap(5),
          Container(
            // height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: borderColor),
              // color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.prefix?.toString() ?? "",
                  ).paddingOnly(right: 5, bottom: 1),
                  Expanded(
                    child: TextFormField(
                      focusNode: myFocusNode,
                      autocorrect: false,
                      inputFormatters: [
                        widget.formatters ??
                            FilteringTextInputFormatter.deny(''),
                      ],
                      autovalidateMode: widget.autovalidateMode,
                      keyboardType: widget.textInputType,
                      textInputAction: widget.textInputAction,
                      readOnly: widget.readOnly!,
                      controller: widget.controller,
                      onTap: widget.onTap,
                      obscureText: hide,
                      obscuringCharacter: '•',
                      maxLines: widget.maxLines ?? 1,
                      validator: widget.validator,

                      onChanged: widget.onChanged,
                      style: txStyle15,
                      cursorColor: appPrimaryColor,

                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        // labelText: widget.labelText,
                        border: InputBorder.none,

                        isDense: true,
                        fillColor: Colors.transparent,

                        // filled: false,
                        //labelText: widget.labelTex
                        hintText: widget.hintText,
                        hintStyle: txStyle14.copyWith(
                          color: widget.darkenText
                              ? Theme.of(context).iconTheme.color
                              : Colors.grey,
                        ),
                        labelStyle: txStyle14,
                        // enabledBorder: OutlineInputBorder(
                        //   borderSide:
                        //       BorderSide(color: Color(0xff667080).withOpacity(0.4)),
                        //   borderRadius: BorderRadius.all(Radius.circular(10)),
                        // ),
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.all(Radius.circular(8)),
                        // ),
                        // suffixIcon: Icon(Icons.visibility_off)
                      ),
                    ),
                  ),
                  widget.obscureText
                      ? Row(
                          children: [
                            // horizontalx10,
                            InkWell(
                              onTap: () {
                                setState(() {
                                  hide = !hide;
                                });
                              },
                              child: hide
                                  ? const Icon(
                                      Icons.visibility_outlined,
                                      size: 20,
                                      color: Colors.grey,
                                    )
                                  : const Icon(
                                      Icons.visibility_off_outlined,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                            ),
                          ],
                        )
                      : widget.suffixIcon != null
                      ? widget.suffixIcon!
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function(String) onChange;
  final Function(String) onSubmit;

  const CustomSearchField({
    super.key,
    required this.textEditingController,
    required this.onChange,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.grey.withOpacity(.2),
      ),
      child: TextFormField(
        controller: textEditingController,
        cursorColor: appPrimaryColor,
        textAlignVertical: TextAlignVertical.center,
        maxLines: 1,
        onChanged: onChange,
        onFieldSubmitted: onSubmit,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        autocorrect: false,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
          hintText: "Search...",
          isDense: true,
          hintStyle: txStyle14.copyWith(color: greyTextColor),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.search, color: Colors.black),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 16, minHeight: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class CustomChatTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final bool autoFocus;
  final Function(String)? onChanged;

  const CustomChatTextField({
    super.key,
    this.hintText,
    this.controller,
    this.suffixIcon,
    this.autoFocus = false,
    this.onChanged,
  });

  @override
  State<CustomChatTextField> createState() => _CustomChatTextFieldState();
}

class _CustomChatTextFieldState extends State<CustomChatTextField> {
  FocusNode myFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    if (widget.autoFocus) {
      myFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                focusNode: myFocusNode,
                controller: widget.controller,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5, // Allow up to 5 lines
                keyboardType: TextInputType.multiline,
                onChanged: widget.onChanged,
                style: txStyle15,
                cursorColor: appPrimaryColor,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  isDense: true,
                  fillColor: Colors.transparent,
                  hintText: widget.hintText,
                  hintStyle: txStyle14.copyWith(color: Colors.grey),
                ),
              ),
            ),
            widget.suffixIcon != null
                ? widget.suffixIcon!
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
