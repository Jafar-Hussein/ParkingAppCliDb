import '../../../shared/lib/src/model/Person.dart';
import '../../../shared/lib/src/repository/Repository.dart';

class PersonRepo implements Repository<Person> {
  static final PersonRepo _instance = PersonRepo._internal();
  PersonRepo._internal();
  static PersonRepo get instance => _instance;

  @override
  Future<Person> create(Person person) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<Person> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<Person>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Person?> getById(int id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<Person> update(int id, Person person) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
