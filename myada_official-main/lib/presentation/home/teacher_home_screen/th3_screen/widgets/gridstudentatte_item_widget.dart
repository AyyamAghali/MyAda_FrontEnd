import 'package:myada_official/core/app_export.dart';

import '../models/gridstudentatte_item_model.dart';

// ignore_for_file: must_be_immutable
class GridstudentatteItemWidget extends StatelessWidget {
  GridstudentatteItemWidget(this.gridstudentatteItemModelObj,
      {Key? key, this.onTapColumnstudentat})
      : super(
          key: key,
        );

  GridstudentatteItemModel gridstudentatteItemModelObj;

  VoidCallback? onTapColumnstudentat;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapColumnstudentat?.call();
      },
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: AppDecoration.card2.copyWith(
          borderRadius: BorderRadiusStyle.roundedBorder14,
        ),
        child: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 4.h),
            CustomImageView(
              imagePath: gridstudentatteItemModelObj.image!,
              height: 44.h,
              width: 46.h,
            ),
            Text(
              gridstudentatteItemModelObj.studentattendan!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium!.copyWith(
                height: 1.10,
              ),
            )
          ],
        ),
      ),
    );
  }
}
