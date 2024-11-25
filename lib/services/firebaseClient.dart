import 'dart:convert';
import 'dart:math';
import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:diet_management_suppport_app/models/meal.dart';
import 'package:diet_management_suppport_app/models/userLimits.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Firebaseclient {
  Firebaseclient();
  final signUpUrl =
      Uri.https('dieteveryvalue-default-rtdb.firebaseio.com', 'Users.json');
  final signInUrl =
      Uri.https('dieteveryvalue-default-rtdb.firebaseio.com', 'Users.json');
  final favouriteListUrl = Uri.https(
      'dieteveryvalue-default-rtdb.firebaseio.com', 'FavouriteList.json');
  final dateFoodItemUrl = Uri.https(
      'dieteveryvalue-default-rtdb.firebaseio.com', 'FavouriteList.json');
  Future<bool> userExists(
      {required String email, required String password}) async {
    final Map<String, dynamic> signInResponse;
    final resposne = await http
        .get(signInUrl, headers: {'Content-Type': 'application/json'});
    if (nullChecker(json.decode(resposne.body))) {
      return false;
    } else {
      signInResponse = json.decode(resposne.body);
      for (var key in signInResponse.keys) {
        var val = signInResponse[key];

        if (val['email'] == email && val['password'] == password) {
          print("Istnieje użytkownik");

          userId = key;
          return true;
        }
      }
    }

    return false;
  }

  bool nullChecker(dynamic response) {
    if (response == null) {
      return true;
    }
    return false;
  }

  void signUpUser({required String email, required String password}) async {
    if (await userExists(email: email, password: password)) {
      print("nie zarejestrowany bo istnieje");
    } else {
      final response = http.post(
        signUpUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
    }
  }

  Future<void> addFavouriteList({
    required String userId,
    required List<FoodItem> favouriteList,
  }) async {
    // Tworzymy URL uwzględniając userId
    final Uri favouriteListUrl = Uri.https(
        'dieteveryvalue-default-rtdb.firebaseio.com',
        'favouriteList/$userId.json');

    // Konwertujemy listę FoodItem do formatu JSON
    final List<Map<String, dynamic>> favouriteListMap =
        favouriteList.map((item) => item.toMap()).toList();

    try {
      // Wysyłamy dane do Firebase
      final response = await http.put(
        favouriteListUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(favouriteListMap),
      );

      if (response.statusCode == 200) {
        print("Lista ulubionych zapisano pomyślnie dla użytkownika $userId.");
      } else {
        print(
            "Błąd przy zapisywaniu listy ulubionych dla użytkownika $userId: ${response.body}");
      }
    } catch (e) {
      print("Wystąpił błąd podczas zapisywania dla użytkownika $userId: $e");
    }
  }

  Future<void> removeFavouriteItem({
    required String userId,
    required String foodName, // nazwa jedzenia, które chcemy usunąć
  }) async {
    // Tworzymy URL dla użytkownika i jego listy ulubionych
    final Uri favouriteListUrl = Uri.https(
        'dieteveryvalue-default-rtdb.firebaseio.com',
        'favouriteList/$userId.json');

    try {
      // Pobieramy bieżącą listę ulubionych
      final response = await http.get(favouriteListUrl);

      if (response.statusCode == 200) {
        // Jeśli lista istnieje, dekodujemy ją
        List<dynamic> favouriteList = json.decode(response.body);

        // Szukamy elementu do usunięcia na podstawie nazwy
        favouriteList.removeWhere((item) => item['name'] == foodName);

        // Zapisujemy zmodyfikowaną listę z powrotem do Firebase
        final updatedList = favouriteList.isEmpty ? null : favouriteList;

        final updateResponse = await http.put(
          favouriteListUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedList),
        );

        if (updateResponse.statusCode == 200) {
          print("Element $foodName został usunięty z listy ulubionych.");
        } else {
          print("Błąd przy usuwaniu elementu: ${updateResponse.body}");
        }
      } else {
        print("Błąd przy pobieraniu listy ulubionych: ${response.body}");
      }
    } catch (e) {
      print("Wystąpił błąd: $e");
    }
  }

  Future<List<FoodItem>> getFavouriteList({
    required String userId,
  }) async {
    final Uri favouriteListUrl = Uri.https(
      'dieteveryvalue-default-rtdb.firebaseio.com',
      'favouriteList/$userId.json',
    );

    try {
      final response = await http.get(favouriteListUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Jeśli dane są `null`, zwróć pustą listę
        if (data == null) {
          return [];
        }

        // Mapowanie danych na listę obiektów FoodItem
        List<dynamic> favouriteListJson = data as List<dynamic>;
        return favouriteListJson.map((item) => FoodItem.fromMap(item)).toList();
      } else {
        throw Exception('Błąd przy pobieraniu danych: ${response.statusCode}');
      }
    } catch (e) {
      print("Wystąpił błąd podczas pobierania listy ulubionych: $e");
      return [];
    }
  }

  Future<void> addMeal({
    required String userId,
    required DateTime mealDate,
    required FoodItem foodItem,
  }) async {
    // Formatujemy datę, aby zawierała tylko rok, miesiąc i dzień
    final DateFormat dateFormat = DateFormat("yyyy-MM-dd"); // Usuwamy godzinę
    final String formattedDate = dateFormat.format(mealDate);

    // Formatowanie godziny posiłku na pełną godzinę
    final DateFormat hourFormat = DateFormat("HH:00"); // Tylko godzina
    final String formattedHour = hourFormat.format(mealDate);

    // Dodajemy 1 godzinę do zapisanej godziny
    final DateTime updatedMealDate = mealDate.add(Duration(hours: 1));
    final String updatedHour = hourFormat.format(updatedMealDate);

    // Przygotowujemy dane do zapisania
    final Map<String, dynamic> mealData = {
      'foodItems': foodItem.toMap(), // Zapisujemy item w postaci mapy
    };

    try {
      // Sprawdzamy, czy już istnieje lista posiłków dla tego użytkownika
      final userMealsUrl = Uri.https(
        'dieteveryvalue-default-rtdb.firebaseio.com',
        'Meals/$userId.json', // Każdy użytkownik ma swoją sekcję
      );

      final response = await http.get(userMealsUrl);

      if (response.statusCode == 200) {
        final existingMeals = json.decode(response.body);

        // Jeśli nie istnieje lista posiłków, tworzymy nową
        Map<String, dynamic> mealsMap = existingMeals == null
            ? {}
            : Map<String, dynamic>.from(existingMeals);

        // Sprawdzamy, czy posiłek o tej samej dacie już istnieje
        if (!mealsMap.containsKey(formattedDate)) {
          // Jeśli nie ma posiłku dla tej daty, tworzymy nowy wpis z listą godzin
          mealsMap[formattedDate] = {};
        }

        // Sprawdzamy, czy dla tej godziny już istnieje lista posiłków
        if (!mealsMap[formattedDate].containsKey(updatedHour)) {
          // Jeśli dla tej godziny nie ma jeszcze posiłków, tworzymy nową listę
          mealsMap[formattedDate][updatedHour] = [];
        }

        // Dodajemy nowy posiłek do listy foodItems danej godziny
        mealsMap[formattedDate][updatedHour].add(mealData['foodItems']);

        // Wysyłamy zaktualizowaną listę posiłków
        final updateResponse = await http.put(
          userMealsUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(mealsMap),
        );

        if (updateResponse.statusCode == 200) {
          print("Posiłek zapisany pomyślnie!");
        } else {
          print("Błąd przy zapisywaniu posiłku: ${updateResponse.body}");
        }
      } else {
        // Jeśli nie ma jeszcze posiłków, tworzymy nową listę
        final Map<String, dynamic> newMealsMap = {
          formattedDate: {
            updatedHour: [mealData['foodItems']]
          }
        };

        final createResponse = await http.put(
          userMealsUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newMealsMap),
        );

        if (createResponse.statusCode == 200) {
          print(
              "Posiłek zapisany pomyślnie jako pierwszy posiłek dla użytkownika!");
        } else {
          print("Błąd przy tworzeniu listy posiłków: ${createResponse.body}");
        }
      }
    } catch (e) {
      print("Wystąpił błąd przy zapisywaniu posiłku: $e");
    }
  }

  // Funkcja do pobierania danych o posiłkach
  Future<void> loadMealsForDate({
    required String userId,
    required DateTime date,
    required Function(List<Meal>) onMealsLoaded,
  }) async {
    final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    final String formattedDate = dateFormat.format(date);

    final Uri userMealsUrl = Uri.https(
      'dieteveryvalue-default-rtdb.firebaseio.com',
      'Meals/$userId.json',
    );

    try {
      final response = await http.get(userMealsUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Jeśli dane są null, to zwróć pustą listę
        if (data == null || !data.containsKey(formattedDate)) {
          onMealsLoaded([]);
          return;
        }

        final mealsForDay = data[formattedDate];
        List<Meal> meals = [];

        // Przechodzimy po każdej godzinie i mapujemy jedzenie
        mealsForDay.forEach((hour, foodItems) {
          List<FoodItem> foodList = [];
          for (var foodItem in foodItems) {
            foodList.add(FoodItem.fromMap(foodItem));
          }

          meals.add(Meal(
            name: hour,
            items: foodList,
          ));
        });

        // Wywołujemy callback z załadowanymi posiłkami
        onMealsLoaded(meals);
      } else {
        throw Exception(
            'Błąd przy pobieraniu posiłków: ${response.statusCode}');
      }
    } catch (e) {
      print("Wystąpił błąd: $e");
      onMealsLoaded([]);
    }
  }

  Future<void> removeFoodItem({
    required String userId,
    required DateTime mealDate, // Data posiłku
    required String mealTime, // Godzina posiłku w formacie "HH:00"
    required String foodName, // Nazwa jedzenia, które chcemy usunąć
  }) async {
    // Formatujemy datę
    final DateFormat dateFormat =
        DateFormat("yyyy-MM-dd"); // Data w formacie "yyyy-MM-dd"
    final String formattedDate = dateFormat.format(mealDate);

    // `mealTime` jest już podane w formacie "HH:00", więc nie musimy go formatować

    // Tworzymy URL do posiłków użytkownika
    final Uri userMealsUrl = Uri.https(
      'dieteveryvalue-default-rtdb.firebaseio.com',
      'Meals/$userId.json', // Każdy użytkownik ma swoją sekcję posiłków
    );

    try {
      // Pobieramy wszystkie posiłki użytkownika
      final response = await http.get(userMealsUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Jeśli dane są null lub nie ma posiłków dla tej daty, zakończ
        if (data == null || !data.containsKey(formattedDate)) {
          print("Brak posiłków dla tej daty.");
          return;
        }

        final mealsForDay = data[formattedDate];

        // Sprawdzamy, czy istnieje godzina, której szukamy
        if (mealsForDay.containsKey(mealTime)) {
          List<dynamic> foodItems = List.from(mealsForDay[mealTime]);

          // Usuwamy element, którego nazwa odpowiada foodName
          foodItems.removeWhere((foodItem) => foodItem['name'] == foodName);

          // Jeśli lista jest pusta, usuwamy cały wpis godziny
          if (foodItems.isEmpty) {
            mealsForDay.remove(mealTime);
          } else {
            mealsForDay[mealTime] = foodItems;
          }

          // Aktualizujemy dane w Firebase
          final updateResponse = await http.put(
            userMealsUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          );

          if (updateResponse.statusCode == 200) {
            print("FoodItem '$foodName' został usunięty.");
          } else {
            print("Błąd przy usuwaniu: ${updateResponse.body}");
          }
        } else {
          print("Nie znaleziono posiłków dla tej godziny.");
        }
      } else {
        print("Błąd przy pobieraniu danych: ${response.body}");
      }
    } catch (e) {
      print("Wystąpił błąd przy usuwaniu jedzenia: $e");
    }
  }

  Future<void> loadMealsForPeriod({
    required String userId,
    required String period, // 'day', 'week', 'month'
    required Function(List<Meal>) onMealsLoaded,
  }) async {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (period) {
      case 'day':
        startDate = now;
        break;
      case 'week':
        startDate = now.subtract(Duration(days: 6));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      default:
        throw ArgumentError('Invalid period: $period');
    }

    await loadMealsForRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      onMealsLoaded: onMealsLoaded,
    );
  }

  Future<void> loadMealsForRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required Function(List<Meal>) onMealsLoaded,
  }) async {
    List<Meal> allMeals = [];

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));

      await loadMealsForDate(
        userId: userId,
        date: currentDate,
        onMealsLoaded: (meals) {
          allMeals.addAll(meals);
        },
      );
    }

    onMealsLoaded(allMeals);
  }

  Future<void> updateGlassesAndSaveToDatabase({
    required String userId,
    required List<bool> glasses,
    required DateTime date,
  }) async {
    // Obliczamy łączną ilość litrów na podstawie liczby "true" w tablicy
    double totalLiters = glasses.where((glass) => glass).length * 0.25;

    // Tworzymy aktualny czas
    DateTime currentDate = date;
    String formattedDate = DateFormat('yyyy-MM-dd')
        .format(currentDate); // Zapisujemy tylko datę (YYYY-MM-DD)

    // Zapisujemy do bazy danych Firebase
    final Uri userGlassesUrl = Uri.https(
      'dieteveryvalue-default-rtdb.firebaseio.com',
      'UserGlasses/$userId/$formattedDate.json', // Klucz daty w ramach użytkownika
    );

    try {
      // Tworzymy dane do zapisania
      final Map<String, dynamic> glassesData = {
        'totalLiters': totalLiters, // Zapisujemy obliczoną wartość litrów
      };

      // Wysyłamy dane do Firebase
      final response = await http.put(
        userGlassesUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(glassesData),
      );

      if (response.statusCode == 200) {
        print("Wartość litrów zapisana pomyślnie!");
      } else {
        print("Błąd przy zapisywaniu wartości litrów: ${response.body}");
      }
    } catch (e) {
      print("Wystąpił błąd przy zapisywaniu wartości litrów: $e");
    }
  }

  Future<void> loadGlassesForDate({
    required String userId,
    required DateTime date,
    required Function(List<bool>) onGlassesLoaded,
  }) async {
    // Formatujemy datę na "yyyy-MM-dd"
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Tworzymy URL do pobierania danych z Firebase
    final Uri userGlassesUrl = Uri.https(
      'dieteveryvalue-default-rtdb.firebaseio.com',
      'UserGlasses/$userId/$formattedDate.json', // Pobieramy dane na podstawie daty
    );

    try {
      // Wysyłamy zapytanie do Firebase
      final response = await http.get(userGlassesUrl);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data != null && data['totalLiters'] != null) {
          // Obliczamy liczbę szklanek na podstawie litrów
          int totalGlasses = (data['totalLiters'] / 0.25).round();
          List<bool> glasses = List.generate(totalGlasses, (_) => true);

          // Wywołujemy callback z listą szklanek
          onGlassesLoaded(glasses);
        } else {
          // Jeżeli brak danych, przekazujemy pustą listę
          onGlassesLoaded([]);
        }
      } else {
        print("Błąd przy pobieraniu danych: ${response.statusCode}");
        onGlassesLoaded([]); // Brak danych w przypadku błędu
      }
    } catch (e) {
      print("Wystąpił błąd przy pobieraniu danych: $e");
      onGlassesLoaded([]); // Brak danych w przypadku błędu
    }
  }
}
