import 'package:breast_milk/domain/models/food_tag.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/features/intake/application/intake_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manage common food tags (delete) from settings.
class FoodTagsSettingsPage extends ConsumerWidget {
  const FoodTagsSettingsPage({super.key});

  static const routeName = 'food-tags-settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(intakeFoodTagsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('常用食物')),
      body: tags.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('加载失败'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(intakeFoodTagsProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('还没有常用食物'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tag = items[index];
              return ListTile(
                title: Text(tag.name),
                subtitle: tag.useCount > 0
                    ? Text('已使用 ${tag.useCount} 次')
                    : const Text('尚未使用'),
                trailing: IconButton(
                  tooltip: '删除',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteTag(context, ref, tag),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteTag(
    BuildContext context,
    WidgetRef ref,
    FoodTag tag,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除常用食物'),
        content: Text(
          '确定删除「${tag.name}」？\n删除后入库页常用列表不再显示；已关联的历史记录仍会保留该标签。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(intakeServiceProvider).deleteFoodTag(tag.id);
      ref.invalidate(intakeFoodTagsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已删除「${tag.name}」')),
      );
    } on MilkRepositoryFailure catch (error) {
      if (!context.mounted) return;
      final message = error.code == 'food_tag_not_found'
          ? '该食物已不存在'
          : '删除失败，请稍后重试';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      ref.invalidate(intakeFoodTagsProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除失败，请稍后重试')),
      );
    }
  }
}
