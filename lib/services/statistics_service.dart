import 'api_client.dart';

class StatisticsService {
  StatisticsService(this.client);

  final ApiClient client;

  Future<dynamic> tasks() => client.get('/statistics/tasks');
  Future<dynamic> assignments() => client.get('/statistics/assignments');
  Future<dynamic> deadlines() => client.get('/statistics/deadlines');
}
