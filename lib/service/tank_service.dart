import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/models/tank_model.dart';

class FuelTankService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new fuel tank to the "FuelTanks" collection
  Future<void> addFuelTank(FuelTank tank) async {
    try {
      await _firestore.collection('FuelTanks').doc(tank.id).set(tank.toJson());
      print("Tank added successfully.");
    } catch (e) {
      print('Error adding tank: $e');
    }
  }

  // Fetch all fuel tanks from Firestore once
  Future<List<FuelTank>> getAllFuelTanks() async {
    try {
      var snapshot = await _firestore.collection('FuelTanks').get();
      return snapshot.docs.map((doc) {
        return FuelTank.fromJson(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching tanks: $e');
      return [];
    }
  }

  // Fetch all fuel tanks from Firestore with real-time updates
  Stream<List<FuelTank>> getFuelTanksStream() {
    return _firestore.collection('FuelTanks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FuelTank.fromJson(doc.data()!, doc.id);
      }).toList();
    });
  }

  // Fetch a single tank by its ID
  Future<FuelTank?> getFuelTankById(String id) async {
    try {
      var docSnapshot = await _firestore.collection('FuelTanks').doc(id).get();
      if (docSnapshot.exists) {
        return FuelTank.fromJson(docSnapshot.data()!, id);
      }
    } catch (e) {
      print('Error fetching tank: $e');
    }
    return null;
  }

  // Update the fuel level directly for a tank
  Future<void> updateFuelLevel(String tankId, double newLevel) async {
    try {
      var tankDoc = await _firestore.collection('FuelTanks').doc(tankId).get();
      if (tankDoc.exists) {
        await _firestore.collection('FuelTanks').doc(tankId).update({
          'currentLevel': newLevel,
        });
        print("Fuel level updated to: $newLevel liters.");
      }
    } catch (e) {
      print('Error updating fuel level: $e');
    }
  }

  // // Add a record for fuel stock in the tank's fuelStock subcollection
  // Future<void> addFuelStockRecord(String tankId, double addedQuantity) async {
  //   try {
  //     // Get the current tank document
  //     var tankDoc = await _firestore.collection('FuelTanks').doc(tankId).get();

  //     if (tankDoc.exists) {
  //       // Get the current fuel level from the tank
  //       double currentLevel = tankDoc['currentLevel'];
  //       double newLevel = currentLevel + addedQuantity;

  //       // Update the tank's current level
  //       await _firestore.collection('FuelTanks').doc(tankId).update({
  //         'currentLevel': newLevel,
  //       });

  //       // Add the fuel stock record to the tank's fuelStock subcollection
  //       await _firestore
  //           .collection('FuelTanks')
  //           .doc(tankId)
  //           .collection('fuelStock')
  //           .add({
  //             'addedQuantity': addedQuantity,
  //             'date': FieldValue.serverTimestamp(),
  //           });

  //       // Also, add the fuel stock record to the global FuelStockHistory collection
  //       await _firestore.collection('FuelStockHistory').add({
  //         'tankId': tankId,
  //         'addedQuantity': addedQuantity,
  //         'date': FieldValue.serverTimestamp(),
  //       });

  //       print("Fuel stock record added to both tank and FuelStockHistory.");
  //     }
  //   } catch (e) {
  //     print('Error adding fuel stock record: $e');
  //   }
  // }

  // Add a record for fuel stock in the tank's fuelStock subcollection
  Future<void> addFuelStockRecord(String tankId, double addedQuantity) async {
    try {
      // Get the current tank document
      var tankDoc = await _firestore.collection('FuelTanks').doc(tankId).get();

      if (tankDoc.exists) {
        // Get the current fuel level from the tank
        double currentLevel = tankDoc['currentLevel'];
        double newLevel = currentLevel + addedQuantity;

        // Get the fuel type from the tank document
        String fuelType = tankDoc['fuelType'];

        // Update the tank's current level
        await _firestore.collection('FuelTanks').doc(tankId).update({
          'currentLevel': newLevel,
        });

        // Add the fuel stock record to the tank's fuelStock subcollection
        await _firestore
            .collection('FuelTanks')
            .doc(tankId)
            .collection('fuelStock')
            .add({
              'addedQuantity': addedQuantity,
              'date': FieldValue.serverTimestamp(),
            });

        // Add the fuel stock record to the global FuelStockHistory collection
        await _firestore.collection('FuelStockHistory').add({
          'tankId': tankId,
          'fuelType': fuelType, // Add the fuel type here
          'addedQuantity': addedQuantity,
          'date': FieldValue.serverTimestamp(),
        });

        print("Fuel stock record added to both tank and FuelStockHistory.");
      }
    } catch (e) {
      print('Error adding fuel stock record: $e');
    }
  }

  Future<void> addFuelSaleRecord(
    String tankId,
    double soldQuantity,
    String pumperName, // Only pass pumper name
  ) async {
    try {
      // Fetch the tank document
      var tankDoc = await _firestore.collection('FuelTanks').doc(tankId).get();

      if (tankDoc.exists) {
        double currentLevel = tankDoc['currentLevel'];
        double newLevel = currentLevel - soldQuantity;
        String fuelType =
            tankDoc['fuelType']; // Fetch the fuel type from the tank

        // Update the tank's current level after sale
        await _firestore.collection('FuelTanks').doc(tankId).update({
          'currentLevel': newLevel,
        });

        // Add the sale record to the tank's fuelSales subcollection
        await _firestore
            .collection('FuelTanks')
            .doc(tankId)
            .collection('fuelSales')
            .add({
              'soldQuantity': soldQuantity,
              'pumperName': pumperName,
              'date': FieldValue.serverTimestamp(),
            });

        // Also, add the sale record to the FuelSaleHistory main collection
        await _firestore.collection('FuelSaleHistory').add({
          'tankId': tankId,
          'fuelType': fuelType, // Add the fuel type here
          'soldQuantity': soldQuantity,
          'pumperName': pumperName,
          'date': FieldValue.serverTimestamp(),
        });

        print("Fuel sale record added to both tank and FuelSaleHistory.");
      }
    } catch (e) {
      print('Error adding fuel sale record: $e');
    }
  }
}
