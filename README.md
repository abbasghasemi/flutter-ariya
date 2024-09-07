![Latest version](https://img.shields.io/badge/version-latest_version-blue)

<h1 style="text-align: center">Ariya</h1>

### A collection of widgets for flutter (components, progress and page indicator ...)

## Features

![Demo](https://github.com/abbasghasemi/flutter-ariya/blob/master/example/demo.gif?raw=true)

### Components

- SeekBar

### Page indicator

- PageViewIndicator

### Progress

- ProgressBallWaveIndicator
- ProgressCircleWaveIndicator
- ProgressCircularDotsIndicator
- ProgressCircularIndicator
- ProgressLineWaveIndicator
- ProgressLinearIndicator

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