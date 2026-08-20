import 'package:flutter/widgets.dart';
import '../models/order.dart';

/// Simple hand-written translations — no build_runner / codegen step,
/// so `flutter pub get` alone is enough to build. Add a new string by
/// adding one getter here and using it via AppStrings.of(context).
class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  bool get _ar => locale.languageCode == 'ar';

  // Login screen
  String get driverLoginTitle => _ar ? 'تسجيل دخول السائق' : 'Driver Login';
  String get phoneNumber => _ar ? 'رقم الهاتف' : 'Phone number';
  String get password => _ar ? 'كلمة المرور' : 'Password';
  String get pleaseEnterPhone => _ar ? 'من فضلك أدخل رقم الهاتف' : 'Please enter your phone number';
  String get pleaseEnterPassword => _ar ? 'من فضلك أدخل كلمة المرور' : 'Please enter your password';
  String get logIn => _ar ? 'تسجيل الدخول' : 'Log In';

  // Orders list screen
  String hiName(String name) => _ar ? 'أهلًا، $name' : 'Hi, $name';
  String get logOut => _ar ? 'تسجيل الخروج' : 'Log out';
  String get noOrdersYet => _ar ? 'لا توجد طلبات معينة لك حتى الآن.' : 'No orders assigned to you yet.';
  String get pullToRefresh => _ar ? 'اسحب للأسفل للتحديث.' : 'Pull down to refresh.';
  String get retry => _ar ? 'إعادة المحاولة' : 'Retry';

  // Order details screen
  String get orderDetails => _ar ? 'تفاصيل الطلب' : 'Order Details';
  String orderNumber(String id) => _ar ? 'طلب رقم #$id' : 'Order #$id';
  String get pickupAddress => _ar ? 'عنوان الاستلام' : 'Pickup Address';
  String get deliveryAddress => _ar ? 'عنوان التوصيل' : 'Delivery Address';
  String get openInMaps => _ar ? 'فتح في الخرائط' : 'Open in Maps';
  String noCoordinatesFor(String label) =>
      _ar ? 'لا توجد إحداثيات محفوظة لـ "$label".' : 'No coordinates saved for "$label".';
  String get timeline => _ar ? 'المراحل' : 'Timeline';
  String get noFurtherAction => _ar ? 'لا يوجد إجراء آخر مطلوب لهذا الطلب.' : 'No further action needed for this order.';
  String orderUpdatedTo(String status) => _ar ? 'تم تحديث الطلب إلى "$status"' : 'Order updated to "$status"';
  String get markPickedUp => _ar ? 'تحديد كـ تم الاستلام' : 'Mark as Picked Up';
  String get markOutForDelivery => _ar ? 'تحديد كـ في الطريق للتوصيل' : 'Mark as Out for Delivery';
  String get markDelivered => _ar ? 'تحديد كـ تم التوصيل' : 'Mark as Delivered';
  String get updateStatus => _ar ? 'تحديث الحالة' : 'Update Status';

  // Status labels (shared with badges/timeline)
  String statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
        return _ar ? 'تم الإنشاء' : 'Created';
      case OrderStatus.assigned:
        return _ar ? 'تم التعيين' : 'Assigned';
      case OrderStatus.pickedUp:
        return _ar ? 'تم الاستلام' : 'Picked Up';
      case OrderStatus.outForDelivery:
        return _ar ? 'في الطريق للتوصيل' : 'Out for Delivery';
      case OrderStatus.delivered:
        return _ar ? 'تم التوصيل' : 'Delivered';
      case OrderStatus.unknown:
        return _ar ? 'غير معروف' : 'Unknown';
    }
  }

  // Address labels
  String get pickup => _ar ? 'الاستلام' : 'Pickup';
  String get deliverTo => _ar ? 'التوصيل إلى' : 'Deliver to';

  // Language toggle
  String get switchLanguage => _ar ? 'English' : 'العربية';
}
