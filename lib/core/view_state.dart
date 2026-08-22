
sealed class ViewState<T> {
  const ViewState();

  const factory ViewState.initial() = ViewInitial<T>;
  const factory ViewState.loading() = ViewLoading<T>;
  const factory ViewState.success(T data) = ViewSuccess<T>;
  const factory ViewState.empty() = ViewEmpty<T>;
  const factory ViewState.error(String message) = ViewError<T>;
}

final class ViewInitial<T> extends ViewState<T> {
  const ViewInitial();
}

final class ViewLoading<T> extends ViewState<T> {
  const ViewLoading();
}

final class ViewSuccess<T> extends ViewState<T> {
  final T data;
  const ViewSuccess(this.data);
}

final class ViewEmpty<T> extends ViewState<T> {
  const ViewEmpty();
}

final class ViewError<T> extends ViewState<T> {
  final String message;
  const ViewError(this.message);
}