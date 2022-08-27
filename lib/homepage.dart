import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinder_app/cardprovider.dart';
import 'package:tinder_app/tinder_card.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.redAccent,
        body: SafeArea(
            child: Column(
          children: <Widget>[
            const SizedBox(
              height: 40,
            ),
            const Text.rich(TextSpan(children: [
              TextSpan(
                  text: 'Tinder',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  
                ),
              WidgetSpan(child: Icon(Icons.fireplace))
            ])),
            const SizedBox(
              height: 40,
            ),
            Expanded(
                child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: buildCards(),
            )),
          ],
        )),
      );

  Widget buildCards() {
    final provider = Provider.of<CardProvider>(context);
    final assetImages = provider.assetImages;

    return assetImages.isEmpty
        ? Center(
            child: ElevatedButton(
                child: const Text('Restart'),
                onPressed: () {
                  final provider =
                      Provider.of<CardProvider>(context, listen: false);
                  provider.userimages();
                }))
        : Stack(
            children: assetImages
                .map((assetImage) => TinderCard(
                      assetImage: assetImage,
                      isFront: assetImages.last == assetImage,
                    ))
                .toList(),
          );
  }
}
