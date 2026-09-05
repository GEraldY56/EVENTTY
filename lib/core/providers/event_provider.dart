import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

// Event Service Provider
final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

// All Events Provider
final allEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final eventService = ref.watch(eventServiceProvider);
  return await eventService.getAllEvents();
});

// Featured Events Provider
final featuredEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final eventService = ref.watch(eventServiceProvider);
  return await eventService.getFeaturedEvents();
});

// Popular Events Provider
final popularEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final eventService = ref.watch(eventServiceProvider);
  return await eventService.getPopularEvents();
});

// Event by ID Provider
final eventByIdProvider = FutureProvider.family<EventModel?, String>((ref, id) async {
  final eventService = ref.watch(eventServiceProvider);
  return await eventService.getEventById(id);
});

// Events by Category Provider
final eventsByCategoryProvider = FutureProvider.family<List<EventModel>, String>((ref, category) async {
  final eventService = ref.watch(eventServiceProvider);
  return await eventService.getEventsByCategory(category);
});

// Events by Status Provider (for Admin)
final eventsByStatusProvider = FutureProvider.family<List<EventModel>, String>((ref, status) async {
  final eventService = ref.watch(eventServiceProvider);
  return await eventService.getEventsByStatus(status);
});

// Search Events Provider
final searchEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, query) async {
  final eventService = ref.watch(eventServiceProvider);
  return await eventService.searchEvents(query);
});

// Registered Events State Provider (untuk track user's registered events)
final registeredEventsProvider = StateProvider<Set<String>>((ref) {
  return {};
});
