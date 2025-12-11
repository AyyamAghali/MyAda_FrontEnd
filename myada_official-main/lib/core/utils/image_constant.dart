// ignore_for_file: must_be_immutable
/// Class containing constants for image paths
class ImageConstant {
  /// Image paths prefix
  static const String _imagePath = 'assets/';
  static const String _iconPath = 'assets/icons/';

  /// App logo
  static const String imgLogo1 = '${_imagePath}images/logo 1.png';

  /// Onboarding images
  static const String imgSmartcards =
      '${_imagePath}images/Smartcards for schools.png';
  static const String imgFrame = 'assets/Frame.png';
  static const String imgFrame2 = 'assets/Frame2.png';
  static const String imgBackground =
      '${_imagePath}images/Background Simple.png';

  /// Feature images
  static const String imgAttendance = 'assets/booking-online_10992406 1.png';
  static const String imgAssign = 'assets/assign_12691866 1.png';
  static const String imgTalk = 'assets/talk_16097781 1.png';
  static const String imgGroup = 'assets/Group 2.png'; // HCE / Wifi-like button
  static const String imgTabBar = '${_imagePath}images/tab bar.png';

  /// Icon images
  static const String imgHome = '${_iconPath}home.png';
  static const String imgCalendar = '${_iconPath}calendar.png';
  static const String imgClassroom = '${_iconPath}classroom.png';
  static const String imgProfile = '${_iconPath}profile.png';
  static const String imgSettings = '${_imagePath}images/settings.png';
  static const String imgMenu = '${_iconPath}menu.png';
  static const String imgUser = '${_iconPath}user.png';
  static const String imgPlus = '${_iconPath}plus.png';
  static const String imgArrowRight = '${_iconPath}arrow_right.png';
  static const String imgArrowLeft = '${_iconPath}arrow_left.png';
  static const String imgSearch = '${_iconPath}search.png';
  static const String imgCheck = '${_iconPath}check.png';
  static const String imgClose = '${_iconPath}close.png';

  // Bottom navigation icons
  static const String imgNavHome = '${_iconPath}nav_home.png';
  static const String imgNavSearch = '${_iconPath}nav_search.png';
  static const String imgNavAccount = '${_iconPath}nav_account.png';

  // For compatibility with existing code
  static const String imgArrowsChevron = '${_iconPath}arrow_left.png';
  static const String imgAssign12691866 = imgAssign;
  static const String imgBookingOnline10992406 = imgAttendance;
  static const String imgTalk160977811 = imgTalk;
  static const String imgEllipse61 = imgLogo1;

  // New references for compatibility
  static const String imgPlay = imgLogo1;
  static const String imgSettingsPrimary = imgSettings;
  static const String imgLock = '${_iconPath}lock.png';
  static const String imgRectangle156 = imgLogo1; // Student photo
  static const String imgRectangle403 = imgLogo1;

  /// User images
  static const String imgStudentPhoto = 'assets/Rectangle 157.png';
  static const String imgTeacherPhoto = 'assets/Rectangle 158.png';

  /// Tab Bar Images
  static const String imgTabBar1 = 'lib/assets/Tab1.png';
  static const String imgTabBar2 = 'lib/assets/Tab2.png';
  static const String imgTabBar3 = 'lib/assets/Tab3.png';

  /// Tab Bar Icons
  static const String imgTabHomeDefault = 'lib/assets/tabhome.png';
  static const String imgTabHomeSelected = 'lib/assets/Home icon.png';
  static const String imgTabSearchDefault = 'lib/assets/tabSearch.png';
  static const String imgTabSearchSelected = 'lib/assets/SearchIcon.png';
  static const String imgTabProfileDefault = 'lib/assets/profile.png';
  static const String imgTabProfileSelected = 'lib/assets/account icon.png';

  static String imageNotFound = imgLogo1;
}
