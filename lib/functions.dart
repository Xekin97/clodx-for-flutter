import './main.dart';

NormalClod<T> clod<T>(T value, {bool Function(T prev, T next)? equal}) {
  return NormalClod<T>(ClodNormalValue(value, equal: equal));
}

PickClod<T> pickClod<T>(Picker<T> value,
    {bool Function(T prev, T next)? equal}) {
  return PickClod<T>(ClodPickValue(value, equal: equal));
}

MakeClod<T> makeClod<T>(Maker<T> value) {
  return MakeClod<T>(ClodMakeValue(value));
}

updatePickClod(PickClod clod) {
  clod.pick();
}

T getClod<T>(Clod<ClodValueType<T>> clod) {
  if (clod is NormalClod) {
    return (clod as NormalClod).current;
  }
  if (clod is PickClod) {
    return (clod as PickClod).pick();
  }

  throw Exception(
      "Can not get clod value from which except NormalClod or PickClod.");
}

T setClod<T>(Clod<ClodValueType<T>> clod, T value) {
  if (clod is NormalClod) {
    return (clod as NormalClod).make(value);
  }
  if (clod is MakeClod) {
    return (clod as MakeClod).make(value);
  }
  throw Exception(
      "Can not set clod value to which except NormalClod or MakeClod.");
}
