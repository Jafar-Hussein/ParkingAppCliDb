import 'dart:collection';

abstract interface class Repository<T> {
 Future<T> create(T item);
  Future<List<T>> getAll();
  Future<T?> getById(int id);
  Future<T> update(int id, T item);
  Future<T> delete(int id);
}
