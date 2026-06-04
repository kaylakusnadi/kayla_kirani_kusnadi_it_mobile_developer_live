import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/user_card_widget.dart';
import 'favorite_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void _initState() {
    super.initState();
    context.read<UserBloc>().add(FetchUserListEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<UserBloc>().add(FetchUserListEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Github Apps Demo"),
          actions: [
            IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Popular"),
              Tab(icon: Icon(Icons.favorite), text: "Favorite"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Popular Tab
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state.isUsersLoading && state.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state.usersError != null && state.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Terjadi Kesalahan: ${state.usersError}"),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => context.read<UserBloc>().add(FetchUserListEvent(isRefresh: true)),
                          child: const Text("Retry"),
                        )
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<UserBloc>().add(FetchUserListEvent(isRefresh: true));
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.hasReachedMax ? state.users.length : state.users.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.users.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return UserCardWidget(user: state.users[index]);
                    },
                  ),
                );
              },
            ),
            // Favorite Tab
            const FavoritePage(),
          ],
        ),
      ),
    );
  }
}