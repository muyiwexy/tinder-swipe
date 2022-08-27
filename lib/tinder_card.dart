import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinder_app/cardprovider.dart';

class TinderCard extends StatefulWidget {
  final String assetImage;
  final bool isFront;

  const TinderCard({
    Key? key,
    required this.assetImage,
    required this.isFront,
  }) : super(key: key);

  @override
  State<TinderCard> createState() => _TinderCardState();
}

class _TinderCardState extends State<TinderCard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.setScreenSize(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: widget.isFront ? buildfirstcard() : buildCard(),
    );
  }

  Widget buildfirstcard() => GestureDetector(
        child: LayoutBuilder(builder: (context, constraints) {
          final provider = Provider.of<CardProvider>(context);
          final position = provider.position;
          final milliseconds = provider.isDragging ? 0 : 400;

          final center = constraints.smallest.center(Offset.zero);
          final angle = provider.angle * pi / 180;
          final rotatedMatrix = Matrix4.identity()
            ..translate(center.dx, center.dy)
            ..rotateZ(angle)
            ..translate(-center.dx, -center.dy);

          return AnimatedContainer(
              curve: Curves.easeInOut,
              duration: Duration(microseconds: milliseconds),
              transform: rotatedMatrix..translate(position.dx, position.dy),
              child: buildCard());
        }),
        onPanStart: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.startPosition(details);
        },
        onPanUpdate: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.updatePosition(details);
        },
        onPanEnd: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.endPosition();
        },
      );

  Widget buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: NetworkImage(widget.assetImage),
          fit: BoxFit.cover,
          // alignment: const Alignment(-0.3, 0)
        )),
      ),
    );
  }
}
