import 'package:myada_official/core/app_export.dart';

class CustomTabBar extends StatefulWidget {
  final Function(int) onTabChanged;
  final int initialTabIndex;

  const CustomTabBar({
    Key? key,
    required this.onTabChanged,
    this.initialTabIndex = 0,
  }) : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start with full animation
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      _animationController.forward(from: 0.0);
      widget.onTabChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 3;

    return Container(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Simple blue background bar without cutout
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 55,
              color: const Color(0xFF3A6381),
            ),
          ),

          // Tab items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTabItem(
                      0, ImageConstant.imgTabHomeDefault, 'Home', itemWidth),
                  _buildTabItem(1, ImageConstant.imgTabSearchDefault, 'Search',
                      itemWidth),
                  _buildTabItem(2, ImageConstant.imgTabProfileDefault,
                      'Account', itemWidth),
                ],
              ),
            ),
          ),

          // Selected circle
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            bottom: 30,
            left: _selectedIndex * itemWidth + (itemWidth - 60) / 2,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFA54D66),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(14),
              child: _buildSelectedIcon(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String icon, String label, double width) {
    final isCurrentTab = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: isCurrentTab ? 0.0 : 1.0,
              child: Container(
                height: 24,
                width: 24,
                child: Image.asset(
                  icon,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      index == 0
                          ? Icons.home
                          : index == 1
                              ? Icons.search
                              : Icons.person,
                      size: 24,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isCurrentTab ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedIcon() {
    String iconPath;

    switch (_selectedIndex) {
      case 0:
        iconPath = ImageConstant.imgTabHomeSelected;
        break;
      case 1:
        iconPath = ImageConstant.imgTabSearchSelected;
        break;
      case 2:
        iconPath = ImageConstant.imgTabProfileSelected;
        break;
      default:
        iconPath = ImageConstant.imgTabHomeSelected;
    }

    return Image.asset(
      iconPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          _selectedIndex == 0
              ? Icons.home
              : _selectedIndex == 1
                  ? Icons.search
                  : Icons.person,
          size: 24,
          color: Colors.white,
        );
      },
    );
  }
}
