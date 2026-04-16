class EditResult<T> {
  const EditResult({this.item, this.deleted = false});

  final T? item;
  final bool deleted;
}
