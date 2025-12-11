import 'package:myada_official/core/app_export.dart';
import 'package:myada_official/core/network/api_service.dart';

import '/widgets/app_bar/custom_app_bar.dart';
import 'provider/th2_provider.dart';

class ThInitialPage extends StatefulWidget {
  const ThInitialPage({Key? key}) : super(key: key);

  @override
  ThInitialPageState createState() => ThInitialPageState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Th2Provider(),
      child: const ThInitialPage(),
    );
  }
}

class ThInitialPageState extends State<ThInitialPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await _apiService.getUserData();

      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: AppDecoration.fillWhite,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: _buildAppBar(context),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text('Error: $error'))
                    : Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.only(
                          left: 18.h,
                          top: 18.h,
                          right: 18.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _buildCardSection(context),
                            _buildMoreOptions(context)
                          ],
                        ),
                      ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 80.h,
      leading: CustomImageView(
        imagePath: ImageConstant.imgPlay,
        height: 38.h,
        width: 60.h,
        margin: EdgeInsets.only(left: 20.h),
      ),
      actions: [
        InkWell(
          onTap: () {
            // Navigate to settings
          },
          child: CustomImageView(
            imagePath: ImageConstant.imgSettingsPrimary,
            height: 24.h,
            width: 24.h,
            margin: EdgeInsets.only(right: 15.h),
          ),
        ),
        Container(
          height: 27.h,
          width: 26.h,
          margin: EdgeInsets.only(
            right: 20.h,
          ),
          child: Stack(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgLock,
                height: 24.h,
                width: 26.h,
                margin: EdgeInsets.only(
                  top: 3.h,
                  right: 2.h,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 12.h,
                  height: 10.h,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    left: 16.h,
                    bottom: 17.h,
                  ),
                  decoration: AppDecoration.fillPink.copyWith(
                    borderRadius: BorderRadiusStyle.circleBorder5,
                  ),
                  child: Text(
                    "1",
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.robotoOnPrimary,
                  ),
                ),
              )
            ],
          ),
        ),
        // Add sign out button
        InkWell(
          onTap: () async {
            try {
              // Sign out using API service
              await _apiService.logout();
              // Navigate to login screen
              NavigatorService.pushReplacementNamed(AppRoutes.loginScreen);
            } catch (e) {
              // Fallback if logout fails
              NavigatorService.pushReplacementNamed(AppRoutes.loginScreen);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.h),
            margin: EdgeInsets.only(right: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFA54D66),
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: Text(
              "Sign Out",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.h,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildCardSection(BuildContext context) {
    return SizedBox(
      width: 352.h,
      height: 213.h,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: EdgeInsets.only(top: 135.h - 115.h), // Adjusted position
        color: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.pink[700] ?? Colors.pink,
            width: 0.5.h,
          ),
          borderRadius: BorderRadiusStyle.roundedBorder10,
        ),
        child: Container(
          width: 352.h,
          height: 213.h,
          padding: EdgeInsets.symmetric(horizontal: 2.h),
          decoration: AppDecoration.fillWhite.copyWith(
            borderRadius: BorderRadiusStyle.roundedBorder10,
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                width: double.maxFinite,
                margin: EdgeInsets.only(left: 34.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 10.h,
                  vertical: 6.h,
                ),
                decoration: AppDecoration.fillWhite,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: double.maxFinite,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              "ADA UNIVERSITY",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          CustomImageView(
                            imagePath: ImageConstant.imgPlay,
                            height: 24.h,
                            width: 38.h,
                            margin: EdgeInsets.only(left: 6.h),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Name: ",
                            style: theme.textTheme.titleSmall,
                          ),
                          TextSpan(
                            text: userData?['firstName'] ?? '',
                            style: theme.textTheme.bodyMedium,
                          )
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 2.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 70.h),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Surname: ",
                                style: theme.textTheme.titleSmall,
                              ),
                              TextSpan(
                                text: userData?['lastName'] ?? '',
                                style: theme.textTheme.bodyMedium,
                              )
                            ],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Status: ",
                            style: theme.textTheme.titleSmall,
                          ),
                          TextSpan(
                            text: userData?['status'] ?? 'Student',
                            style: theme.textTheme.bodyMedium,
                          )
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 2.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 90.h),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Class: ",
                                style: theme.textTheme.titleSmall,
                              ),
                              TextSpan(
                                text: userData?['className'] ?? '',
                                style: theme.textTheme.bodyMedium,
                              )
                            ],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Date of Issue: ",
                            style: CustomTextStyles.sFProPink700SemiBold,
                          ),
                          TextSpan(
                            text: userData?['issueDate'] ?? '',
                            style: CustomTextStyles.sFProPink700Regular,
                          )
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 2.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Validity Date: ",
                            style: CustomTextStyles.sFProPink700SemiBold,
                          ),
                          TextSpan(
                            text: userData?['validityDate'] ?? '',
                            style: CustomTextStyles.sFProPink700Regular,
                          )
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                    // Add HCE button (wifi-like) to the right side
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.h),
                        child: CustomImageView(
                          imagePath: ImageConstant.imgGroup,
                          height: 20.h,
                          width: 20.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "ID: ",
                              style: theme.textTheme.titleSmall,
                            ),
                            TextSpan(
                              text: userData?['id'] ?? '',
                              style: theme.textTheme.bodyMedium,
                            )
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ),
              ),
              CustomImageView(
                imagePath: ImageConstant.imgRectangle156,
                height: 150.h,
                width: 112.h,
                radius: BorderRadius.circular(
                  12.h,
                ),
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 12.h),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildMoreOptions(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(top: 30.h, right: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "More",
            style: CustomTextStyles.titleMediumSFProBlack900,
          ),
          Container(
            height: 1.h,
            width: 40.h,
            decoration: BoxDecoration(
              color: Colors.pink[700] ?? Colors.pink,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Attendance check
              _buildFeatureItem(
                context: context,
                imagePath: ImageConstant.imgAssign12691866,
                title: "attendance check",
                onTap: () {},
              ),
              SizedBox(width: 16.h),
              // Room reservation
              _buildFeatureItem(
                context: context,
                imagePath: ImageConstant.imgBookingOnline10992406,
                title: "room reservation",
                onTap: () {},
              ),
              SizedBox(width: 16.h),
              // Add button
              _buildFeatureItem(
                context: context,
                isAddButton: true,
                onTap: () {},
              ),
            ],
          )
        ],
      ),
    );
  }

  // Build feature item widget
  Widget _buildFeatureItem({
    required BuildContext context,
    String? imagePath,
    String? title,
    required VoidCallback onTap,
    bool isAddButton = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100.h,
        height: 100.h,
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.h),
          border: Border.all(
            color: const Color(0xFFA54D66),
            width: 0.5.h,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isAddButton) ...[
              CustomImageView(
                imagePath: imagePath,
                height: 44.h,
                width: 44.h,
                color: const Color(0xFFA54D66),
              ),
              SizedBox(height: 8.h),
              Text(
                title ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.h,
                  color: const Color(0xFF3A6381),
                ),
              ),
            ] else ...[
              Container(
                height: 40.h,
                width: 40.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFA54D66),
                    width: 1.h,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: const Color(0xFFA54D66),
                  size: 24.h,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Add this class to provide a user model without requiring external service
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String className;
  final String status;
  final String issueDate;
  final String validityDate;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.className,
    required this.status,
    required this.issueDate,
    required this.validityDate,
  });
}
