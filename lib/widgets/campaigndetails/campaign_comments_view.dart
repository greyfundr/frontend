import 'dart:math';

import 'package:flutter/material.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/models/campaign_comment_model.dart';
import 'package:greyfundr/core/providers/campaign_provider.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

const List<Color> _commentColors = [
  Color(0xFFE53E3E),
  Color(0xFFD69E2E),
  Color(0xFF38A169),
  Color(0xFF3182CE),
  Color(0xFF805AD5),
  Color(0xFFDD6B20),
  Color(0xFF319795),
  Color(0xFFD53F8C),
  Color(0xFF2B6CB0),
  Color(0xFF6B46C1),
  Color(0xFF2F855A),
  Color(0xFFB7791F),
];

class CampaignCommentsView extends StatefulWidget {
  final String campaignId;

  const CampaignCommentsView({super.key, required this.campaignId});

  @override
  State<CampaignCommentsView> createState() => _CampaignCommentsViewState();
}

class _CampaignCommentsViewState extends State<CampaignCommentsView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, Color> _userColors = {};
  final Random _random = Random();

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final user = UserLocalStorageService().getUserData();
    _currentUserId = user?.id?.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CampaignProvider>(context, listen: false)
          .fetchCampaignComments(widget.campaignId);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _colorForUser(String? userId) {
    final key = userId ?? 'unknown';
    return _userColors.putIfAbsent(
      key,
      () => _commentColors[_random.nextInt(_commentColors.length)],
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _submit() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final provider = context.read<CampaignProvider>();
    _inputController.clear();
    setState(() {});
    final ok = await provider.postCampaignComment(
      campaignId: widget.campaignId,
      content: text,
    );
    if (!mounted) return;
    if (ok) {
      _scrollToBottom();
    } else {
      _inputController.text = text;
      setState(() {});
      showErrorToast('Failed to post comment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.heightOf(70),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF1F1F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Expanded(child: _buildCommentList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentList() {
    final provider = Provider.of<CampaignProvider>(context);
    if (provider.commentsState == ViewState.Busy &&
        provider.comments.isEmpty) {
      return const Center(child: UiBusyWidget(height: 100));
    }
    if (provider.comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.forum_outlined, size: 42, color: Colors.grey[400]),
              const SizedBox(height: 10),
              Text(
                "No comments yet",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Be the first to leave a comment.",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.widthOf(3),
        vertical: 8,
      ),
      itemCount: provider.comments.length,
      itemBuilder: (context, index) {
        return _buildCommentRow(provider.comments[index]);
      },
    );
  }

  Widget _buildCommentRow(CampaignComment comment) {
    final color = _colorForUser(comment.userId);
    final name = comment.displayName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: "$name:",
              style: txStyle12.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: '  '),
            TextSpan(text: comment.content ?? ''),
            if (comment.isEdited == true)
              TextSpan(
                text: '  (edited)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final canPost = _currentUserId != null && _currentUserId!.isNotEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(
        SizeConfig.widthOf(3),
        8,
        SizeConfig.widthOf(3),
        12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF1F1F7),
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canPost)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Sign in to leave a comment.",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _inputController,
                  hintText: "Send a message...",
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  readOnly: !canPost,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              _buildSendButton(canPost),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(bool canPost) {
    final provider = Provider.of<CampaignProvider>(context);
    final hasText = _inputController.text.trim().isNotEmpty;
    final enabled = canPost && hasText && !provider.postingComment;
    return GestureDetector(
      onTap: enabled ? _submit : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? appPrimaryColor : Colors.grey[400],
          shape: BoxShape.circle,
        ),
        child: provider.postingComment
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send, color: Colors.white, size: 20),
      ),
    );
  }
}
