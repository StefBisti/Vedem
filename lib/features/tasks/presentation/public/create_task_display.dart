import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/pages/day_page.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';

class CreateTaskDisplay extends StatefulWidget {
  final String dayId;

  const CreateTaskDisplay({super.key, required this.dayId});

  @override
  State<CreateTaskDisplay> createState() => _CreateTaskDisplayState();
}

class _CreateTaskDisplayState extends State<CreateTaskDisplay> {
  late TextEditingController categoryController;
  late TextEditingController contentController;
  late TextEditingController diamondsController;

  bool isRecurring = false;

  @override
  void initState() {
    super.initState();
    categoryController = TextEditingController();
    contentController = TextEditingController();
    diamondsController = TextEditingController();
  }

  @override
  void dispose() {
    categoryController.dispose();
    contentController.dispose();
    diamondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          TextField(
            style: AppTextStyles.content,
            maxLines: 1,
            minLines: 1,
            controller: categoryController,
            decoration: InputDecoration(
              labelText: 'Category Id',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            style: AppTextStyles.content,
            maxLines: null,
            minLines: 1,
            controller: contentController,
            decoration: InputDecoration(
              labelText: 'Content',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            style: AppTextStyles.content,
            maxLines: null,
            minLines: 1,
            controller: diamondsController,
            decoration: InputDecoration(
              labelText: 'Diamonds',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            value: isRecurring,
            onChanged: (v) => setState(() {
              isRecurring = v;
            }),
            title: Text('Is recurring', style: AppTextStyles.content),
          ),

          TextButton.icon(
            onPressed: () {
              context.read<TasksBloc>().add(
                CreateNewTaskEvent(
                  dayId: widget.dayId,
                  categoryId: int.parse(categoryController.text.trim()),
                  content: contentController.text,
                  isRecurring: isRecurring,
                  diamonds: int.parse(diamondsController.text.trim()),
                ),
              );
              DayPage.route(context, widget.dayId);
            },
            label: Text(
              'Create',
              style: AppTextStyles.content.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLightTextColor,
              ),
            ),
            icon: Icon(
              Icons.add_rounded,
              color: AppColors.primaryLightTextColor,
              size: 20.0,
            ),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(
                  AppStyle.roundedCorners,
                ),
              ),
              backgroundColor: AppColors.darkBackgroundColor,
            ),
          ),

          SizedBox(height: 60.0),
        ],
      ),
    );
  }
}
