import 'package:myada_official/core/app_export.dart';

import '../models/listattendancec_item_model.dart';

// ignore_for_file: must_be_immutable
class ListattendancecItemWidget extends StatelessWidget {
  ListattendancecItemWidget(this.listattendancecItemModelObj, {Key? key})
      : super(
          key: key,
        );

  ListattendancecItemModel listattendancecItemModelObj;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.h,
      padding: EdgeInsets.symmetric(
        horizontal: 20.h,
        vertical: 8.h,
      ),
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
            imagePath: listattendancecItemModelObj.attendancecheck!,
            height: 44.h,
            width: 46.h,
          ),
          Text(
            listattendancecItemModelObj.attendancecheck1!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium!.copyWith(
              height: 1.10,
            ),
          )
        ],
      ),
    );
  }
}
