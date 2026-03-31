import 'dart:io';

import 'package:care_life_touch/app/global_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../global_widgets/primary_appbar.dart';
import '../controllers/write_review_controller.dart';

class WriteReviewView extends GetView<WriteReviewController> {
  const WriteReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'Review',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductCard(),
            const SizedBox(height: 20),
            _buildRatingPicker(),
            const SizedBox(height: 20),
            _buildUploadBlock(),
            const SizedBox(height: 20),
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF01060F),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.titleController,
              maxLength: 80,
              decoration: InputDecoration(
                hintText: 'Leave review title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE8EAE8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE8EAE8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF064E36)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller.commentController,
              minLines: 5,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Leave your comment here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE8EAE8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE8EAE8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF064E36)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Obx(
          () => CustomButton(
            text: controller.isSubmitting.value ? 'Submitting...' : 'Confirm',
            onPressed: controller.isSubmitting.value ? null : controller.submit,
            size: ButtonSize.medium,
            fullWidth: true,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8EAE8)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _ProductImage(path: controller.imageUrl.value),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.brandName.value.isNotEmpty)
                    Text(
                      controller.brandName.value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xB301060F),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    controller.productName.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF191930),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (controller.priceText.value.isNotEmpty)
                        Text(
                          controller.priceText.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF064E36),
                          ),
                        ),
                      if (controller.oldPriceText.value.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          controller.oldPriceText.value,
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFFA2A8AF),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (controller.quantityText.value.isNotEmpty)
                        Text(
                          controller.quantityText.value,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xB301060F),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingPicker() {
    return Obx(
      () => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              final active = star <= controller.rating.value;
              return IconButton(
                onPressed: () => controller.setRating(star),
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  active ? Icons.star : Icons.star_border,
                  size: 30,
                  color: active ? const Color(0xFFEAB308) : const Color(0xFFEFEFEF),
                ),
              );
            }),
          ),
          Text(
            '${controller.rating.value}/5',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF01060F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload image/videos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF01060F),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: controller.pickImages,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE8EAE8), width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/upload_image.svg',
                  width: 50,
                  height: 36,
                  colorFilter: const ColorFilter.mode(
                    Color(0xB301060F),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => Text(
                    controller.isPickingImages.value
                        ? 'Opening gallery...'
                        : 'Browse Files to upload',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF01060F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => controller.selectedImages.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.selectedImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, index) {
                      final image = controller.selectedImages[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              image,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: IconButton(
                              onPressed: () => controller.removeImageAt(index),
                              icon: const Icon(Icons.cancel, color: Colors.black87),
                              iconSize: 20,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.trim().isEmpty) {
      return _fallback();
    }

    final isRemote = path.startsWith('http://') || path.startsWith('https://');
    if (isRemote) {
      return Image.network(
        path,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, width: 80, height: 80, fit: BoxFit.cover);
    }

    return Image.asset(
      path,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFFAFAFA),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Color(0xFFA2A8AF)),
    );
  }
}

