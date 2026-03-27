import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessagesInboxScreen extends StatelessWidget {
  const MessagesInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('rachel-req', 'Rachel Haddad', 'Sent you a message request', false, true),
      ('omar-thread', 'Omar Nassar', 'Can you send the physics file?', false, false),
      ('math-group', 'Math Study Group', 'Tony: I uploaded the sheet', true, false),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Messages',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_square_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search messages',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final id = item.$1;
                  final title = item.$2;
                  final subtitle = item.$3;
                  final isGroup = item.$4;
                  final isRequest = item.$5;

                  return ListTile(
                    onTap: () {
                      if (isRequest) {
                        context.go('/messages/request/$id');
                      } else {
                        context.go('/messages/$id');
                      }
                    },
                    leading: CircleAvatar(
                      child: Text(
                        isGroup ? 'MG' : title.split(' ').take(2).map((e) => e[0]).join(),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isGroup)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            child: const Text(
                              'Group',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isRequest
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                        : const Text('2:14 PM'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
