// import 'package:flutter/material.dart';
// import 'package:sidi/models/stylist.dart';

// class StylistsCard extends StatelessWidget {
//   final Stylist stylist;

//   const StylistsCard({super.key, required this.stylist});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(14),
//           child: Image.network(
//             stylist.image,
//             width: 64,
//             height: 64,
//             fit: BoxFit.cover,
//           ),
//         ),
//         const SizedBox(width: 18),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 stylist.name,
//                 style: const TextStyle(
//                   fontFamily: 'PlayfairDisplay',
//                   fontSize: 18,
//                   color: Color(0xFF1A1A1A),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 stylist.role,
//                 style: const TextStyle(
//                   fontSize: 11,
//                   letterSpacing: 2,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => DetailedArtistScreen(
//                             artistName: stylist.name,
//                             role: stylist.role,
//                             imageUrl: stylist.image,
//                           ),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       'BOOK NOW',
//                       style: TextStyle(
//                         fontSize: 12,
//                         letterSpacing: 1.2,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => DetailedArtistScreen(
//                             artistName: stylist.name,
//                             role: stylist.role,
//                             imageUrl: stylist.image,
//                           ),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       'VIEW',
//                       style: TextStyle(
//                         fontSize: 12,
//                         letterSpacing: 1.2,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.star, size: 16, color: Color(0xFFD4AF37)),
//                 const SizedBox(width: 2),
//                 Text(
//                   stylist.rating.toStringAsFixed(1),
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFFD4AF37),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               '• ${stylist.distance.toStringAsFixed(1)} MI',
//               style: const TextStyle(fontSize: 11, color: Colors.grey),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
