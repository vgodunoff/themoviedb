import 'package:flutter/material.dart';

import 'package:themoviedb/resources/resources.dart';

class MovieDetailsMainScreenCastWidget extends StatelessWidget {
  const MovieDetailsMainScreenCastWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Series cast',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            height: 300,
            child: Scrollbar(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 20,
                  itemExtent: 120,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  // blurRadius: 8.0 - размыли тень
                                  blurRadius: 8.0,
                                  //  Offset(0, 5) - тень по горизонтали 0, по вертикали опустили ниже на 5
                                  offset: const Offset(0, 5))
                            ],
                            border: Border.all(
                                color: Colors.black.withOpacity(0.2)),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            children: [
                              const Image(image: AssetImage(AppImages.actor)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Steve Carell',
                                      maxLines: 1,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      'Kevin / Stuart / Bob / Minions (voice)',
                                      maxLines: 1,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      'Episode',
                                      maxLines: 4,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextButton(
                onPressed: () {}, child: const Text('Full cast & crew')),
          ),
        ],
      ),
    );
  }
}
