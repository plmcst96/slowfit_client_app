import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/client/client_detail.dart';
import 'package:slowFit_client/provider/user_provider.dart';

import '../provider/bottom_bar_provider.dart';
import '../widget/custom_bottom_bar.dart';
import 'add_client.dart';

class ClientPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ClientPageState();
  }
}

class _ClientPageState extends ConsumerState<ClientPage> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final clients = ref.watch(userProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                      ref.read(bottomBarProvider.notifier).updateIndex(0);
                    },
                    icon: Icon(Icons.arrow_back_ios, color: Colors.pink[400],),
                  ),
                  Spacer(),
                  Text(
                    'Scegli cliente',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          sheetAnimationStyle: const AnimationStyle(
                            duration: Duration(seconds: 3),
                            reverseDuration: Duration(seconds: 1),
                          ),
                          builder: (BuildContext context) {
                            return SizedBox.expand(
                              child: AddClient(),
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 30,
                        color: Colors.pink[400],
                      )),
                ],
              ),
              SizedBox(height: 50),
              Expanded(
                child: GridView.builder(
                  itemCount: clients.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 3.5,
                  ),
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientDetail(
                              clientId: client.userId,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                image: AssetImage('assets/profile_ex.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            client.firstName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(currentIndex: selectedIndex),
    );
  }
}
