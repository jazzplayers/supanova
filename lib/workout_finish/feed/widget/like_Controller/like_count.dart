// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'like_provider.dart';

// class LikeCount extends ConsumerWidget {
//   final String workoutFinishId;
//   const LikeCount({super.key, required this.workoutFinishId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final likeCountAsync = ref.watch(
//       likeCountProvider(workoutFinishId)
//       ); // 실제 workoutFinishId로 변경 필요
//     return Container(
//       child: likeCountAsync.when(
//         data: (likeCount) => Text(
//           '$likeCount',
//           style: const TextStyle(
//             color: Colors.black54,
//             fontSize: 14,
//           ),
//         ),
//         loading: () => const SizedBox.shrink(),
//         error: (e, st) => const SizedBox.shrink(),
//       ),
//     );
//   }
// }