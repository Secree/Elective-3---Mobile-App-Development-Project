import 'package:shared_preferences/shared_preferences.dart';

class PromoResult {
  final double finalPrice;
  final bool isBogo;
  final double discountPercent;

  PromoResult(this.finalPrice, this.isBogo, this.discountPercent);
}

class PromoService {
  static final PromoService instance = PromoService._init();
  PromoService._init();

  static const String _keyActivePromo = 'active_promo';
  static const String _keyPromoExpiry = 'promo_expiry';

  // Promo types
  static const String promo20Off = 'NOV20FLY';
  static const String promoBogo = 'BOGO';

  /// Save active promo with expiry (24 hours)
  Future<void> activatePromo(String promoCode) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch;
    
    await prefs.setString(_keyActivePromo, promoCode);
    await prefs.setInt(_keyPromoExpiry, expiryTime);
  }

  /// Get active promo if not expired
  Future<String?> getActivePromo() async {
    final prefs = await SharedPreferences.getInstance();
    final promoCode = prefs.getString(_keyActivePromo);
    final expiryTime = prefs.getInt(_keyPromoExpiry);
    
    if (promoCode == null || expiryTime == null) {
      return null;
    }
    
    // Check if expired
    if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
      await clearPromo();
      return null;
    }
    
    return promoCode;
  }

  /// Clear active promo
  Future<void> clearPromo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActivePromo);
    await prefs.remove(_keyPromoExpiry);
  }

  /// Calculate discount based on promo code
  /// Returns PromoResult with discountedPrice, isBogo, and discountPercent
  PromoResult applyPromo(String? promoCode, double basePrice, int numberOfSeats) {
    if (promoCode == null) {
      return PromoResult(basePrice * numberOfSeats, false, 0.0);
    }

    switch (promoCode) {
      case promo20Off:
        // 20% off on base fare
        final discountedPrice = basePrice * 0.8;
        return PromoResult(discountedPrice * numberOfSeats, false, 20.0);
        
      case promoBogo:
        // Buy 1 Get 1: Pay for half, get double seats
        // But user still needs to select the seats they want
        final priceToPay = basePrice * numberOfSeats; // But only pay for original count
        return PromoResult(priceToPay, true, 50.0); // 50% discount effectively
        
      default:
        return PromoResult(basePrice * numberOfSeats, false, 0.0);
    }
  }

  /// Check if promo code is valid
  bool isValidPromo(String promoCode) {
    return promoCode == promo20Off || promoCode == promoBogo;
  }

  /// Get promo description
  String getPromoDescription(String promoCode) {
    switch (promoCode) {
      case promo20Off:
        return '20% Off November Promo';
      case promoBogo:
        return 'Buy 1 Get 1 Seat Sale';
      default:
        return 'Unknown Promo';
    }
  }
}
