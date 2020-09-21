import 'package:flutter/material.dart';

const double _kAlphabetItemSize = 48;
const double _kCharItemSize = 72;

class ContactsListView extends StatefulWidget {
  final List<String> contacts;
  final IndexedWidgetBuilder itemBuilder;
  final WidgetBuilder titleBuilder;
  final double itemHeight;

  final List<HeaderSection> headers;

  ContactsListView(
    this.contacts, {
    @required this.itemHeight,
    @required this.itemBuilder,
    this.titleBuilder,
    this.headers,
    Key key,
  }) : super(key: key);

  @override
  ContactsListViewState createState() => ContactsListViewState();
}

class ContactsListViewState extends State<ContactsListView> {
  ScrollController _scrollController;

  String currentChar = '';

  List<String> indexes;

  Map<String, int> indexesPositions = {};
  Map<String, int> contactsPositions = {};

  @override
  void initState() {
    _scrollController = ScrollController();
    _init();
    super.initState();
  }

  void _init() {
    _initIndexesPositions(
      widget.contacts,
      widget.titleBuilder != null,
      widget.headers,
    );
  }

  @override
  void didUpdateWidget(ContactsListView oldWidget) {
    _init();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _initIndexesPositions(List<String> contacts, bool withTitle,
      List<HeaderSection> headerSections) {
    int headersItemCount = 0;
    headerSections?.forEach((element) {
      if (element.index?.isNotEmpty ?? false) {
        indexesPositions[element.index] = headersItemCount;
      }
      if (element.itemCount > 0) {
        headersItemCount +=
            element.itemCount + (element.titleBuilder != null ? 1 : 0);
      }
    });
    if (withTitle) headersItemCount++;

    for (var i = headersItemCount;
        i < contacts.length + headersItemCount;
        i++) {
      final contact = contacts[i - headersItemCount];
      contactsPositions[contact] = i;

      final firstChar = contact[0];

      if (!indexesPositions.containsKey(firstChar)) {
        indexesPositions[firstChar] = i;
      }
    }
  }

  void _scrollToItems(String char) {
    final indexToGo = indexesPositions[char];
    _animateTo(indexToGo);
  }

  void scrollToText(String text) {
    final contact = contactsPositions.keys.firstWhere(
        (element) => element.toLowerCase().contains(text.toLowerCase()),
        orElse: () => null);
    if (contact != null) {
      final indexToGo = contactsPositions[contact];
      _animateTo(indexToGo);
    }
  }

  void _animateTo(int indexToGo) {
    double dyToGo = indexToGo * widget.itemHeight;

    if (dyToGo >= _scrollController.position.maxScrollExtent) {
      dyToGo = _scrollController.position.maxScrollExtent;
    }

    setState(() {
      _scrollController.animateTo(
        dyToGo,
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  void _hideCharPreview() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        currentChar = "";
      });
    });
  }

  void _showCharPreview(String char) {
    setState(() {
      currentChar = char;
    });
  }

  SliverFixedExtentList _buildContactSection(IndexedWidgetBuilder itemBuilder,
      WidgetBuilder titleBuilder, int itemCount) {
    final withTitle = titleBuilder != null;
    final swift = (withTitle ? 1 : 0);
    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0 && withTitle) return titleBuilder(context);
          return itemBuilder(context, index - swift);
        },
        childCount: itemCount + swift,
      ),
      itemExtent: widget.itemHeight,
    );
  }

  Widget _indexes(BuildContext context, List<String> items) {
    return Container(
      width: 48,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final char = items[index];
          return AlphabetItem(
            char,
            onTapDown: () => _showCharPreview(char),
            onTapUp: () {
              _scrollToItems(char);
              _hideCharPreview();
            },
            onTapCancel: _hideCharPreview,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Scrollbar(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    ...?widget.headers
                        ?.where((element) => element.itemCount > 0)
                        ?.map((element) {
                      return _buildContactSection(
                        element.itemBuilder,
                        element.titleBuilder,
                        element.itemCount,
                      );
                    })?.toList(),
                    _buildContactSection(
                      widget.itemBuilder,
                      widget.titleBuilder,
                      widget.contacts.length,
                    )
                  ],
                ),
              ),
            ),
            _indexes(context, indexesPositions.keys.toList())
          ],
        ),
        if (currentChar.isNotEmpty) CurrentChar(char: currentChar),
      ],
    );
  }
}

class CurrentChar extends StatelessWidget {
  const CurrentChar({
    Key key,
    @required this.char,
  }) : super(key: key);

  final String char;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: _kCharItemSize,
        width: _kCharItemSize,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: Colors.black.withAlpha(80),
        ),
        child: Center(
          child: Text(
            char,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36.0,
            ),
          ),
        ),
      ),
    );
  }
}

class AlphabetItem extends StatelessWidget {
  final String char;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  const AlphabetItem(
    this.char, {
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: (_) => onTapDown(),
      onTap: onTapUp,
      onTapCancel: onTapCancel,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        height: _kAlphabetItemSize,
        width: _kAlphabetItemSize,
        child: Center(
          child: Text(
            char,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderSection {
  final int itemCount;
  final String index;
  final IndexedWidgetBuilder itemBuilder;
  final WidgetBuilder titleBuilder;

  HeaderSection({
    @required this.itemCount,
    @required this.itemBuilder,
    this.index,
    this.titleBuilder,
  });
}
