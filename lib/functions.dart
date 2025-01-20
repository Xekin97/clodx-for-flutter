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

ClodVisitor<T> visitClod<T>(Clod<ClodValueType<T>> clod) {
  return ClodVisitor(clod);
}

ClodController<T> controlClod<T>(Clod<ClodValueType<T>> clod) {
  return ClodController(clod);
}
