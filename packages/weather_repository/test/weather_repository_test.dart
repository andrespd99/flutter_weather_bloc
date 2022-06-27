// ignore_for_file: prefer_const_constructors
import 'package:accu_weather_api/accu_weather_api.dart' as accu_weather_api;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockAccuWeatherApiClient extends Mock
    implements accu_weather_api.AccuWeatherApiClient {}

class MockLocation extends Mock implements accu_weather_api.Location {}

class MockWeather extends Mock implements accu_weather_api.Weather {}

void main() {
  group('WeatherRepository', () {
    late accu_weather_api.AccuWeatherApiClient accuWeatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      accuWeatherApiClient = MockAccuWeatherApiClient();
      weatherRepository = WeatherRepository(
        weatherApiClient: accuWeatherApiClient,
      );
    });

    group('constructor', () {
      test('instantiates internal MetaWeatherApiClient when not injected', () {
        expect(WeatherRepository(), isNotNull);
      });
    });

    group('getWeather', () {
      const city = 'london';
      const woeid = 44418;

      test('calls locationSearch with correct city', () async {
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => accuWeatherApiClient.locationSearch(city)).called(1);
      });

      test('throws when locationSearch fails', () async {
        final exception = Exception('oops');
        when(() => accuWeatherApiClient.locationSearch(any()))
            .thenThrow(exception);
        expect(
          () async => await weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('calls getWeather with correct woeid', () async {
        final location = MockLocation();
        when(() => location.woeid).thenReturn(woeid);
        when(() => accuWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => accuWeatherApiClient.getWeather(woeid)).called(1);
      });

      test('throws when getWeather fails', () async {
        final exception = Exception('oops');
        final location = MockLocation();
        when(() => location.woeid).thenReturn(woeid);
        when(() => accuWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(() => accuWeatherApiClient.getWeather(any())).thenThrow(exception);
        expect(
          () async => await weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('returns correct weather on success (showers)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.woeid).thenReturn(woeid);
        when(() => location.title).thenReturn('London');
        when(() => weather.weatherStateAbbr).thenReturn(
          accu_weather_api.WeatherState.showers,
        );
        when(() => weather.theTemp).thenReturn(42.42);
        when(() => accuWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(() => accuWeatherApiClient.getWeather(any())).thenAnswer(
          (_) async => weather,
        );
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          Weather(
            temperature: 42.42,
            location: 'London',
            condition: WeatherCondition.rainy,
          ),
        );
      });

      test('returns correct weather on success (heavy cloud)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.woeid).thenReturn(woeid);
        when(() => location.title).thenReturn('London');
        when(() => weather.weatherStateAbbr).thenReturn(
          accu_weather_api.WeatherState.heavyCloud,
        );
        when(() => weather.theTemp).thenReturn(42.42);
        when(() => accuWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(() => accuWeatherApiClient.getWeather(any())).thenAnswer(
          (_) async => weather,
        );
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          Weather(
            temperature: 42.42,
            location: 'London',
            condition: WeatherCondition.cloudy,
          ),
        );
      });

      test('returns correct weather on success (light cloud)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.woeid).thenReturn(woeid);
        when(() => location.title).thenReturn('London');
        when(() => weather.weatherStateAbbr).thenReturn(
          accu_weather_api.WeatherState.lightCloud,
        );
        when(() => weather.theTemp).thenReturn(42.42);
        when(() => accuWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(() => accuWeatherApiClient.getWeather(any())).thenAnswer(
          (_) async => weather,
        );
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          Weather(
            temperature: 42.42,
            location: 'London',
            condition: WeatherCondition.cloudy,
          ),
        );
      });
    });
  });
}
