import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:refload/RefLoad/refload.dart';
import 'package:refload/example/cubit/example_cubit.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExampleCubit(),
      child: const _Content(),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content();

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RefLoad'),
      ),
      body: RefLoad(
        isCanLoadMore: true,
        isCanRefresh: true,
        onRefresh: () async {
          await context.read<ExampleCubit>().refresh();
        },
        onLoadMore: () async {
          await context.read<ExampleCubit>().loadMore();
        },
        slivers: [
          BlocBuilder<ExampleCubit, ExampleState>(
            builder: (_, e) {
              return SliverList.builder(
                itemCount: e.listBox.length,
                itemBuilder: (_, i) {
                  final item = e.listBox[i];

                  return Container(
                    color: i.isEven
                        ? Colors.amberAccent.withOpacity(.4)
                        : Colors.blueAccent.withOpacity(.4),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    child: Text('${item.name}'),
                  );
                },
              );
            },
          ),
        ],
        onLoadMoreWidget: BlocSelector<ExampleCubit, ExampleState, bool>(
          selector: (e) {
            return e.loading;
          },
          builder: (_, loading) {
            return loading
                ? const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text('OnLoadMore'),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
