import 'dart:math';

import 'package:flutter/material.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/models/split_bill_comment_model.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

const List<Color> _participantPalette = [
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

class SplitBillCommentsView extends StatefulWidget {
  final String billId;
  final String? participantId;

  const SplitBillCommentsView({
    super.key,
    required this.billId,
    required this.participantId,
  });

  @override
  State<SplitBillCommentsView> createState() => _SplitBillCommentsViewState();
}

class _SplitBillCommentsViewState extends State<SplitBillCommentsView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, Color> _participantColors = {};
  final Random _random = Random();

  List<SplitBillComment> _comments = [];
  bool _loading = true;
  String? _editingCommentId;
  String? _currentAuthorId;
  String? _currentDisplayName;

  @override
  void initState() {
    super.initState();
    final user = UserLocalStorageService().getUserData();
    _currentAuthorId = user?.id?.toString();
    final fullName =
        '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    _currentDisplayName = fullName.isNotEmpty
        ? fullName
        : (user?.username ?? 'You');
    _loadComments();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _colorForParticipant(String? participantId) {
    final key = participantId ?? 'unknown';
    return _participantColors.putIfAbsent(
      key,
      () => _participantPalette[_random.nextInt(_participantPalette.length)],
    );
  }

  Future<void> _loadComments() async {
    final provider = context.read<NewSplitBillProvider>();
    final comments = await provider.getSplitBillComments(widget.billId);
    if (!mounted) return;
    setState(() {
      _comments = comments;
      _loading = false;
    });
    _scrollToBottom();
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
    final participantId = widget.participantId;
    if (participantId == null || participantId.isEmpty) {
      showErrorToast('Only participants can comment');
      return;
    }
    final provider = context.read<NewSplitBillProvider>();
    final isEditing = _editingCommentId != null;
    final editingId = _editingCommentId;

    if (isEditing) {
      final originalIndex =
          _comments.indexWhere((c) => c.id == editingId);
      SplitBillComment? original;
      if (originalIndex != -1) {
        original = _comments[originalIndex];
        setState(() {
          _comments[originalIndex] = SplitBillComment(
            id: original!.id,
            content: text,
            displayName: original.displayName,
            displayType: original.displayType,
            participantId: original.participantId,
            authorId: original.authorId,
            isGuest: original.isGuest,
            isPinned: original.isPinned,
            isEdited: true,
            editedAt: DateTime.now(),
            transactionId: original.transactionId,
            createdAt: original.createdAt,
          );
          _editingCommentId = null;
          _inputController.clear();
        });
      }
      final success = await provider.editParticipantComment(
        billId: widget.billId,
        participantId: participantId,
        commentId: editingId!,
        content: text,
      );
      if (!mounted) return;
      if (success) {
        _loadComments();
      } else {
        if (originalIndex != -1 && original != null) {
          setState(() => _comments[originalIndex] = original!);
        }
        showErrorToast('Failed to update comment');
      }
      return;
    }

    final tempId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = SplitBillComment(
      id: tempId,
      content: text,
      displayName: _currentDisplayName,
      displayType: 'full_name',
      participantId: participantId,
      authorId: _currentAuthorId,
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments = [..._comments, optimistic];
      _inputController.clear();
    });
    _scrollToBottom();

    final success = await provider.addParticipantComment(
      billId: widget.billId,
      participantId: participantId,
      content: text,
    );
    if (!mounted) return;
    if (success) {
      _loadComments();
    } else {
      setState(() {
        _comments = _comments.where((c) => c.id != tempId).toList();
      });
      showErrorToast('Failed to post comment');
    }
  }

  Future<void> _deleteComment(SplitBillComment comment) async {
    if (comment.id == null) return;
    final participantId = comment.participantId ?? widget.participantId ?? '';
    if (participantId.isEmpty) return;
    final provider = context.read<NewSplitBillProvider>();
    final success = await provider.deleteParticipantComment(
      billId: widget.billId,
      participantId: participantId,
      commentId: comment.id!,
    );
    if (!mounted) return;
    if (success) {
      await _loadComments();
    } else {
      showErrorToast('Failed to delete comment');
    }
  }

  void _startEdit(SplitBillComment comment) {
    setState(() {
      _editingCommentId = comment.id;
      _inputController.text = comment.content ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
      _inputController.clear();
    });
  }

  void _showCommentActions(SplitBillComment comment) {
    final isAuthor =
        _currentAuthorId != null && comment.authorId == _currentAuthorId;
    if (!isAuthor) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit comment'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _startEdit(comment);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete comment',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _deleteComment(comment);
                },
              ),
            ],
          ),
        );
      },
    );
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
    if (_loading) {
      return const Center(child: UiBusyWidget(height: 100));
    }
    if (_comments.isEmpty) {
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
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        return _buildCommentRow(_comments[index]);
      },
    );
  }

  Widget _buildCommentRow(SplitBillComment comment) {
    final color = _colorForParticipant(comment.participantId);
    final name = (comment.displayName ?? '').trim().isEmpty
        ? 'Anonymous'
        : comment.displayName!;
    final isAuthor =
        _currentAuthorId != null && comment.authorId == _currentAuthorId;

    return GestureDetector(
      onLongPress: isAuthor ? () => _showCommentActions(comment) : null,
      child: Padding(
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
                text: "${name}:",
                style: txStyle12.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '  '),
              TextSpan(text: comment.content ?? ''),
              if (comment.isEdited)
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
      ),
    );
  }

  Widget _buildInputBar() {
    final isEditing = _editingCommentId != null;
    final canPost =
        widget.participantId != null && widget.participantId!.isNotEmpty;
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
                "Only participants on this bill can comment.",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.edit, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Text(
                    "Editing comment",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelEdit,
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 12,
                        color: appSecondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
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
    final hasText = _inputController.text.trim().isNotEmpty;
    final enabled = canPost && hasText;
    return GestureDetector(
      onTap: enabled ? _submit : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? appPrimaryColor : Colors.grey[400],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send, color: Colors.white, size: 20),
      ),
    );
  }
}
