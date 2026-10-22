import 'package:flutter_test/flutter_test.dart';
import 'package:way_point/features/search/controllers/place_search_controller.dart';
import 'package:way_point/features/search/models/autocomplete_prediction_model.dart';

void main() {
  group('PlaceSearchController Unit Tests', () {
    late PlaceSearchController controller;

    setUp(() {
      controller = PlaceSearchController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state contains curated destinations and empty query', () {
      expect(controller.query, isEmpty);
      expect(controller.predictions, isEmpty);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.results, equals(PlaceSearchController.allDestinations));
    });

    test('onQueryChanged updates search query', () {
      controller.onQueryChanged('Savar');
      expect(controller.query, equals('Savar'));
    });

    test('selectCategory updates selected category and filters results', () {
      controller.selectCategory('heritage');
      expect(controller.selectedCategory, equals('heritage'));
      for (final place in controller.curatedDestinations) {
        expect(place.category, equals('heritage'));
      }
    });

    test('clear resets query, predictions, and error states', () {
      controller.onQueryChanged('Dhanmondi');
      controller.clear();

      expect(controller.query, isEmpty);
      expect(controller.predictions, isEmpty);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.results, equals(PlaceSearchController.allDestinations));
    });

    test('AutocompletePredictionModel parses JSON correctly', () {
      final json = {
        'place_id': 'ch_dhanmondi_123',
        'description': 'Dhanmondi, Dhaka, Bangladesh',
        'structured_formatting': {
          'main_text': 'Dhanmondi',
          'secondary_text': 'Dhaka, Bangladesh',
        },
        'types': ['locality', 'political'],
      };

      final prediction = AutocompletePredictionModel.fromJson(json);

      expect(prediction.placeId, equals('ch_dhanmondi_123'));
      expect(prediction.primaryText, equals('Dhanmondi'));
      expect(prediction.secondaryText, equals('Dhaka, Bangladesh'));
      expect(prediction.fullDescription, equals('Dhanmondi, Dhaka, Bangladesh'));
      expect(prediction.types, contains('locality'));
    });
  });
}
