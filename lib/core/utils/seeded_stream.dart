/// Emits [currentValue] immediately, then forwards [stream] events.
/// Prevents StreamProviders from staying in loading when the service
/// already emitted its initial value before subscription.
Stream<T> seededStream<T>(T currentValue, Stream<T> stream) async* {
  yield currentValue;
  yield* stream;
}
