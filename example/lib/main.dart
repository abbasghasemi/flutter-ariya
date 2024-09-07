import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ariya/ariya.dart';

void main() async {
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const AriyaActivity(),
    );
  }
}

class AriyaActivity extends StatelessWidget {
  const AriyaActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final controller1 = SeekBarController(
      min: 0,
      max: 20,
      first: 5.5,
      last: 15,
    );
    final controller2 = SeekBarController(
      min: 0,
      max: 1,
      first: 0,
      last: 0.5,
    );
    final controller3 = SeekBarController(
      min: 0,
      max: 1,
      first: 0,
      last: 0.1,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ariya"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 32,
            runSpacing: 32,
            children: [
              const SizedBox(width: double.infinity, child: Text("Progress")),
              ProgressLineWaveIndicator(
                color: Colors.primaries[0],
              ),
              ProgressLineWaveIndicator(
                color: Colors.primaries[1],
                timing: 0.4,
              ),
              ProgressLineWaveIndicator(
                color: Colors.primaries[2],
                timing: 0.9,
              ),
              ProgressLineWaveIndicator(
                color: Colors.primaries[3],
                timing: 0,
              ),
              ProgressCircularIndicator(
                color: Colors.primaries[4],
              ),
              ProgressCircularIndicator(
                color: Colors.primaries[5],
                value: 0.4,
                backgroundWidth: 1,
                strokeWidth: 5,
                strokeCap: StrokeCap.square,
                backgroundColor: Colors.blueGrey,
              ),
              ProgressCircularDotsIndicator(
                color: Colors.primaries[6],
              ),
              ProgressCircularDotsIndicator(
                color: Colors.primaries[7],
                scaled: false,
              ),
              ProgressCircularDotsIndicator(
                color: Colors.primaries[8],
                scaled: false,
                faded: false,
                duration: const Duration(milliseconds: 2000),
                rotated: true,
              ),
              ProgressBallWaveIndicator(
                color: Colors.primaries[9],
              ),
              ProgressBallWaveIndicator(
                color: Colors.primaries[10],
                timing: 0.3,
              ),
              ProgressBallWaveIndicator(
                color: Colors.primaries[11],
                timing: 0.5,
              ),
              ProgressCircleWaveIndicator(
                color: Colors.primaries[12],
              ),
              ProgressLinearIndicator(
                fromProgress: .3,
                radius: const Radius.circular(5),
                height: 15,
                // If the height is greater than the width, it changes to the vertical state
                backgroundGradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.blue.shade100]),
                gradient: LinearGradient(
                    colors: [Colors.green.shade500, Colors.yellow.shade500]),
                progress: .6,
              ),
              const SizedBox(width: double.infinity, child: Text("Component")),
              Row(
                children: [
                  Expanded(
                    child: SeekBar(
                      controller: controller1,
                      interval: true,
                      onChange: (f, l) {},
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ListenableBuilder(
                    listenable: controller1,
                    builder: (context, _) {
                      return SizedBox(
                          width: 120,
                          child: Text(
                              "${controller1.first.toStringAsFixed(3)} - ${controller1.last.toStringAsFixed(3)}"));
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SeekBar(
                      controller: controller2,
                      radius: const Radius.circular(5),
                      thumpColor: Colors.yellow,
                      thumpRadius: const Radius.circular(3),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ListenableBuilder(
                    listenable: controller2,
                    builder: (context, _) {
                      return SizedBox(
                          width: 45,
                          child: Text(controller2.last.toStringAsFixed(3)));
                    },
                  ),
                ],
              ),
              Stack(
                children: [
                  SeekBar(
                    height: 42,
                    padding: EdgeInsets.zero,
                    controller: controller3,
                    thumpSize: 0,
                    background: Colors.grey.withOpacity(0.5),
                    radius: const Radius.circular(7),
                    onChange: (f, l) {},
                  ),
                  AnimatedBuilder(
                    animation: controller3,
                    builder: (context, w) => Positioned(
                      top: 10,
                      left: max(
                          5,
                          controller3.last * MediaQuery.of(context).size.width -
                              65),
                      child: Text((controller3.last * 100).toInt().toString()),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: double.infinity, child: Text("Indicator")),
              PageIndicatorDemo(),
            ],
          ),
        ),
      ),
    );
  }
}

class PageIndicatorDemo extends StatelessWidget {
  final PageController _pageController = PageController();

  PageIndicatorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      7,
      (index) => Container(
        color: Colors.accents[index],
        child: Center(child: Text("Page ${index + 1}")),
      ),
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          children: [
            PageViewIndicator(
              size: const Size(200, 20),
              controller: _pageController,
              count: items.length,
            ),
            PageViewIndicator(
              size: const Size(200, 30),
              controller: _pageController,
              count: items.length,
              indicatorSmooth: false,
              indicatorSpace: 5,
              indicatorSize: 20,
              indicatorColor: Colors.red.shade200,
              indicatorSelectedColor: Colors.red,
              indicatorRadius: const Radius.circular(7),
            ),
            PageViewIndicator(
              size: const Size(200, 20),
              controller: _pageController,
              count: items.length,
              indicatorSmooth: false,
              indicatorSpace: 3,
              indicatorStrokeWidth: 1,
              indicatorColor: Colors.pinkAccent,
              indicatorStyle: PaintingStyle.stroke,
              indicatorSelectedColor: Colors.yellow,
              indicatorRadius: Radius.zero,
            ),
          ],
        ),
        const SizedBox(
          width: 8,
        ),
        SizedBox.square(
          dimension: 200,
          child: PageView(
            scrollBehavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: items,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        PageViewIndicator(
          size: const Size(20, 200),
          indicatorRadius: const Radius.circular(4),
          indicatorColor: Colors.green.shade100,
          indicatorSelectedColor: Colors.green,
          controller: _pageController,
          count: items.length,
          onClick: (index) {
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutBack);
          },
        ),
      ],
    );
  }
}
