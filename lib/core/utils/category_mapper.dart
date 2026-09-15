/// Category Mapper Utility
/// Maps database categories to final consistent categories
class CategoryMapper {
  CategoryMapper._();

  // Final Categories
  static const String all = 'all';
  static const String sekolah = 'sekolah';
  static const String harian = 'harian';
  static const String seminar = 'seminar';
  static const String workshop = 'workshop';
  static const String kompetisi = 'kompetisi';
  static const String lainnya = 'lainnya';

  /// Map database category value to final category
  static String mapToFinalCategory(String dbCategory) {
    final category = dbCategory.toLowerCase().trim();

    // Kompetisi mapping
    if (category.contains('classmeet') ||
        category.contains('sport') ||
        category.contains('competition') ||
        category.contains('tournament') ||
        category.contains('science')) {
      return kompetisi;
    }

    // Seminar mapping
    if (category.contains('seminar')) {
      return seminar;
    }

    // Workshop mapping
    if (category.contains('workshop')) {
      return workshop;
    }

    // Sekolah mapping (school events)
    if (category.contains('career') ||
        category.contains('school') ||
        category.contains('sekolah')) {
      return sekolah;
    }

    // Harian mapping (daily/routine events)
    if (category.contains('harian') ||
        category.contains('daily') ||
        category.contains('routine')) {
      return harian;
    }

    // Default to lainnya
    return lainnya;
  }

  /// Get display name for final category
  static String getDisplayName(String category) {
    switch (category.toLowerCase()) {
      case all:
        return 'Semua';
      case sekolah:
        return 'Sekolah';
      case harian:
        return 'Harian';
      case seminar:
        return 'Seminar';
      case workshop:
        return 'Workshop';
      case kompetisi:
        return 'Kompetisi';
      case lainnya:
        return 'Lainnya';
      default:
        return 'Lainnya';
    }
  }

  /// Get all final categories
  static List<String> getAllCategories() {
    return [all, sekolah, harian, seminar, workshop, kompetisi, lainnya];
  }

  /// Check if event matches category filter
  static bool matchesCategory(String eventCategory, String filterCategory) {
    if (filterCategory == all) return true;

    final mappedCategory = mapToFinalCategory(eventCategory);
    return mappedCategory == filterCategory.toLowerCase();
  }
}
