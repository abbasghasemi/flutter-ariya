[![Latest version](https://img.shields.io/pub/v/ariya.svg)](https://pub.dev/packages/ariya)

<h1 style="text-align: center">Ariya</h1>

### A collection of widgets for flutter (components, effects, progress and page indicator ...)

## Features

![Demo](https://github.com/abbasghasemi/flutter-ariya/blob/master/example/demo.gif?raw=true)

### Components

- SeekBar

![Demo](https://github.com/abbasghasemi/flutter-ariya/blob/master/example/shimmer.gif?raw=true)

- Shimmer

### Page indicator

- PageViewIndicator

### Progress

- ProgressBallWaveIndicator
- ProgressCircleWaveIndicator
- ProgressCircularDotsIndicator
- ProgressCircularIndicator
- ProgressLineWaveIndicator
- ProgressLinearIndicator

### Effect
![Demo](https://github.com/abbasghasemi/flutter-ariya/blob/master/example/effectFireworks.gif?raw=true)

- EffectFireworks

![Demo](https://github.com/abbasghasemi/flutter-ariya/blob/master/example/effectConfetti.gif?raw=true)

- EffectConfetti

## Getting started

```shell
flutter pub add ariya
```

## Usage

### Sample SeekBar
```dart
SeekBar(
  controller: controller,
  radius: const Radius.circular(5),
  thumpColor: Colors.yellow,
  thumpRadius: const Radius.circular(3),
)
```

### Sample Shimmer
```dart
Shimmer(
  child: Container(width: 50, height: 10, color: Colors.blue),
)
```

### Sample PageViewIndicator
```dart
PageViewIndicator(
  size: const Size(200, 20),
  controller: pageController,
  count: items.length,
  indicatorSmooth: true,
  indicatorSelectedColor: Colors.blue,
  indicatorRadius: Radius.circular(6),
)
```

### Sample ProgressBallWaveIndicator
```dart
ProgressBallWaveIndicator(
  color: Colors.primaries[9],
)
```

### Sample ProgressCircleWaveIndicator
```dart
ProgressCircleWaveIndicator(
  color: Colors.primaries[9],
)
```

### Sample ProgressCircularDotsIndicator
```dart
ProgressCircularDotsIndicator(
  color: Colors.primaries[9],
)
```

### Sample ProgressCircularIndicator
```dart
ProgressCircularIndicator(
  color: Colors.primaries[9],
)
```

### Sample ProgressLineWaveIndicator
```dart
ProgressLineWaveIndicator(
  color: Colors.primaries[9],
)
```

### Sample ProgressLinearIndicator
```dart
ProgressLinearIndicator(
  progress: 0.6,
)
```
## Additional information

* [Home page](https://github.com/abbasghasemi/flutter-ariya)

* [Issues](https://github.com/abbasghasemi/flutter-ariya/issues)
> You can help us to keep my open source projects up to date!